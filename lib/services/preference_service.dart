import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_core_module/services/logger_service.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'encryption_service.dart';

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
      //
    }
  }

  void clearLoginCredential() {
    _box.clear();
  }

  bool contains(String key) {
    return _box.containsKey(key) ?? false;
  }

  void setInt(String key, int value) {
    if (isEncryptionEnabled) {
      setString(key, value.toString());
    } else {
      _box.put(key, value);
    }
  }

  int getInt(String key, {int defaultValue = 0}) {
    if (isEncryptionEnabled) {
      try {
        String temp = getString(key);
        return int.parse(temp);
      } catch (e) {
        return defaultValue;
      }
    } else {
      return _box.get(key, defaultValue: defaultValue) ?? defaultValue;
    }
  }

  void setString(String key, String value) {
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

  String getString(String key, {String defaultValue = ''}) {
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

  void setBoolean(String key, bool value) {
    if (isEncryptionEnabled) {
      setString(key, value.toString());
    } else {
      _box.put(key, value);
    }
  }

  bool getBoolean(String key, {bool defaultValue = false}) {
    if (isEncryptionEnabled) {
      String temp = getString(key);
      return temp == 'true';
    } else {
      return _box.get(key, defaultValue: defaultValue) ?? defaultValue;
    }
  }

  void setDouble(String key, double value) {
    if (isEncryptionEnabled) {
      setString(key, value.toString());
    } else {
      _box.put(key, value);
    }
  }

  double getDouble(String key) {
    if (isEncryptionEnabled) {
      String temp = getString(key);
      return double.tryParse(temp) ?? 0.0;
    } else {
      return _box.get(key, defaultValue: 0.0) ?? 0.0;
    }
  }

  void setStringList(String key, List<String> value) {
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

  List<String> getStringList(String key) {
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

  void remove(String key) {
    _box.delete(key);
  }
}
