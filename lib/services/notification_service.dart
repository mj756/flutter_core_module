/*import 'dart:async';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show WidgetsFlutterBinding;
import 'package:flutter_core_module/classes/notification.dart';
import 'package:flutter_core_module/classes/notification_model.dart';
import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/services/preference_service.dart';
import 'package:flutter_core_module/streams/app_events.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_core_module/services/logger_service.dart';

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction) async {
  WidgetsFlutterBinding.ensureInitialized();
  final port = IsolateNameServer.lookupPortByName('callback_port');
  port?.send(receivedAction);
  print('Notification is tapped in killed state');
}

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  Future<void> initializeLocalNotifications({required List<CustomNotificationDetailModel> channels,required String defaultIcon}) async {
     {

      List<NotificationChannel> channelsList=List.empty(growable: true);
      for(int i=0;i<channels.length;i++){
        channelsList.add(NotificationChannel(
            icon:channels[i].icon,
            channelKey:channels[i].channelKey,
            channelName:channels[i].channelName,
            channelDescription:channels[i].channelDescription,
            playSound: channels[i].playSound,
            criticalAlerts: channels[i].criticalAlerts,
            onlyAlertOnce: channels[i].onlyAlertOnce,
            enableLights: channels[i].enableLights,
            enableVibration: channels[i].enableVibration,
            groupAlertBehavior:channels[i].groupAlertBehavior,
            importance:channels[i].importance ,
            defaultPrivacy: channels[i].defaultPrivacy,
            defaultColor: channels[i].defaultColor,
            ledColor:channels[i].ledColor,
            soundSource:channels[i].soundSource
        ));
      }

      await AwesomeNotifications().initialize(
          defaultIcon, channelsList,
          debug: false);

      AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
      );
    }
  }

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
/*
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
  }*/

  Future<ReceivedAction?> getLaunchDetails() async {
    ReceivedAction? detail;
    try {
        ReceivedAction? receivedAction = await AwesomeNotifications().getInitialNotificationAction(removeFromActionEvents: false);
        if (receivedAction != null) {
          AppEventsStream().addEvent(
              AppEvent(type: AppEventType.initialNotificationReceived, data:receivedAction)
          );
        } else {
          print('App was not launched by a notification');
        }
    } catch (e) {
      //
    }
    return detail;
  }
  Future<void> showNotification(
      {required MyNotificationModel payload,
        required bool isScheduled,
        bool isTimerNotification = false,
        int durationInSeconds = 0}) async {
    List<NotificationActionButton> actionButtons = List.empty(growable: true);
    try {
      for (int i = 0; i < payload.buttons.length; i++) {

        actionButtons.add(NotificationActionButton(
            color: payload.buttons[i].color,
            key: payload.buttons[i].key,
            actionType: payload.buttons[i].action,
            label: payload.buttons[i].title));
      }
      NotificationLayout notificationLayout = NotificationLayout.BigText;
      if (payload.imageURL.isNotEmpty) {
        notificationLayout = NotificationLayout.BigPicture;
      }

      if (payload.channelKey.isNotEmpty) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            fullScreenIntent: true,
            id: int.parse(payload.notificationId),
            channelKey: payload.channelKey,
            locked: payload.locked,
            autoDismissible: payload.autoDismissible,
            title: payload.title,
            body: payload.message,
            displayOnForeground: true,
            displayOnBackground: true,
            backgroundColor: payload.backgroundColor,
            color: payload.fontColor,
            hideLargeIconOnExpand: true,
            category: NotificationCategory.Message,
            criticalAlert: payload.criticalAlert,
            wakeUpScreen: payload.wakeUpScreen,
            bigPicture: payload.imageURL.isEmpty ? null : payload.imageURL,
            largeIcon: 'resource://drawable/ic_launcher',
            icon: 'resource://drawable/ic_launcher',
            notificationLayout: notificationLayout,
            payload:payload.notificationTapData,
          ),
          actionButtons: actionButtons,
        );
      }
    } catch (e) {
      LoggerService().log(message: e.toString());
    }
  }


}
*/