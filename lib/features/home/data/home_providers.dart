import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/severity.dart';
import '../../../core/utils/shared_prefs.dart';
import '../../reminders/data/reminder_repository.dart';
import '../../reminders/domain/reminder.dart';
import '../../scan/data/scan_repository.dart';
import '../../scan/data/scan_results.dart';
import '../../scan/domain/scan_record.dart';
import '../../triage/domain/triage_result.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../../vehicles/domain/vehicle.dart';

class SelectedVehicleNotifier extends Notifier<String?> {
  static const _key = 'selectedVehicle';

  @override
  String? build() => ref.read(sharedPrefsProvider).getString(_key);

  Future<void> select(String id) async {
    state = id;
    await ref.read(sharedPrefsProvider).setString(_key, id);
  }
}

final selectedVehicleIdProvider =
    NotifierProvider<SelectedVehicleNotifier, String?>(
      SelectedVehicleNotifier.new,
    );

// the car shown on home, falls back to the first car
final homeVehicleProvider = Provider<Vehicle?>((ref) {
  final vehicles = ref.watch(vehiclesProvider).value ?? const [];
  final id = ref.watch(selectedVehicleIdProvider);
  for (final v in vehicles) {
    if (v.id == id) return v;
  }
  return vehicles.isEmpty ? null : vehicles.first;
});

final upcomingRemindersProvider = Provider<List<Reminder>>((ref) {
  final reminders = ref.watch(remindersProvider).value ?? const [];
  final open = reminders.where((r) => !r.done).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return open.take(3).toList();
});

final recentScansProvider = Provider<List<ScanRecord>>((ref) {
  final scans = ref.watch(scansProvider).value ?? const [];
  return scans.take(3).toList();
});

// newest scan from the last 7 days that needs attention
final latestWarningProvider = Provider<(ScanRecord, TriageResult)?>((ref) {
  final scans = ref.watch(scansProvider).value ?? const [];
  final weekAgo = DateTime.now().subtract(const Duration(days: 7));
  for (final scan in scans) {
    final at = scan.createdAt;
    if (at != null && at.isBefore(weekAgo)) break;
    final result = ref.watch(scanResultProvider(scan.id));
    if (result == null) continue;
    if (result.severity == Severity.stop || result.severity == Severity.soon) {
      return (scan, result);
    }
  }
  return null;
});

// next open reminder of one type for the home car
final nextReminderProvider = Provider.family<Reminder?, ReminderType>((
  ref,
  type,
) {
  final car = ref.watch(homeVehicleProvider);
  final reminders = ref.watch(remindersProvider).value ?? const [];
  final matches =
      reminders
          .where((r) => !r.done && r.type == type && r.vehicleId == car?.id)
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return matches.isEmpty ? null : matches.first;
});
