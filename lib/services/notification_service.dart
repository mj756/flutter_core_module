import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_core_module/services/preference_service.dart';
import 'package:flutter_core_module/utils/event_bus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'logger_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  eventBus.fire(
    NotificationTapped(response: notificationResponse),
  ); // ignore: avoid_print
  print(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
      'notification action tapped with input: ${notificationResponse.input}',
    );
  }
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  final flutterNotificationPlugin = FlutterLocalNotificationsPlugin();
  String notificationChannelId = '';
  String notificationChannelName = '';
  late NotificationDetails notificationDetail;
  final StreamController<NotificationResponse> _tapStreamController =
      StreamController.broadcast();

  Future<String> getFcmToken({String vapidKeyForWeb = ''}) async {
    String token = '';
    try {
      if (PreferenceService().getString('prefKeyFcmToken').isEmpty) {
        if (kIsWeb) {
          token =
              await FirebaseMessaging.instance.getToken(
                vapidKey: vapidKeyForWeb,
              ) ??
              '';
          PreferenceService().setString('prefKeyFcmToken', token);
        } else {
          token = await FirebaseMessaging.instance.getToken() ?? '';
        }
      } else {
        token = PreferenceService().getString('prefKeyFcmToken');
      }
    } catch (e) {
      LoggerService().log(message: e);
    }
    return token;
  }

  Future<void> initialize({
    required String channelId,
    required String channelName,
    String androidIcon = '@mipmap/ic_launcher',
    NotificationDetails? notificationDetails,
  }) async {
    notificationDetail =
        notificationDetails ??
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(),
        );

    notificationChannelId = channelId;
    notificationChannelName = channelName;

    await flutterNotificationPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings(androidIcon),
        iOS: const DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        ),
        macOS: const DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        ),
        linux: LinuxInitializationSettings(
          defaultActionName: 'Open notification',
          defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
        ),
      ),
      onDidReceiveNotificationResponse: (resp) {
        _tapStreamController.add(resp);
      },
      onDidReceiveBackgroundNotificationResponse: (resp) {
        _tapStreamController.add(resp);
      },
    );
  }

  void showLocalNotification({required RemoteMessage message}) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await flutterNotificationPlugin.show(
      id,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      notificationDetail,
      payload: json.encode(message.data),
    );
  }
}
