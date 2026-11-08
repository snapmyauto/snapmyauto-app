import 'package:flutter/material.dart';

enum AppAccent { green, blue }

class AppColors {
  AppColors._();

  static const green = Color(0xFF0B6E5F);
  static const blue = Color(0xFF1F4FD8);

  static Color seed(AppAccent accent) =>
      accent == AppAccent.green ? green : blue;

  static Color _pick(
    AppAccent accent,
    Brightness brightness, {
    required int greenLight,
    required int greenDark,
    required int blueLight,
    required int blueDark,
  }) {
    final isLight = brightness == Brightness.light;
    if (accent == AppAccent.green) {
      return Color(isLight ? greenLight : greenDark);
    }
    return Color(isLight ? blueLight : blueDark);
  }

  // page background, lightly tinted to match the accent
  static Color background(AppAccent accent, Brightness brightness) => _pick(
    accent,
    brightness,
    greenLight: 0xFFF3F7F6,
    greenDark: 0xFF0A1513,
    blueLight: 0xFFF3F5FB,
    blueDark: 0xFF0A0F1C,
  );

  // a calmer blue in dark mode, the bright one glares on a dark page
  static Color fill(AppAccent accent, Brightness brightness) => _pick(
    accent,
    brightness,
    greenLight: 0xFF0B6E5F,
    greenDark: 0xFF0B6E5F,
    blueLight: 0xFF1F4FD8,
    blueDark: 0xFF2A4A9E,
  );

  static Color card(AppAccent accent, Brightness brightness) => _pick(
    accent,
    brightness,
    greenLight: 0xFFFFFFFF,
    greenDark: 0xFF12211D,
    blueLight: 0xFFFFFFFF,
    blueDark: 0xFF121A2B,
  );

  static Color border(AppAccent accent, Brightness brightness) => _pick(
    accent,
    brightness,
    greenLight: 0xFFDDE7E4,
    greenDark: 0xFF1F3530,
    blueLight: 0xFFDDE3F0,
    blueDark: 0xFF1F2A44,
  );

  static Color tile(AppAccent accent, Brightness brightness) => _pick(
    accent,
    brightness,
    greenLight: 0xFFDDF1EC,
    greenDark: 0xFF143A32,
    blueLight: 0xFFDFE7FB,
    blueDark: 0xFF15244A,
  );

  static Color accentText(AppAccent accent, Brightness brightness) => _pick(
    accent,
    brightness,
    greenLight: 0xFF0B6E5F,
    greenDark: 0xFF6FD3B8,
    blueLight: 0xFF1F4FD8,
    blueDark: 0xFF9DB7FF,
  );

  static Color text(AppAccent accent, Brightness brightness) => _pick(
    accent,
    brightness,
    greenLight: 0xFF0E1F1B,
    greenDark: 0xFFE4F0EC,
    blueLight: 0xFF0E1626,
    blueDark: 0xFFE4E9F5,
  );

  static Color mutedText(AppAccent accent, Brightness brightness) => _pick(
    accent,
    brightness,
    greenLight: 0xFF46605A,
    greenDark: 0xFF93ABA4,
    blueLight: 0xFF4A5672,
    blueDark: 0xFF96A2BE,
  );
}

class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({required this.fill, required this.onFill});

  final Color fill;
  final Color onFill;

  @override
  BrandColors copyWith({Color? fill, Color? onFill}) =>
      BrandColors(fill: fill ?? this.fill, onFill: onFill ?? this.onFill);

  @override
  BrandColors lerp(BrandColors? other, double t) {
    if (other == null) return this;
    return BrandColors(
      fill: Color.lerp(fill, other.fill, t)!,
      onFill: Color.lerp(onFill, other.onFill, t)!,
    );
  }
}

extension BrandContext on BuildContext {
  BrandColors get brand => Theme.of(this).extension<BrandColors>()!;
}
