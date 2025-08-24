import 'package:flutter/material.dart';
import 'package:flutter_core_module/enums.dart';

class SizeConfig {
  factory SizeConfig() => _instance;
  SizeConfig._internal();
  static final SizeConfig _instance = SizeConfig._internal();

  double width = 0;
  double height = 0;
  late double blockSizeHorizontal;
  late double blockSizeVertical;

  late DeviceType deviceType;
  late double textScaleFactor;

  void init({required BuildContext context}) {
    final mediaQuery = MediaQuery.of(context);
    width = mediaQuery.size.width;
    height = mediaQuery.size.height;

    if (width < 600) {
      deviceType = DeviceType.mobile;
    } else if (width < 1200) {
      deviceType = DeviceType.tablet;
    } else {
      deviceType = DeviceType.desktop;
    }

    blockSizeHorizontal = width / 100;
    blockSizeVertical = height / 100;
    textScaleFactor = mediaQuery.textScaler.scale(1.0);
  }
}

extension SizeExtension on num {
  double get w => this * SizeConfig().blockSizeHorizontal;
  double get h => this * SizeConfig().blockSizeVertical;
  double get sp =>
      (this * SizeConfig().blockSizeHorizontal) / SizeConfig().textScaleFactor;
}
