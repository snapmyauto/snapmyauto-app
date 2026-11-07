import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reminders/data/reminder_repository.dart';
import '../../reminders/domain/reminder.dart';
import '../../scan/data/scan_repository.dart';
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

/// Latest 5 scans saved for a vehicle.
final vehicleScansProvider = Provider.family<List<ScanRecord>, String>((
  ref,
  id,
) {
  final scans = ref.watch(scansProvider).value ?? const [];
  return scans.where((s) => s.vehicleId == id).take(5).toList();
});

/// Open reminders for a vehicle, soonest first.
final vehicleRemindersProvider = Provider.family<List<Reminder>, String>((
  ref,
  id,
) {
  final reminders = ref.watch(remindersProvider).value ?? const [];
  return reminders.where((r) => r.vehicleId == id && !r.done).toList();
});
