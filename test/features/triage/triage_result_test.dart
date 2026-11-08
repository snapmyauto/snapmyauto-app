import 'package:flutter_test/flutter_test.dart';
import 'package:snapmyauto/core/theme/severity.dart';
import 'package:snapmyauto/features/icon_library/domain/warning_light.dart';
import 'package:snapmyauto/features/triage/domain/symptom.dart';
import 'package:snapmyauto/features/triage/domain/triage_result.dart';

WarningLight light(String id, Severity severity, CanDrive canDrive) {
  return WarningLight(
    id: id,
    name: id,
    severity: severity,
    category: LightCategory.engine,
    meaning: '',
    causes: const [],
    steps: ['step for $id'],
    canDrive: canDrive,
    driveNote: '',
    detectable: true,
  );
}

void main() {
  final oil = light('oil_pressure', Severity.stop, CanDrive.no);
  final engine = light('check_engine', Severity.soon, CanDrive.short);
  final fog = light('fog_light', Severity.safe, CanDrive.yes);
  final library = [oil, engine, fog];

  test('worst light decides the result', () {
    final result = TriageResult.from([fog, engine, oil]);

    expect(result.severity, Severity.stop);
    expect(result.canDrive, CanDrive.no);
    expect(result.worstLight, oil);
    expect(result.steps, ['step for oil_pressure']);
  });

  test('symptoms can raise the result', () {
    final result = TriageResult.from([fog], symptoms: {Symptom.smoke});

    expect(result.severity, Severity.stop);
    expect(result.canDrive, CanDrive.no);
    expect(result.raisedBySymptoms, isTrue);
  });

  test('mild symptoms do not lower a worse light', () {
    final result = TriageResult.from([oil], symptoms: {Symptom.strangeNoise});

    expect(result.severity, Severity.stop);
    expect(result.raisedBySymptoms, isFalse);
  });

  test('labels are looked up, repeats and unknown labels skipped', () {
    final result = TriageResult.fromLabels([
      'check_engine',
      'check_engine',
      'not_a_light',
    ], library);

    expect(result.lights, [engine]);
    expect(result.severity, Severity.soon);
    expect(result.canDrive, CanDrive.short);
  });

  test('nothing found is safe', () {
    final result = TriageResult.from([]);

    expect(result.severity, Severity.safe);
    expect(result.canDrive, CanDrive.yes);
    expect(result.worstLight, isNull);
  });
}
