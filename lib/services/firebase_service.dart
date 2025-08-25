import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/main.dart';
import 'package:flutter_core_module/streams/app_events.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppEventsStream().addEvent(
    AppEvent(type: AppEventType.backgroundNotificationReceived, data: message),
  );
  final port = IsolateNameServer.lookupPortByName('callback_port');
   port?.send(message.data);

  //const MethodChannel channel = MethodChannel('flutter.core.module/channel');
 // await channel.invokeMethod('notificationReceived',message.toMap());

}

class FirebaseService {
  factory FirebaseService() => _instance;
  FirebaseService._internal();
  static final FirebaseService _instance = FirebaseService._internal();

  void setHandler(){
    const portName = 'callback_port';

    IsolateNameServer.removePortNameMapping(portName);
    final port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, portName);

    port.listen((dynamic data) {
            print('data received in main port from pragma');
            LoggerService().log(message: 'data received in main port from pragma');

    });
    _methodChannel.setMethodCallHandler((call) async {
      if (call.method == 'notificationToDart') {
        LoggerService().log(message: 'notification message from kotlin');
        final data = call.arguments as Map<String,dynamic>;
        AppEventsStream().addEvent(
          AppEvent(type: AppEventType.backgroundNotificationReceived, data: data),
        );
      }else if (call.method == 'notificationClickToDart') {
        LoggerService().log(message: 'notification click  message from kotlin');
        final data = call.arguments as Map<String,dynamic>;
        AppEventsStream().addEvent(
          AppEvent(type: AppEventType.backgroundNotificationReceived, data: data),
        );
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
          const MethodChannel channel = MethodChannel('flutter.core.module/channel');
          channel.invokeMethod('notificationReceived',message.toMap());
        });

        FirebaseMessaging.onMessageOpenedApp.listen((message){
          AppEventsStream().addEvent(
            AppEvent(type: AppEventType.notificationClick, data: message),
          );
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
