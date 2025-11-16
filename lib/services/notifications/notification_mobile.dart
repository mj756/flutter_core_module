import 'dart:ui' show IsolateNameServer;

import 'package:awesome_notifications/awesome_notifications.dart' show NotificationActionButton, NotificationLayout, AwesomeNotifications, NotificationCategory, NotificationContent, NotificationChannel;
import 'package:awesome_notifications/src/models/received_models/received_action.dart';
import 'package:flutter/material.dart' show WidgetsFlutterBinding;
import 'package:flutter_core_module/classes/notification.dart';
import 'package:flutter_core_module/classes/notification_model.dart';
import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/services/logger_service.dart';
import 'package:flutter_core_module/services/notifications/notification_service.dart' show NotificationService;
import 'package:flutter_core_module/streams/app_events.dart';

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction) async {
  WidgetsFlutterBinding.ensureInitialized();
  final port = IsolateNameServer.lookupPortByName('callback_port');
  port?.send(receivedAction);
  print('Notification is tapped in killed state');
}
class NotificationServiceMobile implements NotificationService{

  factory NotificationServiceMobile() => _instance;
  NotificationServiceMobile._internal();
  static final NotificationServiceMobile _instance = NotificationServiceMobile._internal();

  @override
  Future<void> getLaunchDetails() async{

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

  }

  @override
  void initialize({required List<CustomNotificationDetailModel> channels,required String defaultIcon}) async{
   try {
     List<NotificationChannel> channelsList = List.empty(growable: true);
     for (int i = 0; i < channels.length; i++) {
       channelsList.add(NotificationChannel(
           icon: channels[i].icon,
           channelKey: channels[i].channelKey,
           channelName: channels[i].channelName,
           channelDescription: channels[i].channelDescription,
           playSound: channels[i].playSound,
           criticalAlerts: channels[i].criticalAlerts,
           onlyAlertOnce: channels[i].onlyAlertOnce,
           enableLights: channels[i].enableLights,
           enableVibration: channels[i].enableVibration,
           groupAlertBehavior: channels[i].groupAlertBehavior,
           importance: channels[i].importance,
           defaultPrivacy: channels[i].defaultPrivacy,
           defaultColor: channels[i].defaultColor,
           ledColor: channels[i].ledColor,
           soundSource: channels[i].soundSource
       ));
     }

     await AwesomeNotifications().initialize(
         defaultIcon, channelsList,
         debug: false);

     AwesomeNotifications().setListeners(
       onActionReceivedMethod: onActionReceivedMethod,
     );
   }catch(e){
     LoggerService().log(message: e.toString());
   }
  }

  @override
  Future<void> showNotification({required MyNotificationModel payload}) async {
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