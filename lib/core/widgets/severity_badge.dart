import 'package:flutter/material.dart';

import '../theme/severity.dart';

class SeverityBadge extends StatelessWidget {
  const SeverityBadge({super.key, required this.severity, this.prefix = ''});

  final Severity severity;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    // surface colour reads well on the severity colour in light and dark
    final fg = Theme.of(context).colorScheme.surface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: severity.color(context),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(severity.icon, size: 13, color: fg),
          const SizedBox(width: 6),
          Text(
            '$prefix${severity.label}',
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class SeverityChip extends StatelessWidget {
  const SeverityChip({super.key, required this.severity, this.label});

  final Severity severity;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: severity.tint(context),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(severity.icon, size: 14, color: severity.color(context)),
          const SizedBox(width: 6),
          Text(
            label ?? severity.label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
