import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../reminders/data/reminder_repository.dart';
import '../../scan/data/scan_results.dart';
import '../data/vehicle_report.dart';
import '../domain/vehicle.dart';
import 'vehicle_providers.dart';

VehicleReport _reportFor(WidgetRef ref, Vehicle v) {
  final reminders = ref.read(remindersProvider).value ?? const [];
  final scans = ref.read(allVehicleScansProvider(v.id));

  return VehicleReport(
    vehicle: v,
    counts: ref.read(vehicleLightCountsProvider(v.id)),
    scans: [
      for (final s in scans)
        () {
          final result = ref.read(scanResultProvider(s.id));
          final lights = result?.lights ?? const [];
          return ReportScan(
            date: s.createdAt,
            lights: [for (final l in lights) l.name],
            worst: lights.isEmpty ? null : result!.severity,
          );
        }(),
    ],
    open: reminders.where((r) => r.vehicleId == v.id && !r.done).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
    done: ref.read(vehicleServiceLogProvider(v.id)),
  );
}

// builds the pdf and opens the share sheet, so it can be saved or sent
Future<void> exportReport(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String filename,
  required List<Vehicle> vehicles,
  String? ownerName,
  String? ownerEmail,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final bytes = await buildReportPdf(
      title: title,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      vehicles: [for (final v in vehicles) _reportFor(ref, v)],
    );
    await Printing.sharePdf(bytes: bytes, filename: filename);
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not make the PDF. Try again.')),
    );
  }
}
