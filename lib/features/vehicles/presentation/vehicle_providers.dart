import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/severity.dart';

import '../../reminders/data/reminder_repository.dart';
import '../../reminders/domain/reminder.dart';
import '../../scan/data/scan_repository.dart';
import '../../scan/data/scan_results.dart';
import '../../scan/domain/scan_record.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';

/// One vehicle from the live list. Null when it was deleted.
final vehicleByIdProvider = Provider.family<AsyncValue<Vehicle?>, String>((
  ref,
  id,
) {
  return ref.watch(vehiclesProvider).whenData((list) {
    for (final v in list) {
      if (v.id == id) return v;
    }
    return null;
  });
});

/// Open reminders for a vehicle, soonest first.
final vehicleRemindersProvider = Provider.family<List<Reminder>, String>((
  ref,
  id,
) {
  final reminders = ref.watch(remindersProvider).value ?? const [];
  return reminders.where((r) => r.vehicleId == id && !r.done).toList();
});

/// Every scan for a vehicle, newest first.
final allVehicleScansProvider = Provider.family<List<ScanRecord>, String>((
  ref,
  id,
) {
  final scans = ref.watch(scansProvider).value ?? const [];
  return scans.where((s) => s.vehicleId == id).toList();
});

/// Lights seen on a vehicle, counted by severity. Safe counts as info.
final vehicleLightCountsProvider = Provider.family<Map<Severity, int>, String>((
  ref,
  id,
) {
  final counts = <Severity, int>{};
  for (final scan in ref.watch(allVehicleScansProvider(id))) {
    final result = ref.watch(scanResultProvider(scan.id));
    for (final light in result?.lights ?? const []) {
      final s = light.severity == Severity.safe
          ? Severity.info
          : light.severity;
      counts[s] = (counts[s] ?? 0) + 1;
    }
  }
  return counts;
});

/// Finished reminders for a vehicle, newest first.
final vehicleServiceLogProvider = Provider.family<List<Reminder>, String>((
  ref,
  id,
) {
  final reminders = ref.watch(remindersProvider).value ?? const [];
  return reminders.where((r) => r.vehicleId == id && r.done).toList()
    ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
});

/// Latest insurance, licence and emission reminder for a vehicle.
final vehicleDocumentsProvider = Provider.family<List<Reminder>, String>((
  ref,
  id,
) {
  final reminders = ref.watch(remindersProvider).value ?? const [];
  final latest = <ReminderType, Reminder>{};
  for (final r in reminders.where((r) => r.vehicleId == id && r.isRenewal)) {
    final kept = latest[r.type];
    // an open one beats a done one, then the later date wins
    final better =
        kept == null ||
        (kept.done && !r.done) ||
        (kept.done == r.done && r.dueDate.isAfter(kept.dueDate));
    if (better) latest[r.type] = r;
  }
  return latest.values.toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
});
