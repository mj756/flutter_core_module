import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;

import 'package:flutter_core_module/services/logger_service.dart';

class EncryptionService {
  factory EncryptionService() => _instance;
  EncryptionService._internal();
  static final EncryptionService _instance = EncryptionService._internal();

  String get key => 'jghtbghtyghtugjthtugfstegsbdgety';
  String get iv => 'jghtydfehtbchrky';

  String encrypt({required String content}) {
    try {
      final keyTemp = enc.Key.fromUtf8(key);
      final ivv = enc.IV.fromUtf8(iv);
      final encrypter = enc.Encrypter(
        enc.AES(keyTemp, mode: enc.AESMode.cbc, padding: 'PKCS7'),
      );

      final encrypted = encrypter.encrypt(content, iv: ivv);
      return base64Encode(encrypted.bytes);
    } catch (e) {
      LoggerService().log(message: e);
      return '';
    }
  }

  String decrypt({required String encryptedContent}) {
    final keyTemp = enc.Key.fromUtf8(key);
    final ivv = enc.IV.fromUtf8(iv);
    final encrypter = enc.Encrypter(
      enc.AES(keyTemp, mode: enc.AESMode.cbc, padding: 'PKCS7'),
    );

    final encrypted = enc.Encrypted(base64Decode(encryptedContent));
    return encrypter.decrypt(encrypted, iv: ivv);
  }
}
