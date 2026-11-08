import 'package:flutter_test/flutter_test.dart';
import 'package:snapmyauto/core/theme/severity.dart';
import 'package:snapmyauto/features/ai_chat/domain/chat_context.dart';
import 'package:snapmyauto/features/icon_library/domain/warning_light.dart';
import 'package:snapmyauto/features/triage/domain/symptom.dart';
import 'package:snapmyauto/features/triage/domain/triage_result.dart';
import 'package:snapmyauto/features/vehicles/domain/vehicle.dart';

void main() {
  const oil = WarningLight(
    id: 'oil_pressure',
    name: 'Oil pressure',
    severity: Severity.stop,
    category: LightCategory.engine,
    meaning: 'Engine oil pressure is too low.',
    causes: [],
    steps: [],
    canDrive: CanDrive.no,
    driveNote: '',
    detectable: true,
  );
  const aqua = Vehicle(id: 'v1', make: 'Toyota', model: 'Aqua', year: 2015);

  test('facts include the lights, symptoms and car', () {
    final chat = ChatContext(
      triage: TriageResult.from([oil], symptoms: {Symptom.smoke}),
    );
    final facts = chat.describe(aqua);

    expect(facts, contains('2015 Toyota Aqua'));
    expect(facts, contains('Overall result: Stop now.'));
    expect(facts, contains('Light on: Oil pressure (Stop now)'));
    expect(facts, contains('Driver noticed: Smoke from the engine.'));
  });

  test('no scan and no car says so', () {
    expect(
      const ChatContext().describe(null),
      'No scan or vehicle was shared.',
    );
  });

  test('suggestions use the worst light', () {
    final chat = ChatContext(triage: TriageResult.from([oil]));
    expect(chat.suggestions(), contains('What causes the oil pressure light?'));
  });
}
