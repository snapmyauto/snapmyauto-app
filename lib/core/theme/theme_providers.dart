import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/shared_prefs.dart';
import 'app_colors.dart';

class AccentNotifier extends Notifier<AppAccent> {
  static const _key = 'accent';

  @override
  AppAccent build() {
    final saved = ref.read(sharedPrefsProvider).getString(_key);
    return AppAccent.values.firstWhere(
      (a) => a.name == saved,
      orElse: () => AppAccent.green,
    );
  }

  Future<void> change(AppAccent accent) async {
    state = accent;
    await ref.read(sharedPrefsProvider).setString(_key, accent.name);
  }
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'themeMode';

  @override
  ThemeMode build() {
    final saved = ref.read(sharedPrefsProvider).getString(_key);
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> change(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPrefsProvider).setString(_key, mode.name);
  }
}

final accentProvider =
    NotifierProvider<AccentNotifier, AppAccent>(AccentNotifier.new);
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
