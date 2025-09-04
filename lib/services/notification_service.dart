import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show WidgetsFlutterBinding;
import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/services/preference_service.dart';
import 'package:flutter_core_module/streams/app_events.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_core_module/services/logger_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  WidgetsFlutterBinding.ensureInitialized();
  final port = IsolateNameServer.lookupPortByName('callback_port');
  port?.send(notificationResponse);
  print('Notification is tapped in killed state');
  /*const MethodChannel channel = MethodChannel('flutter.core.module/channel');
  channel.invokeMethod('notificationClick',notificationResponse);*/
}

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  final flutterNotificationPlugin = FlutterLocalNotificationsPlugin();
  String notificationChannelId = '';
  String notificationChannelName = '';
  late NotificationDetails notificationDetail;

  Future<String> getFcmToken({String vapidKeyForWeb = ''}) async {
    String token = '';
    try {
      if (PreferenceService().getString(key:'prefKeyFcmToken').isEmpty) {
        if (kIsWeb) {
          token =
              await FirebaseMessaging.instance.getToken(
                vapidKey: vapidKeyForWeb,
              ) ??
              '';
          PreferenceService().setString(key:'prefKeyFcmToken', value:token);
        } else {
          token = await FirebaseMessaging.instance.getToken() ?? '';
          PreferenceService().setString(key:'prefKeyFcmToken', value:token);
        }
      } else {
        token = PreferenceService().getString(key:'prefKeyFcmToken');
      }
    } catch (e) {
      LoggerService().log(message: 'Error while getting fcm token $e');
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
          iOS: const DarwinNotificationDetails(),
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
        AppEventsStream().addEvent(
          AppEvent(type: AppEventType.localNotificationTapped, data: resp),
        );
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<NotificationResponse?> getLaunchDetails() async {
    NotificationResponse? detail;
    try {
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =await flutterNotificationPlugin.getNotificationAppLaunchDetails();

      if (notificationAppLaunchDetails!=null && notificationAppLaunchDetails.didNotificationLaunchApp) {
        detail= notificationAppLaunchDetails.notificationResponse;
        if (detail != null) {
          AppEventsStream().addEvent(
            AppEvent(type: AppEventType.initialNotificationReceived, data: detail)
          );
        }
      }else{
      }

    } catch (e) {
      //
    }
    return detail;
  }

  void showLocalNotification({required String title,required String body, required Map<String,dynamic> message}) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await flutterNotificationPlugin.show(
      id,
     title,
      body,
      notificationDetail,
      payload: json.encode(message),
    );
  }
}
