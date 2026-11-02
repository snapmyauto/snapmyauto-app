import 'package:flutter/material.dart';

enum AppAccent { green, blue }

class AppColors {
  AppColors._();

  static const green = Color(0xFF0B6E5F);
  static const blue = Color(0xFF1F4FD8);

  static Color seed(AppAccent accent) =>
      accent == AppAccent.green ? green : blue;

  // page background, lightly tinted to match the accent
  static Color background(AppAccent accent, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    if (accent == AppAccent.green) {
      return isLight ? const Color(0xFFF3F7F6) : const Color(0xFF0A1513);
    }
    return isLight ? const Color(0xFFF3F5FB) : const Color(0xFF0A0F1C);
  }
}
