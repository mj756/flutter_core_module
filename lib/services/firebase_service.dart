import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core_module/main.dart';
import 'package:flutter_core_module/utils/event_bus.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('flutter.core.module/channel');
  await channel.invokeMethod('notificationReceived',message.toMap());

}

class FirebaseService {
  FirebaseService() {
    _methodChannel.setMethodCallHandler((call) async {
      if (call.method == 'notificationToDart') {
        final data = call.arguments as Map<String,dynamic>;
        eventBus.fire(BackGroundNotificationReceived(notification: data));
      }else if (call.method == 'notificationClickToDart') {
        final data = call.arguments as Map<String,dynamic>;
        eventBus.fire(BackGroundNotificationReceived(notification: data));
      }
    });
  }
  final MethodChannel _methodChannel = const MethodChannel('flutter.core.module/channel');


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
        FirebaseMessaging.onMessage.listen((message){
          eventBus.fire(BackGroundNotificationReceived(notification: message.data));
          NotificationService().showLocalNotification(title: message.notification!.title??'', body: message.notification!.body??'', message: message.data);
        });

        FirebaseMessaging.onMessageOpenedApp.listen((message){
          eventBus.fire(NotificationTapped(isLocalNotificationTapped: false, firebaseMessage: message));
        });

      }
    } catch (e) {
      LoggerService().log(message: 'Firebase Service error==>$e');
    }
  }
  Future<RemoteMessage?> getInitialMessage()async{
    RemoteMessage? msg=await FirebaseMessaging.instance.getInitialMessage();
    return msg;
  }
}
