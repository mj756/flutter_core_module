import 'package:firebase_messaging/firebase_messaging.dart' show RemoteMessage;

extension RemoteMessageMapper on RemoteMessage {
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'sentTime': sentTime?.millisecondsSinceEpoch,
      'from': from,
      'data': data,
      'notification': {
        'title': notification?.title,
        'body': notification?.body,
        'android': notification?.android?.toMap(),
        'apple': notification?.apple?.toMap(),
      }
    };
  }
}
