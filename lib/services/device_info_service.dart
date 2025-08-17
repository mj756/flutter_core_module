import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart' as device_info;
import 'package:flutter/foundation.dart';
import 'package:flutter_core_module/main.dart';

class DeviceInfoService {
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();
  static final DeviceInfoService _instance = DeviceInfoService._internal();

  Future<void> load() async {
    try {
      if (PreferenceService().getString(key:'prefKeyDeviceInfo').isEmpty) {
      //  await device_info.loadLibrary();
        String fcmToken = PreferenceService().getString(key:'prefKeyFcmToken');
        if (kIsWeb) {
          final data = await device_info.DeviceInfoPlugin().webBrowserInfo;
          PreferenceService().setString(
            key:'prefKeyDeviceInfo',
            value:json.encode({
              'sdkVersion': data.browserName.name,
              'platform': 'web',
              'deviceModel': data.appName,
              'brand': data.appVersion,
              'deviceId': data.browserName.name,
              'fcmToken': fcmToken,
              'serialNumber': '',
              'osVersion': 'Chrome',
            }),
          );
        } else if (Platform.isAndroid) {
          final build = await device_info.DeviceInfoPlugin().androidInfo;
          PreferenceService().setString(
            key:'prefKeyDeviceInfo',
            value:json.encode({
              'platform': 'android',
              'sdkVersion': build.version.sdkInt,
              'deviceModel': build.model,
              'brand': build.brand,
              'fcmToken': fcmToken,
              'deviceId': build.id,
              'serialNumber': build.serialNumber,
              'osVersion': 'Android',
            }),
          );
        } else if (Platform.isIOS) {
          final data = await device_info.DeviceInfoPlugin().iosInfo;
          PreferenceService().setString(
            key:'prefKeyDeviceInfo',
            value:json.encode({
              'sdkVersion': data.systemVersion,
              'platform': 'ios',
              'fcmToken': fcmToken,
              'deviceModel': data.model,
              'brand': data.modelName,
              'modelName': data.modelName,
              'deviceId': ' dfgdfg',
              'serialNumber': data.identifierForVendor,
              'osVersion': 'ios',
            }),
          );
        }
      } else {}
    } catch (e) {}
  }

  Map<String, dynamic> getDeviceData() {
    try {
      String data = PreferenceService().getString(key:'prefKeyDeviceInfo');
      if (data.isEmpty) {
        return {};
      } else {
        return json.decode(data);
      }
    } catch (e) {
      LoggerService().log(message: e);
    }
    return {};
  }
}
