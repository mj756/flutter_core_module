import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/main.dart';
import 'package:flutter_core_module/streams/app_events.dart';
import 'package:flutter_core_module/utils/event_bus.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppEventsStream().addEvent(
    AppEvent(type: AppEventType.backgroundNotificationReceived, data: message),
  );
  const MethodChannel channel = MethodChannel('flutter.core.module/channel');
  await channel.invokeMethod('notificationReceived',message.toMap());

}

class FirebaseService {
  factory FirebaseService() => _instance;
  FirebaseService._internal();
  static final FirebaseService _instance = FirebaseService._internal();

  void setHandler(){
    _methodChannel.setMethodCallHandler((call) async {
      if (call.method == 'notificationToDart') {
        LoggerService().log(message: 'notification message from kotlin');
        final data = call.arguments as Map<String,dynamic>;
        AppEventsStream().addEvent(
          AppEvent(type: AppEventType.backgroundNotificationReceived, data: data),
        );
        //  eventBus.fire(BackGroundNotificationReceived(notification: data));
      }else if (call.method == 'notificationClickToDart') {
        LoggerService().log(message: 'notification click  message from kotlin');
        final data = call.arguments as Map<String,dynamic>;
        AppEventsStream().addEvent(
          AppEvent(type: AppEventType.backgroundNotificationReceived, data: data),
        );
        // eventBus.fire(BackGroundNotificationReceived(notification: data));
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
          AppEventsStream().addEvent(
            AppEvent(type: AppEventType.notificationReceived, data: message),
          );
        //  eventBus.fire(BackGroundNotificationReceived(notification: message.data));
          const MethodChannel channel = MethodChannel('flutter.core.module/channel');
          channel.invokeMethod('notificationReceived',message.toMap());
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
