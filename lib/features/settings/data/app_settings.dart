import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/shared_prefs.dart';
import '../../reminders/data/reminder_notifications.dart';
import '../../reminders/data/reminder_repository.dart';

enum DistanceUnit { km, miles }

extension DistanceUnitFormat on DistanceUnit {
  // distances are saved in km, this only changes how they look
  String format(int km) => switch (this) {
    DistanceUnit.km => '${formatNumber(km)} km',
    DistanceUnit.miles => '${formatNumber((km * 0.621371).round())} mi',
  };
}

class DistanceUnitNotifier extends Notifier<DistanceUnit> {
  static const _key = 'distanceUnit';

  @override
  DistanceUnit build() {
    final saved = ref.read(sharedPrefsProvider).getString(_key);
    return DistanceUnit.values.asNameMap()[saved] ?? DistanceUnit.km;
  }

  Future<void> change(DistanceUnit unit) async {
    state = unit;
    await ref.read(sharedPrefsProvider).setString(_key, unit.name);
  }
}

final distanceUnitProvider =
    NotifierProvider<DistanceUnitNotifier, DistanceUnit>(
      DistanceUnitNotifier.new,
    );

class ReminderAlertsNotifier extends Notifier<bool> {
  static const _key = 'reminderAlerts';

  @override
  bool build() => ref.read(sharedPrefsProvider).getBool(_key) ?? true;

  Future<void> change(bool on) async {
    state = on;
    await ref.read(sharedPrefsProvider).setBool(_key, on);

    final notes = ref.read(reminderNotificationsProvider);
    if (!on) {
      await notes.cancelAll();
      return;
    }
    await notes.askPermission();
    final reminders = ref.read(remindersProvider).value ?? const [];
    for (final r in reminders.where((r) => !r.done)) {
      await notes.schedule(r);
    }
  }
}

// null follows the phone language
class AppLocaleNotifier extends Notifier<Locale?> {
  static const _key = 'language';
  static const supported = ['en', 'si', 'ta'];

  @override
  Locale? build() {
    final saved = ref.read(sharedPrefsProvider).getString(_key);
    return supported.contains(saved) ? Locale(saved!) : null;
  }

  Future<void> change(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPrefsProvider);
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale?>(
  AppLocaleNotifier.new,
);

final reminderAlertsProvider = NotifierProvider<ReminderAlertsNotifier, bool>(
  ReminderAlertsNotifier.new,
);

class ReadResultsNotifier extends Notifier<bool> {
  static const _key = 'readResults';

  @override
  bool build() => ref.read(sharedPrefsProvider).getBool(_key) ?? false;

  Future<void> change(bool on) async {
    state = on;
    await ref.read(sharedPrefsProvider).setBool(_key, on);
  }
}

final readResultsProvider = NotifierProvider<ReadResultsNotifier, bool>(
  ReadResultsNotifier.new,
);
