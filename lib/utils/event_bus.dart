import 'package:event_bus/event_bus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

EventBus eventBus = EventBus();

class NotificationTapped {
  NotificationTapped({required this.response});
  final NotificationResponse response;
}
