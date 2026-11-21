import 'package:flutter_test/flutter_test.dart';
import 'package:snapmyauto/core/theme/severity.dart';
import 'package:snapmyauto/features/reminders/domain/reminder.dart';
import 'package:snapmyauto/features/vehicles/data/vehicle_report.dart';
import 'package:snapmyauto/features/vehicles/domain/vehicle.dart';

void main() {
  test('report pdf builds for a car with data', () async {
    final bytes = await buildReportPdf(
      title: 'Test report',
      ownerName: 'Test',
      ownerEmail: 'test@example.com',
      vehicles: [
        VehicleReport(
          vehicle: const Vehicle(
            id: 'v1',
            make: 'Toyota',
            model: 'Aqua',
            year: 2015,
          ),
          counts: const {Severity.stop: 1},
          scans: [
            ReportScan(
              date: DateTime(2026, 11, 20),
              lights: const ['Oil pressure'],
              worst: Severity.stop,
            ),
          ],
          open: [
            Reminder(
              id: 'r1',
              title: 'Service',
              type: ReminderType.service,
              dueDate: DateTime(2026, 12, 1),
              dueKm: 86000,
            ),
          ],
          done: const [],
        ),
      ],
    );
    // every pdf starts with this header
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
