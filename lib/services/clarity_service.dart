import 'package:clarity_flutter/clarity_flutter.dart';

class ClarityService {
  ClarityService._internal();
  factory ClarityService() => _instance;
  static final ClarityService _instance = ClarityService._internal();
  String _sessionId = '';
  ClarityConfig getConfig({required String projectId}) {
    return ClarityConfig(projectId: projectId, logLevel: LogLevel.None);
  }

  void setClarityOnSessionStartedCallback() {
    Clarity.setOnSessionStartedCallback((String sessionId) {
      _sessionId = sessionId;
    });
  }

  String getSessionId() {
    return _sessionId;
  }

  String getClaritySessionUrl() {
    return Clarity.getCurrentSessionUrl() ?? '';
  }

  void sendClarityCustomEvent({required String event}) {
    Clarity.sendCustomEvent(event);
  }

  void setClarityScreenName({required String screenName}) {
    Clarity.setCurrentScreenName(screenName);
  }

  void pauseClarity() {
    Clarity.pause();
  }

  void resumeClarity() {
    Clarity.resume();
  }

  bool isClarityPaused() {
    return Clarity.isPaused();
  }
}
