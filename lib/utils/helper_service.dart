import 'dart:io';
import 'dart:math' show Random;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show BuildContext, FocusManager, FocusScope, FocusNode;
import 'package:flutter/services.dart' show MethodChannel, SystemChannels;
import 'package:flutter_core_module/main.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../services/download/download_factory.dart';

class HelperService {
  final _methodChannel = 'flutter.core.module/channel';

  Future<String> getDownloadDirectory() async {
    MethodChannel channel = MethodChannel(_methodChannel);
    try {
      if (Platform.isAndroid) {
        //path_provider library is not supported in android version so we have to use native functionality.
        String path = await channel.invokeMethod('getDownloadDirectory');
        return path;
      } else if (Platform.isIOS) {
        final Directory downloadsDir = await getApplicationDocumentsDirectory();
        return downloadsDir.path;
      }
    } catch (ex) {
      LoggerService().log(message: 'Error while getting download directory===>$ex');
    }
    return '';
  }

  int generateRandomNumber() {
    Random rng = Random();
    return rng.nextInt(10000000);
  }

  String convertStringToInitCap({required String word}) {
    if (word.isEmpty) {
      return '';
    }
    return word[0].toUpperCase() + word.substring(1);
  }

  Future<bool> showBatteryOptimizationDialog({
    required bool isSystemDialog,
  }) async {
    bool status = true;
    try {
      if (Platform.isAndroid) {
        if (isSystemDialog) {
          status = await MethodChannel(
            _methodChannel,
          ).invokeMethod('checkOptimizationStatus');
          if (!status) {
            MethodChannel(
              _methodChannel,
            ).invokeMethod('openBatteryOptimizationSetting');
          }
        }
      }
    } catch (e) {
      LoggerService().log(message: e);
    }
    return status;
  }

  String? getFormattedDate({
    required String date,
    String outputFormat = 'dd-MM-yyyy',
  }) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      if (parsedDate.isUtc) {
        parsedDate = parsedDate.toLocal();
      }
      return DateFormat(outputFormat).format(parsedDate);
    } catch (e) {
      LoggerService().log(message: 'Invalid date format exception==>$e');
      return null;
    }
  }

  Future<String> getAppFlavor() async {
    try {
      if (Platform.isAndroid) {
        final String result = await MethodChannel(
          _methodChannel,
        ).invokeMethod('getFlavor');
        print(result);
        return result;
      } else {
        return 'prod';
      }
    } catch (e) {
      LoggerService().log(message: 'Error while getting app flavor===>$e');
    }
    return '';
  }

  bool isUrl(String string) {
    final urlPattern = RegExp(
      r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-zA-Z0-9]+([-.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}(:[0-9]{1,5})?(\/.*)?$',
    );
    return urlPattern.hasMatch(string);
  }

  Future<String?> downloadFile({required String url}) async {
    if (isUrl(url)) {
      try {
        String? path = await DownloadFactory.getInstance().download(url: url);
        return path;
      } catch (e) {
        LoggerService().log(message: e);
        return null;
      }
    }
    return null;
  }

  Future<bool> checkDeviceSecurity() async {
    bool status = true;
    MethodChannel channel = MethodChannel(_methodChannel);
    try {
      if (Platform.isAndroid) {
        status = await channel.invokeMethod('checkDeviceSecure');
      } else {
        status = false;
      }
    } catch (ex) {
      LoggerService().log(message: ex);
      status = false;
    }
    return status;
  }

  Future<bool> checkMockLocationStatus() async {
    bool status = false;
    MethodChannel channel = MethodChannel(_methodChannel);
    try {
      if (kIsWeb) {
        status = false;
      } else if (Platform.isAndroid) {
        status = await channel.invokeMethod('checkMockLocationStatus');
      } else {
        status = false;
      }
    } catch (ex) {
      LoggerService().log(message: ex);
      status = false;
    }
    return status;
  }

  void hideKeyboard({required BuildContext context}) {
    FocusManager.instance.primaryFocus!.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
