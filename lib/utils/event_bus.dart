import 'package:event_bus/event_bus.dart';
import 'package:firebase_messaging/firebase_messaging.dart' show RemoteMessage;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final EventBus eventBus = EventBus();

class NotificationTapped {
  bool isLocalNotificationTapped;
  NotificationTapped({required this.isLocalNotificationTapped,this.response,this.firebaseMessage});
  final NotificationResponse? response;
  final RemoteMessage? firebaseMessage;
}


class BackGroundNotificationReceived {
  BackGroundNotificationReceived({required this.notification});
  final Map<String,dynamic> notification;
}
