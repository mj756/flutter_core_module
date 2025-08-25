import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/main.dart';
import 'package:flutter_core_module/streams/app_events.dart';

class ConnectivityService {
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();
  static final ConnectivityService _instance = ConnectivityService._internal();
  bool hasInternet=true;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void startListening() {
    ApiService().hasInternet().then((result){
      hasInternet=result;
      AppEventsStream().addEvent(
        AppEvent(type:result==true ? AppEventType.internetConnected:AppEventType.internetDisConnected, data: result),
      );
    });
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final hasConnection = _hasConnection(results);

      if(hasConnection){
        ApiService().hasInternet().then((result){
          hasInternet=result;
          AppEventsStream().addEvent(
            AppEvent(type:result==true ? AppEventType.internetConnected:AppEventType.internetDisConnected, data: result),
          );
        });
      }else{
        hasInternet=false;
        AppEventsStream().addEvent(
          AppEvent(type: AppEventType.internetDisConnected, data: false),
        );
      }

    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }
}
