import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/main.dart';
import 'package:flutter_core_module/streams/app_events.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show NotificationResponse;

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  final port = IsolateNameServer.lookupPortByName('callback_port');
  port?.send(message.data);
}

class FirebaseService {
  factory FirebaseService() => _instance;
  FirebaseService._internal();
  static final FirebaseService _instance = FirebaseService._internal();

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
        const portName = 'callback_port';
        IsolateNameServer.removePortNameMapping(portName);
        final port = ReceivePort();
        IsolateNameServer.registerPortWithName(port.sendPort, portName);
        port.listen((dynamic data) {
          if (data is RemoteMessage) {
            AppEventsStream().addEvent(
              AppEvent(
                type: AppEventType.backgroundNotificationReceived,
                data: data,
              ),
            );
          } else if (data is NotificationResponse) {
            AppEventsStream().addEvent(
              AppEvent(type: AppEventType.localNotificationTapped, data: data),
            );
          }
        });
        await Firebase.initializeApp();

        FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
        FirebaseMessaging.onMessage.listen((message) {
          AppEventsStream().addEvent(
            AppEvent(type: AppEventType.notificationReceived, data: message),
          );
          //  const MethodChannel channel = MethodChannel('flutter.core.module/channel');
          // channel.invokeMethod('notificationReceived',message.toMap());
        });

        FirebaseMessaging.onMessageOpenedApp.listen((message) {
          AppEventsStream().addEvent(
            AppEvent(type: AppEventType.notificationClick, data: message),
          );
        });
      }
    } catch (e) {
      print('Firebase Service error==>${e.toString()}');
    }
  }

  Future<void> getInitialMessage() async {
    try {
      RemoteMessage? msg = await FirebaseMessaging.instance.getInitialMessage();
      if (msg != null) {
        AppEventsStream().addEvent(
          AppEvent(type: AppEventType.notificationClick, data: msg),
        );
      }
    } catch (e) {
      //
    }
  }

  Future<String> getFcmToken() async {
    String token = '';
    try {
      if (PreferenceService().getString(key: 'fcmToken').isNotEmpty) {
        token = PreferenceService().getString(key: 'fcmToken');
      } else {
        token = await FirebaseMessaging.instance.getToken() ?? '';
        PreferenceService().setString(key: 'fcmToken', value: token);
      }
    } catch (e) {
      //
    }
    return token;
  }
}
