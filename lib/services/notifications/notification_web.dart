import 'package:awesome_notifications/src/models/received_models/received_action.dart';
import 'package:flutter_core_module/classes/notification.dart';
import 'package:flutter_core_module/classes/notification_model.dart';
import 'package:flutter_core_module/services/notifications/notification_service.dart' show NotificationService;

class NotificationServiceWeb implements NotificationService{
  factory NotificationServiceWeb() => _instance;
  NotificationServiceWeb._internal();
  static final NotificationServiceWeb _instance = NotificationServiceWeb._internal();
  @override
  Future<ReceivedAction?> getLaunchDetails() {
    throw UnimplementedError();
  }

  @override
  Future<void> initialize({required List<CustomNotificationDetailModel> channels,required String defaultIcon}) async{

  }

  @override
  Future<void> showNotification({required MyNotificationModel payload}) {
    throw UnimplementedError();
  }

}