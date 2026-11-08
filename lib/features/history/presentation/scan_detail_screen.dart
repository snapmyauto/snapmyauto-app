import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/severity_colors.dart';
import '../../../core/utils/l10n.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/severity_badge.dart';
import '../../../core/widgets/state_views.dart';
import '../../ai_chat/domain/chat_context.dart';
import '../../auth/data/auth_repository.dart';
import '../../icon_library/data/warning_light_repository.dart';
import '../../icon_library/presentation/widgets/light_visuals.dart';
import '../../scan/data/scan_repository.dart';
import '../../scan/data/scan_results.dart';
import '../../scan/domain/scan_record.dart';
import '../../vehicles/presentation/vehicle_providers.dart';

class ScanDetailScreen extends ConsumerWidget {
  const ScanDetailScreen({super.key, required this.scanId});

  final String scanId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.scanDetailDeleteTitle),
        content: Text(l10n.scanDetailDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              backgroundColor: ctx.severity.stop,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.historyDelete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    context.pop();
    await ref.read(scanRepositoryProvider).delete(uid, scanId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scan = ref.watch(scanProvider(scanId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.scanDetailTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (scan.value != null)
            IconButton(
              tooltip: l10n.historyDelete,
              icon: const Icon(LucideIcons.trash2),
              onPressed: () => _delete(context, ref),
            ),
        ],
      ),
      body: scan.when(
        loading: () => const LoadingState(),
        error: (_, _) =>
            ErrorState(onRetry: () => ref.invalidate(scanProvider(scanId))),
        data: (scan) => scan == null
            ? EmptyState(
                icon: LucideIcons.searchX,
                title: l10n.scanDetailGone,
                message: '',
              )
            : _Details(scan: scan),
      ),
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.scan});

  final ScanRecord scan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final result = ref.watch(scanResultProvider(scan.id));
    final library = ref.watch(warningLightsProvider).value ?? const [];
    final byId = {for (final l in library) l.id: l};
    final vehicleId = scan.vehicleId;
    final car = vehicleId == null
        ? null
        : ref.watch(vehicleByIdProvider(vehicleId)).value;
    final locale = Localizations.localeOf(context).toString();
    final at = scan.createdAt ?? DateTime.now();

    final info = [
      DateFormat.yMMMd(locale).add_jm().format(at),
      car?.displayName ?? l10n.historyNoCar,
      scan.source == ScanSource.camera ? l10n.sourceCamera : l10n.sourceGallery,
    ].join(' · ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
      children: [
        if (result != null) SeverityBadge(severity: result.severity),
        const SizedBox(height: 10),
        Text(
          result?.worstLight?.name ?? '',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          info,
          style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 22),
        Text(
          l10n.scanDetailLights,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        for (final light in scan.lights)
          if (byId[light.label] case final info?)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  leading: LightIcon(light: info, size: 44),
                  title: Text(
                    info.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    l10n.scanDetailSure((light.score * 100).round()),
                  ),
                  trailing: SeverityChip(severity: info.severity),
                  onTap: () => context.push('/library/${info.id}'),
                ),
              ),
            ),
        const SizedBox(height: 14),
        if (result != null) ...[
          PrimaryButton(
            label: l10n.scanDetailAdvice,
            icon: LucideIcons.clipboardList,
            onPressed: () => context.push('/triage', extra: result),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: l10n.scanDetailAskAi,
            icon: LucideIcons.sparkles,
            onPressed: () => context.push(
              '/chat',
              extra: ChatContext(triage: result, vehicleId: scan.vehicleId),
            ),
          ),
        ],
      ],
    );
  }
}
