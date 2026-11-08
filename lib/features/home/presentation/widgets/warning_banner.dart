import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/severity.dart';
import '../../../../core/utils/l10n.dart';
import '../../data/home_providers.dart';
import 'date_labels.dart';

class WarningBanner extends ConsumerWidget {
  const WarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warning = ref.watch(latestWarningProvider);
    if (warning == null) return const SizedBox.shrink();

    final (scan, result) = warning;
    final severity = result.severity;
    final colors = Theme.of(context).colorScheme;
    final at = scan.createdAt;
    final when = at == null ? context.l10n.agoToday : agoLabel(context, at);

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Material(
        color: severity.tint(context),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => context.push('/home/triage', extra: result),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: severity.color(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(severity.icon, color: colors.surface),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.worstLight?.name ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${severity.label} · '
                        '${context.l10n.homeWarningScanned(when)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  context.l10n.homeView,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
