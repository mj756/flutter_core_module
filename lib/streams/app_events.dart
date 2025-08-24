import 'dart:async';

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
  void addEvent(AppEvent event) {
    if (!_controller.isClosed) {
      LoggerService().log(message: 'adding app event');
      _controller.add(event);
    }
  }
  void initialize(){
    ConnectivityService().startListening();
  }
  void dispose(){
    _controller.close();
    ConnectivityService().dispose();
  }
}
