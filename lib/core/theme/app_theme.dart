import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'severity_colors.dart';

ThemeData buildTheme(AppAccent accent, Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final brand = AppColors.seed(accent);
  const onBrand = Colors.white;
  final card = AppColors.card(accent, brightness);
  final border = AppColors.border(accent, brightness);
  final text = AppColors.text(accent, brightness);

  final scheme =
      ColorScheme.fromSeed(
        seedColor: brand,
        brightness: brightness,
        dynamicSchemeVariant:
            DynamicSchemeVariant.fidelity, // keeps brand colour exact
      ).copyWith(
        primary: AppColors.accentText(accent, brightness),
        primaryContainer: AppColors.tile(accent, brightness),
        onPrimaryContainer: AppColors.accentText(accent, brightness),
        surfaceContainerLowest: card,
        outlineVariant: border,
        onSurface: text,
        onSurfaceVariant: AppColors.mutedText(accent, brightness),
      );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Manrope',
  );
  final radius16 = BorderRadius.circular(16);

  bool selected(Set<WidgetState> states) =>
      states.contains(WidgetState.selected);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background(accent, brightness),
    extensions: [
      isLight ? SeverityColors.light : SeverityColors.dark,
      BrandColors(fill: brand, onFill: onBrand),
    ],
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: radius16),
        backgroundColor: brand,
        foregroundColor: onBrand,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: radius16),
        side: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: brand,
      foregroundColor: onBrand,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => selected(s) ? onBrand : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => selected(s) ? brand : null,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      showCheckmark: false,
      side: WidgetStateBorderSide.resolveWith(
        (s) => selected(s) ? BorderSide.none : BorderSide(color: border),
      ),
      color: WidgetStateProperty.resolveWith((s) => selected(s) ? brand : card),
      labelStyle: TextStyle(
        color: WidgetStateColor.resolveWith(
          (s) => selected(s) ? onBrand : text,
        ),
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(
        borderRadius: radius16,
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius16,
        borderSide: BorderSide(color: border),
      ),
    ),
  );
}
