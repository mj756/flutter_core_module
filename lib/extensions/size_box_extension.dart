import 'package:flutter/material.dart';

extension SizedBoxExtension on num {
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());
  SizedBox get hw => SizedBox(height: toDouble(),width: toDouble());
}