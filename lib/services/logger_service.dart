import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_core_module/enums.dart';
import 'package:flutter_core_module/utils/helper_service.dart';
class LoggerService {
  factory LoggerService() => _instance;
  LoggerService._internal();
  static final LoggerService _instance = LoggerService._internal();
  bool showLogInReleaseMode = false;
  void log({required dynamic message, LogLevel level = LogLevel.debug}) {
    if (kReleaseMode && !showLogInReleaseMode) return;

    final time = HelperService().getFormattedDate(date: DateTime.now().toIso8601String(),outputFormat: 'yyyy-MM-dd hh:mm');// ;
    String emoji;
    switch (level) {
      case LogLevel.debug:
        emoji = '🐛';
        break;
      case LogLevel.info:
        emoji = 'ℹ️';
        break;
      case LogLevel.warning:
        emoji = '⚠️';
        break;
      case LogLevel.error:
        emoji = '❌';
        break;
    }

    final logMessage = '$emoji [$time]: $message';
    String coloredMessage;
    switch (level) {
      case LogLevel.debug:
        coloredMessage = logMessage; // Blue
        break;
      case LogLevel.info:
        coloredMessage = logMessage; // Green
        break;
      case LogLevel.warning:
        coloredMessage = logMessage; // Yellow
        break;
      case LogLevel.error:
        coloredMessage = logMessage; // Red
        break;
    }

    developer.log(coloredMessage);
    _writeLogToFile(message: coloredMessage);
  }

  Future<void> _writeLogToFile({required String message}) async {
    try {
      if (kIsWeb) {
        return;
      }
      final date = DateTime.now();
      final fileName = '${date.year}-${date.month}-${date.day}.log';
      final internalBaseDir = await getApplicationDocumentsDirectory();
      final internalLogsDir = Directory('${internalBaseDir.path}/app_logs');
      if (!await internalLogsDir.exists()) {
        await internalLogsDir.create(recursive: true);
      }
      final internalFile = File('${internalLogsDir.path}/$fileName');
      await internalFile.writeAsString(
        '$message\n',
        mode: FileMode.append,
        flush: false,
      );
    } catch (e) {
      //
    }
  }
}
