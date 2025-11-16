import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show AppLifecycleListener, WidgetsBinding;
import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/main.dart';
import 'package:flutter_core_module/services/connectivity_service.dart';
import 'package:flutter_core_module/services/notifications/notification_factory.dart';

class AppEvent {
  AppEvent({required this.type, this.data});
  final AppEventType type;
  final dynamic data;
}



class AppEventsStream {

  factory AppEventsStream() => _instance;
  AppEventsStream._internal();
  static final AppEventsStream _instance = AppEventsStream._internal();
  final StreamController<AppEvent> _controller =StreamController<AppEvent>.broadcast();
  Stream<AppEvent> get stream => _controller.stream;
  late AppLifecycleListener _lifecycleListener;
  void addEvent(AppEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }
  void initialize(){
    _lifecycleListener = AppLifecycleListener(
      onPause: () {
        AppEventsStream().addEvent(
          AppEvent(type: AppEventType.appPaused),
        );
      },
      onResume: () {
        AppEventsStream().addEvent(
          AppEvent(type: AppEventType.appResumed),
        );
      },
      onInactive: () {
        AppEventsStream().addEvent(
          AppEvent(type: AppEventType.appInActive),
        );
      },
      onDetach: () {
        AppEventsStream().addEvent(
          AppEvent(type: AppEventType.appDetached),
        );
      },
    );
    ConnectivityService().startListening();
    if(!kIsWeb) {

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await NotificationFactory.getInstance().getLaunchDetails();
        await FirebaseService().getInitialMessage();
      });
    }
  }
  void dispose(){
    _controller.close();
    _lifecycleListener.dispose();
    if(!kIsWeb) {
      ConnectivityService().dispose();
    }
  }
}
