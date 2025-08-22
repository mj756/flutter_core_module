import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_core_module/services/logger_service.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_core_module/services/encryption_service.dart';

class PreferenceService {
  factory PreferenceService() => _instance;
  PreferenceService._internal();
  static final PreferenceService _instance = PreferenceService._internal();
  late final Box<dynamic> _box;
  bool isInitialized = false;
  bool isEncryptionEnabled = false;
  Future<void> initPreference({bool encryptionEnabled = false}) async {
    try {
      isEncryptionEnabled = encryptionEnabled;
      if (kIsWeb) {
        if (isInitialized == false) {
          _box = await Hive.openBox('prefs');
          isInitialized = true;
        }
      } else {
        if (isInitialized == false) {
          Directory dir = await getApplicationDocumentsDirectory();
          Hive.init(dir.path);
          _box = await Hive.openBox('prefs');
          isInitialized = true;
        }
      }
    } catch (e) {
      LoggerService().log(message: e);
    }
  }

  void clear() {
    _box.clear();
  }

  bool contains({required String key}) {
    return _box.containsKey(key);
  }

  void setInt({required String key, required int value}) {
    if (isEncryptionEnabled) {
      setString(key:key, value:value.toString());
    } else {
      _box.put(key, value);
    }
  }

  int getInt({required String key,int defaultValue = 0}) {
    if (isEncryptionEnabled) {
      try {
        String temp = getString(key:key);
        return int.parse(temp);
      } catch (e) {
        LoggerService().log(message: e);
        return defaultValue;
      }
    } else {
      return _box.get(key, defaultValue: defaultValue) ?? defaultValue;
    }
  }

  void setString({required String key, required String value}) {
    try {
      if (isEncryptionEnabled) {
        if (value.isEmpty) {
          _box.put(key, '');
        } else {
          String encrypted = EncryptionService().encrypt(content: value);
          _box.put(key, encrypted);
        }
      } else {
        _box.put(key, value);
      }
    } catch (e) {
      LoggerService().log(message: e);
      // handle encryption error
    }
  }

  String getString({required String key,String defaultValue = ''}) {
    try {
      String value = _box.get(key, defaultValue: defaultValue);
      if (isEncryptionEnabled) {
        if (value == defaultValue || value.isEmpty) return value;
        return EncryptionService().decrypt(encryptedContent: value);
      }
      return value;
    } catch (e) {
      LoggerService().log(message: e);
      return defaultValue;
    }
  }

  void setBoolean({required String key, required bool value}) {
    if (isEncryptionEnabled) {
      setString(key:key, value:value.toString());
    } else {
      _box.put(key, value);
    }
  }

  bool getBoolean({required String key,bool defaultValue = false}) {
    if (isEncryptionEnabled) {
      String temp = getString(key:key);
      return temp == 'true';
    } else {
      return _box.get(key, defaultValue: defaultValue) ?? defaultValue;
    }
  }

  void setDouble({required String key, required double value}) {
    if (isEncryptionEnabled) {
      setString(key:key, value:value.toString());
    } else {
      _box.put(key, value);
    }
  }

  double getDouble({required String key}) {
    if (isEncryptionEnabled) {
      String temp = getString(key:key);
      return double.tryParse(temp) ?? 0.0;
    } else {
      return _box.get(key, defaultValue: 0.0) ?? 0.0;
    }
  }

  void setStringList({required String key, required List<String> value}) {
    List<String> temp = [];
    if (isEncryptionEnabled) {
      for (var val in value) {
        if (val.isNotEmpty) {
          temp.add(EncryptionService().encrypt(content: val));
        } else {
          temp.add('');
        }
      }
    } else {
      temp = value;
    }
    _box.put(key, temp);
  }

  List<String> getStringList({required String key}) {
    List<String> temp =
        (_box.get(key, defaultValue: <String>[]) as List?)?.cast<String>() ??
        [];
    if (isEncryptionEnabled) {
      for (int i = 0; i < temp.length; i++) {
        if (temp[i].isNotEmpty) {
          temp[i] = EncryptionService().decrypt(encryptedContent: temp[i]);
        }
      }
    }
    return temp;
  }

  void remove({required String key}) {
    _box.delete(key);
  }
}
