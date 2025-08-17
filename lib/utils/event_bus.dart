import 'package:event_bus/event_bus.dart';
import 'package:firebase_messaging/firebase_messaging.dart' show RemoteMessage;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

EventBus eventBus = EventBus();

class NotificationTapped {
  NotificationTapped({required this.response});
  final NotificationResponse response;
}

class BackGroundNotificationReceived {
  BackGroundNotificationReceived({required this.notification});
  final RemoteMessage notification;
}
