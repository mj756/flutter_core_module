import 'package:event_bus/event_bus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core_module/main.dart';
import 'package:flutter_core_module/utils/event_bus.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  EventBus event = EventBus();
  event.fire(BackGroundNotificationReceived(notification: message));
}

class FirebaseService {
  Future<void> initialize({required Map<String, dynamic> options}) async {
    try {
      if (kIsWeb) {
        Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: options['apiKey'] as String,
            appId: options['appId'] as String,
            messagingSenderId: options['messagingSenderId'] as String,
            projectId: options['projectId'] as String,
          ),
        );
      } else {
        await Firebase.initializeApp();

        FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
        FirebaseMessaging.onMessage.listen(onBackgroundMessage);
        FirebaseMessaging.instance.getInitialMessage().then(
          (RemoteMessage? message) {},
        );
      }
    } catch (e) {
      LoggerService().log(message: 'Firebase Service error==>$e');
    }
  }
}
