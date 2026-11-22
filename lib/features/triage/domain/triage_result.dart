import '../../../core/theme/severity.dart';
import '../../icon_library/domain/warning_light.dart';
import 'symptom.dart';

class TriageResult {
  const TriageResult({
    required this.severity,
    required this.canDrive,
    required this.lights,
    this.symptoms = const {},
  });

  final Severity severity;
  final CanDrive canDrive;
  // worst light first
  final List<WarningLight> lights;
  final Set<Symptom> symptoms;

  WarningLight? get worstLight => lights.isEmpty ? null : lights.first;

  List<String> get steps => worstLight?.steps ?? const [];

  bool get raisedBySymptoms =>
      symptoms.any((s) => s.severity.rank > (worstLight?.severity.rank ?? -1));

  factory TriageResult.from(
    List<WarningLight> lights, {
    Set<Symptom> symptoms = const {},
  }) {
    final sorted = [...lights]
      ..sort((a, b) => b.severity.rank.compareTo(a.severity.rank));

    final all = [
      ...sorted.map((l) => l.severity),
      ...symptoms.map((s) => s.severity),
    ];
    final severity = all.isEmpty
        ? Severity.safe
        : all.reduce((a, b) => a.rank >= b.rank ? a : b);

    var canDrive = CanDrive.yes;
    for (final light in sorted) {
      canDrive = _worse(canDrive, light.canDrive);
    }
    for (final symptom in symptoms) {
      canDrive = _worse(canDrive, switch (symptom.severity) {
        Severity.stop => CanDrive.no,
        Severity.soon => CanDrive.short,
        _ => CanDrive.yes,
      });
    }

    return TriageResult(
      severity: severity,
      canDrive: canDrive,
      lights: sorted,
      symptoms: symptoms,
    );
  }

  factory TriageResult.fromLabels(
    Iterable<String> labels,
    List<WarningLight> library, {
    Set<Symptom> symptoms = const {},
  }) {
    final byId = {for (final l in library) l.id: l};
    final lights = labels.toSet().map((id) => byId[id]).nonNulls.toList();
    return TriageResult.from(lights, symptoms: symptoms);
  }
}

extension SeverityRank on Severity {
  int get rank => switch (this) {
    Severity.stop => 3,
    Severity.soon => 2,
    Severity.safe => 1,
    Severity.info => 0,
  };
}

CanDrive _worse(CanDrive a, CanDrive b) => a.index >= b.index ? a : b;
