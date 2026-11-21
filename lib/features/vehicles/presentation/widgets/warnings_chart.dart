import 'package:flutter/material.dart';

import '../../../../core/theme/severity.dart';

// how many lights of each severity this car has shown, as simple bars
class WarningsChart extends StatelessWidget {
  const WarningsChart({super.key, required this.counts});

  final Map<Severity, int> counts;

  static const _order = [Severity.stop, Severity.soon, Severity.info];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total = counts.values.fold(0, (a, b) => a + b);
    final most = _order
        .map((s) => counts[s] ?? 0)
        .fold(0, (a, b) => a > b ? a : b);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warnings by severity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              total == 0
                  ? 'No warning lights found yet.'
                  : '$total ${total == 1 ? 'light' : 'lights'} across all scans',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            for (final s in _order)
              _Bar(
                severity: s,
                count: counts[s] ?? 0,
                share: most == 0 ? 0 : (counts[s] ?? 0) / most,
              ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.severity,
    required this.count,
    required this.share,
  });

  final Severity severity;
  final int count;
  final double share;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final mark = severity.color(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        label: '${severity.label}: $count',
        child: Row(
          children: [
            // icon and label carry the meaning, not the colour alone
            Icon(severity.icon, size: 16, color: mark),
            const SizedBox(width: 6),
            SizedBox(
              width: 92,
              child: Text(
                severity.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 12,
                      // a zero count still shows a sliver of track
                      width: count == 0 ? 4 : box.maxWidth * share,
                      decoration: BoxDecoration(
                        color: count == 0 ? colors.outlineVariant : mark,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(4),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 28,
              child: Text(
                '$count',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
