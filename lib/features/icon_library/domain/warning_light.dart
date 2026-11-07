enum LightSeverity { stop, soon, safe, info }

enum CanDrive { yes, short, no }

class WarningLight {
  const WarningLight({
    required this.id,
    required this.name,
    required this.severity,
    required this.meaning,
    required this.action,
    required this.canDrive,
    required this.detectable,
  });

  // same as the model label, e.g. "oil_pressure"
  final String id;
  final String name;
  final LightSeverity severity;
  final String meaning;
  final String action;
  final CanDrive canDrive;
  // true when DashLight can find this light in a photo
  final bool detectable;

  factory WarningLight.fromJson(Map<String, dynamic> json) {
    return WarningLight(
      id: json['id'] as String,
      name: json['name'] as String,
      severity:
          LightSeverity.values.asNameMap()[json['severity']] ??
          LightSeverity.info,
      meaning: json['meaning'] as String? ?? '',
      action: json['action'] as String? ?? '',
      canDrive: CanDrive.values.asNameMap()[json['canDrive']] ?? CanDrive.short,
      detectable: json['detectable'] as bool? ?? false,
    );
  }

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        meaning.toLowerCase().contains(q) ||
        id.replaceAll('_', ' ').contains(q);
  }
}
