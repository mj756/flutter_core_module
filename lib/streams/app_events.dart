import 'dart:async';

import 'package:flutter/material.dart' show AppLifecycleListener, WidgetsBinding;
import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/main.dart';
import 'package:flutter_core_module/services/connectivity_service.dart';


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
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      LoggerService().log(message: 'Post frame call back');
      await NotificationService().getLaunchDetails();
      await FirebaseService().getInitialMessage();
    });
  }
  void dispose(){
    _controller.close();
    _lifecycleListener.dispose();
    ConnectivityService().dispose();
  }
}
