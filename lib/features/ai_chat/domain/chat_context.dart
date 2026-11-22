import '../../../core/theme/severity.dart';
import '../../triage/domain/triage_result.dart';
import '../../vehicles/domain/vehicle.dart';

class ChatContext {
  const ChatContext({this.triage, this.vehicleId});

  final TriageResult? triage;
  final String? vehicleId;

  bool get hasScan => triage?.worstLight != null;

  // the facts the assistant is allowed to use, sent with the system prompt
  String describe(Vehicle? vehicle) {
    final lines = <String>[];
    final triage = this.triage;

    if (vehicle != null) {
      lines.add(
        'Vehicle: ${vehicle.year} ${vehicle.make} ${vehicle.model}, '
        '${vehicle.type.name}, ${vehicle.fuelType.name}, '
        '${vehicle.transmission.name}.',
      );
    }
    if (triage != null && triage.lights.isNotEmpty) {
      lines.add('Overall result: ${triage.severity.label}.');
      lines.add('Can keep driving: ${triage.canDrive.name}.');
      for (final light in triage.lights) {
        lines.add(
          'Light on: ${light.name} (${light.severity.label}). ${light.meaning}',
        );
      }
    }
    for (final symptom in triage?.symptoms ?? const {}) {
      lines.add('Driver noticed: ${symptom.label}.');
    }

    if (lines.isEmpty) return 'No scan or vehicle was shared.';
    return lines.join('\n');
  }

  List<String> suggestions() {
    final light = triage?.worstLight;
    if (light == null) {
      return const [
        'What does a flashing light mean?',
        'How often should I service my car?',
      ];
    }
    return [
      'Can I keep driving?',
      'What causes the ${light.name.toLowerCase()} light?',
      'How much will it cost to fix?',
    ];
  }
}
