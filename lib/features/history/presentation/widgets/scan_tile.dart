import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/l10n.dart';
import '../../../../core/widgets/severity_badge.dart';
import '../../../icon_library/presentation/widgets/light_visuals.dart';
import '../../../scan/data/scan_results.dart';
import '../../../scan/domain/scan_record.dart';
import '../../../vehicles/presentation/vehicle_providers.dart';

class ScanTile extends ConsumerWidget {
  const ScanTile({super.key, required this.scan});

  final ScanRecord scan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final result = ref.watch(scanResultProvider(scan.id));
    final worst = result?.worstLight;
    final extra = (result?.lights.length ?? 0) - 1;
    final vehicleId = scan.vehicleId;
    final car = vehicleId == null
        ? null
        : ref.watch(vehicleByIdProvider(vehicleId)).value;
    final at = scan.createdAt ?? DateTime.now();
    final locale = Localizations.localeOf(context).toString();

    final details = [
      car?.displayName ?? context.l10n.historyNoCar,
      DateFormat.MMMd(locale).add_jm().format(at),
      if (extra > 0) context.l10n.homeMoreLights(extra),
    ].join(' · ');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/history/${scan.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (worst != null) ...[
                LightIcon(light: worst, size: 44),
                const SizedBox(width: 12),
              ],
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
                    const SizedBox(height: 2),
                    Text(
                      details,
                      style: TextStyle(
                        fontSize: 12,
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
    );
  }
}
