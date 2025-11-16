import 'package:flutter_core_module/classes/notification.dart';
import 'package:flutter_core_module/classes/notification_model.dart';

// Conditional exports
export 'notification_service.dart'
if (dart.library.io) 'notification_mobile.dart'
if (dart.library.html) 'notification_web.dart';

/// Base notification service interface
abstract class NotificationService {
  void initialize({
    required List<CustomNotificationDetailModel> channels,
    required String defaultIcon,
  });

  Future<void> getLaunchDetails();

  Future<void> showNotification({required MyNotificationModel payload});
}
