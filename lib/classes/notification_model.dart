import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart' show ActionType;
import 'package:flutter/material.dart' show Colors;

class MyNotificationModel {
  MyNotificationModel(
      { required this.title,
        required this.action,
        required this.channelKey,
        required this.message,
        required this.notificationId, this.imageURL = '',
        this.largeIcon = '',
        this.locked = false,
        this.criticalAlert = true,
        this.wakeUpScreen = true,
        this.autoDismissible = true,
        this.backgroundColor = Colors.white,
        this.fontColor = Colors.black,
        this.notificationTapData=const{},
        this.notificationSound = ''}) ;

  late String title;
  late String message;
  final String notificationId;
  final String action ,channelKey ;
  final Color backgroundColor, fontColor;
  late Map<String,String> notificationTapData={};

  late String imageURL, largeIcon;
  late String notificationSound;
  List<MyNotificationButtons> buttons = List.empty(growable: true);
  late bool autoDismissible,
      criticalAlert,
      wakeUpScreen,
      locked,
      isTimerNotification;

}

class MyNotificationButtons {

  MyNotificationButtons(
      {required this.key,required this.title, required this.action, required this.color});

  final String title,key;
  final ActionType action;
  final Color color;
}
