import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core_module/utils/svg_helper/svg_web.dart'
    if (dart.library.html) 'svg_web.dart';

class LocalImageFactory {
  static Widget getInstance({
    required bool isSvg,
    required String url,
    double? height,
    double? width,
    Color? color,
    ColorFilter? filter,
    BoxFit? fit,
    String downloadCacheDirectory = '',
  }) {
    if (kIsWeb) {
      return Icon(Icons.error, color: Colors.red, size: height);
    } else {
      return LocalImageWeb.load('');
    }
  }
}
