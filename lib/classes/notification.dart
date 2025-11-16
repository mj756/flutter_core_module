import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart' show GroupAlertBehavior, NotificationImportance, NotificationPrivacy;
class CustomNotificationDetailModel{
  CustomNotificationDetailModel({
    required this.icon,
    required this.channelKey,
    required this.channelName,
    required this.channelDescription,
    required this.playSound,
    required this.criticalAlerts,
    required this.onlyAlertOnce,
    required this.enableLights,
    required this.enableVibration,
    required this.groupAlertBehavior,
    required this.importance,
    required this.defaultPrivacy,
    required this.defaultColor,
    required this.ledColor,
    required this.soundSource,
  });
  final String icon;
  final String channelKey;
  final String channelName;
  final String channelDescription;
  final bool playSound;
  final bool criticalAlerts;
  final bool onlyAlertOnce;
  final bool enableLights;
  final bool enableVibration;
  final GroupAlertBehavior groupAlertBehavior;
  final NotificationImportance importance;
  final NotificationPrivacy defaultPrivacy;
  final Color defaultColor;
  final Color ledColor;
  final String soundSource;


}