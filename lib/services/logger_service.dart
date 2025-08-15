import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../enums.dart';

class LoggerService {
  LoggerService._internal();
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  bool showLogInReleaseMode = false;
  void log({required dynamic message, LogLevel level = LogLevel.debug}) {
    if (kReleaseMode && !showLogInReleaseMode) return;

    final time = DateTime.now().toIso8601String();
    String emoji;
    switch (level) {
      case LogLevel.debug:
        emoji = "🐛";
        break;
      case LogLevel.info:
        emoji = "ℹ️";
        break;
      case LogLevel.warning:
        emoji = "⚠️";
        break;
      case LogLevel.error:
        emoji = "❌";
        break;
    }

    final logMessage = "$emoji [$time]: $message";
    String coloredMessage;
    switch (level) {
      case LogLevel.debug:
        coloredMessage = "\x1B[34m$logMessage\x1B[0m"; // Blue
        break;
      case LogLevel.info:
        coloredMessage = "\x1B[32m$logMessage\x1B[0m"; // Green
        break;
      case LogLevel.warning:
        coloredMessage = "\x1B[33m$logMessage\x1B[0m"; // Yellow
        break;
      case LogLevel.error:
        coloredMessage = "\x1B[31m$logMessage\x1B[0m"; // Red
        break;
    }

    developer.log(coloredMessage);
    unawaited(_writeLogToFile(message: coloredMessage));
  }

  Future<void> _writeLogToFile({required String message}) async {
    try {
      if (kIsWeb) {
        return;
      } else if (Platform.isAndroid == false || Platform.isIOS == false) {
        return;
      }
      final date = DateTime.now();
      final fileName = "${date.year}-${date.month}-${date.day}.log";
      final internalBaseDir = await getApplicationSupportDirectory();
      final internalLogsDir = Directory("${internalBaseDir.path}/app_logs");
      if (!await internalLogsDir.exists()) {
        await internalLogsDir.create(recursive: true);
      }
      final internalFile = File("${internalLogsDir.path}/$fileName");
      await internalFile.writeAsString(
        "$message\n",
        mode: FileMode.append,
        flush: false,
      );
    } catch (e) {}
  }
}
