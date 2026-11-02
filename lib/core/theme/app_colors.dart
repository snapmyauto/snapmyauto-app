import 'package:flutter/material.dart';

enum AppAccent { green, blue }

class AppColors {
  AppColors._();

  static const green = Color(0xFF0B6E5F);
  static const blue = Color(0xFF1F4FD8);

  static const bgLight = Color(0xFFF3F7F6);
  static const bgDark = Color(0xFF0A1513);

  static Color seed(AppAccent accent) =>
      accent == AppAccent.green ? green : blue;
}
