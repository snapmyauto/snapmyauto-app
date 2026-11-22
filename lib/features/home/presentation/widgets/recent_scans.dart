import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/utils/l10n.dart';
import '../../../../core/widgets/severity_badge.dart';
import '../../../icon_library/presentation/widgets/light_visuals.dart';
import '../../../scan/data/scan_repository.dart';
import '../../../scan/data/scan_results.dart';
import '../../../scan/domain/scan_record.dart';
import '../../data/home_providers.dart';
import 'date_labels.dart';
import 'home_section_title.dart';

class RecentScans extends ConsumerWidget {
  const RecentScans({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final loading = ref.watch(scansProvider).isLoading;
    final scans = ref.watch(recentScansProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionTitle(
          l10n.homeRecentScans,
          actionLabel: l10n.homeSeeAll,
          onAction: () => context.go('/history'),
        ),
        const SizedBox(height: 6),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (scans.isEmpty)
          Card(
            child: ListTile(
              leading: Icon(LucideIcons.scanLine, color: colors.primary),
              title: Text(l10n.homeNoScans),
              subtitle: Text(l10n.homeNoScansBody),
            ),
          )
        else
          for (final scan in scans) _ScanRow(scan: scan),
      ],
    );
  }
}

class _ScanRow extends ConsumerWidget {
  const _ScanRow({required this.scan});

  final ScanRecord scan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final result = ref.watch(scanResultProvider(scan.id));
    final worst = result?.worstLight;
    final extra = (result?.lights.length ?? 0) - 1;
    final at = scan.createdAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: result == null
              ? null
              : () => context.push('/triage', extra: result),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (worst != null) LightIcon(light: worst, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worst?.name ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        [
                          if (at != null) agoLabel(context, at),
                          if (extra > 0) context.l10n.homeMoreLights(extra),
                        ].join(' · '),
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (result != null) SeverityChip(severity: result.severity),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
