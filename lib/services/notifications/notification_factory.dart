import 'package:flutter/foundation.dart';
import 'package:flutter_core_module/services/notifications/notification_mobile.dart'
if (dart.library.io) 'notification_mobile.dart';
import 'package:flutter_core_module/services/notifications/notification_service.dart';
import 'package:flutter_core_module/services/notifications/notification_web.dart'
if (dart.library.html) 'notification_web.dart';

class NotificationFactory {
  static NotificationService getInstance() {
    if (kIsWeb) {
      return NotificationServiceWeb();
    } else {
      return NotificationServiceMobile();
    }
  }
}
