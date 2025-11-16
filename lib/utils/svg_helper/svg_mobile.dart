import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LocalImageMobile {
  static Widget load({
    required bool isSvg,
    required String url,
    double? height,
    double? width,
    Color? color,
    ColorFilter? filter,
    BoxFit? fit,
    String downloadCacheDirectory = '',
  }) {
    if (isSvg) {
      return SvgPicture.file(
        File(url),
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => SizedBox(
          width: width,
          height: height,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.error, color: Colors.red, size: height),
      );
    } else {
      return Image.file(
        File(url),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.error, color: Colors.red, size: height),
      );
    }
  }
}
