enum LightSeverity { stop, soon, safe, info }

enum CanDrive { yes, short, no }

enum LightCategory { engine, brakes, safety, lights }

class WarningLight {
  const WarningLight({
    required this.id,
    required this.name,
    required this.severity,
    required this.category,
    required this.meaning,
    required this.causes,
    required this.steps,
    required this.canDrive,
    required this.driveNote,
    required this.detectable,
  });

  // same as the model label, e.g. "oil_pressure"
  final String id;
  final String name;
  final LightSeverity severity;
  final LightCategory category;
  final String meaning;
  final List<String> causes;
  final List<String> steps;
  final CanDrive canDrive;
  // one short line under "can I keep driving?"
  final String driveNote;
  // true when dashlight can find this light in a photo
  final bool detectable;

  factory WarningLight.fromJson(Map<String, dynamic> json) {
    List<String> strings(String key) =>
        (json[key] as List<dynamic>? ?? []).cast<String>();

    return WarningLight(
      id: json['id'] as String,
      name: json['name'] as String,
      severity:
          LightSeverity.values.asNameMap()[json['severity']] ??
          LightSeverity.info,
      category:
          LightCategory.values.asNameMap()[json['category']] ??
          LightCategory.safety,
      meaning: json['meaning'] as String? ?? '',
      causes: strings('causes'),
      steps: strings('steps'),
      canDrive: CanDrive.values.asNameMap()[json['canDrive']] ?? CanDrive.short,
      driveNote: json['driveNote'] as String? ?? '',
      detectable: json['detectable'] as bool? ?? false,
    );
  }

  // all steps as one sentence, handy for short texts like triage
  String get action => steps.join('. ');

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        meaning.toLowerCase().contains(q) ||
        id.replaceAll('_', ' ').contains(q);
  }
}
