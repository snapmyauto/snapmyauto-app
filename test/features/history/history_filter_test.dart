import 'package:flutter_test/flutter_test.dart';
import 'package:snapmyauto/core/theme/severity.dart';
import 'package:snapmyauto/features/history/domain/history_filter.dart';
import 'package:snapmyauto/features/icon_library/domain/warning_light.dart';
import 'package:snapmyauto/features/scan/domain/scan_record.dart';
import 'package:snapmyauto/features/triage/domain/triage_result.dart';

ScanRecord scan(String label, {String? vehicleId}) {
  return ScanRecord(
    id: label,
    vehicleId: vehicleId,
    lights: [
      ScanLight(label: label, score: 0.9, left: 0, top: 0, right: 1, bottom: 1),
    ],
  );
}

void main() {
  final now = DateTime(2026, 11, 8, 15);

  test('dates fall in the right group', () {
    expect(groupFor(DateTime(2026, 11, 8, 9), now), DateGroup.today);
    expect(groupFor(DateTime(2026, 11, 7, 22), now), DateGroup.yesterday);
    expect(groupFor(DateTime(2026, 11, 4), now), DateGroup.thisWeek);
    expect(groupFor(DateTime(2026, 10, 1), now), DateGroup.older);
    expect(groupFor(null, now), DateGroup.today);
  });

  const oil = WarningLight(
    id: 'oil_pressure',
    name: 'Oil pressure',
    severity: Severity.stop,
    category: LightCategory.engine,
    meaning: '',
    causes: [],
    steps: [],
    canDrive: CanDrive.no,
    driveNote: '',
    detectable: true,
  );
  final oilResult = TriageResult.from([oil]);

  test('filter by car, severity and search', () {
    final s = scan('oil_pressure', vehicleId: 'car1');

    expect(const HistoryFilter().matches(s, oilResult), isTrue);
    expect(
      const HistoryFilter(vehicleId: 'car2').matches(s, oilResult),
      isFalse,
    );
    expect(
      const HistoryFilter(severity: Severity.soon).matches(s, oilResult),
      isFalse,
    );
    expect(const HistoryFilter(query: 'oil').matches(s, oilResult), isTrue);
    expect(const HistoryFilter(query: 'brake').matches(s, oilResult), isFalse);
  });

  test('copyWith can clear a value', () {
    const f = HistoryFilter(vehicleId: 'car1');
    expect(f.copyWith(vehicleId: () => null).vehicleId, isNull);
    expect(f.copyWith(query: 'abs').vehicleId, 'car1');
  });
}
