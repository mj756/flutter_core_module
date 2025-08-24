import 'package:flutter/material.dart';
import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/main.dart';
import 'package:flutter_core_module/streams/app_events.dart';
class CustomNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    AppEventsStream().addEvent(
      AppEvent(type: AppEventType.navigationPush, data: route.settings),
    );
    LoggerService().log(message: 'Route pushed: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    AppEventsStream().addEvent(
      AppEvent(type: AppEventType.navigationPop, data: route.settings),
    );
    LoggerService().log(message: 'Route popped: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AppEventsStream().addEvent(
      AppEvent(type: AppEventType.navigationReplace, data: newRoute!.settings),
    );
    LoggerService().log(message: 'Route replaced: ${newRoute!.settings.name}');
  }
}
