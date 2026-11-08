import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'severity_colors.dart';

enum Severity { stop, soon, safe, info }

extension SeverityStyle on Severity {
  String get label => switch (this) {
    Severity.stop => 'Stop now',
    Severity.soon => 'Garage soon',
    Severity.safe => 'Safe',
    Severity.info => 'Info',
  };

  IconData get icon => switch (this) {
    Severity.stop => LucideIcons.octagonX,
    Severity.soon => LucideIcons.triangleAlert,
    Severity.safe => LucideIcons.circleCheck,
    Severity.info => LucideIcons.info,
  };

  Color color(BuildContext context) {
    final s = context.severity;
    return switch (this) {
      Severity.stop => s.stop,
      Severity.soon => s.soon,
      Severity.safe => s.safe,
      Severity.info => s.info,
    };
  }

  Color tint(BuildContext context) {
    final s = context.severity;
    return switch (this) {
      Severity.stop => s.stopTint,
      Severity.soon => s.soonTint,
      Severity.safe => s.safeTint,
      Severity.info => s.infoTint,
    };
  }
}
