import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_core_module/services/logger_service.dart';

class PermissionService {
  factory PermissionService() => _instance;
  PermissionService._internal();
  static final PermissionService _instance = PermissionService._internal();

  Future<bool> checkNotificationPermission() async {
    bool permissionStatus = false;
    try {
      var status = await Permission.notification.status;
      if (status.isDenied) {
        permissionStatus = false;
      } else if (status.isPermanentlyDenied) {
      } else if (status.isLimited) {
        permissionStatus = false;
      } else if (status.isProvisional) {
        permissionStatus = false;
      } else if (status.isGranted) {
        permissionStatus = true;
      }
    } catch (e) {
      LoggerService().log(message: e);
    }

    return permissionStatus;
  }

  Future<bool> requestNotificationPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  }) async {
    bool status = false;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: alert,
        announcement: announcement,
        badge: badge,
        carPlay: carPlay,
        criticalAlert: criticalAlert,
        provisional: provisional,
        sound: sound,
        providesAppNotificationSettings: providesAppNotificationSettings,
      );
      status =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      LoggerService().log(message: e);
    }
    return status;
  }

  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.locationWhenInUse.request();
      return status.isGranted;
    } catch (e) {
      LoggerService().log(message: e);
      return false;
    }
  }

  Future<bool> requestBackgroundLocationPermission() async {
    try {
      final status = await Permission.locationAlways.request();
      return status.isGranted;
    } catch (e) {
      LoggerService().log(message: e);
      return false;
    }
  }

  Future<bool> requestStoragePermission() async {
    bool status = false;
    try {
      status = await Permission.storage.isGranted;
      if (status == true) {
        return status;
      }
      final permissionStatus = await Permission.storage.request();
      status = permissionStatus.isGranted;
      return status;
    } catch (e) {
      LoggerService().log(message: e);
      return false;
    }
  }

  Future<bool> requestPreciseAlarmPermission() async {
    bool status = false;
    PermissionStatus status1 = await Permission.ignoreBatteryOptimizations
        .request();
    if (status1.isGranted) {
      status = true;
    } else {
      status1 = await Permission.ignoreBatteryOptimizations.request();
      if (status1.isGranted) {
        status = true;
      } else {
        status = false;
      }
    }
    return status;
  }
}
