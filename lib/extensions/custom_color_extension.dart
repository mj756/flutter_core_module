import 'package:flutter/material.dart';
extension CustomString on String {

  Color hx({Color defaultColor = Colors.white}) {
    try {
      final hex = replaceAll('#', '').trim();
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      //
    }
    return defaultColor;
  }

}


