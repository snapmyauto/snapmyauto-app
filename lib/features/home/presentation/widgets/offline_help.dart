import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/severity_colors.dart';
import '../../../../core/utils/connectivity.dart';
import '../../../../core/utils/l10n.dart';

class OfflineHelp extends ConsumerWidget {
  const OfflineHelp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(isOfflineProvider).value ?? false;
    if (!offline) return const SizedBox.shrink();

    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final sev = context.severity;
    final muted = colors.onSurfaceVariant;
    final greyTile = colors.surfaceContainerHigh;

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: greyTile,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(LucideIcons.wifiOff, size: 32, color: muted),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.offlineTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.offlineBody,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.5, color: muted),
          ),
          const SizedBox(height: 18),
          _Label(l10n.offlineStillWorks, color: sev.safe),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _Row(
                  icon: LucideIcons.scanLine,
                  title: l10n.navScan,
                  subtitle: l10n.offlineScanSub,
                  color: sev.safe,
                  tint: sev.safeTint,
                  onTap: () => context.push('/scan'),
                ),
                const Divider(height: 1, indent: 64),
                _Row(
                  icon: LucideIcons.bookOpen,
                  title: l10n.homeIconLibrary,
                  color: sev.safe,
                  tint: sev.safeTint,
                  onTap: () => context.push('/library'),
                ),
                const Divider(height: 1, indent: 64),
                _Row(
                  icon: LucideIcons.phone,
                  title: l10n.offlineSos,
                  subtitle: l10n.offlineSosSub,
                  color: sev.safe,
                  tint: sev.safeTint,
                  onTap: () => context.push('/sos'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Label(l10n.offlineNeedsInternet, color: muted),
          Opacity(
            opacity: 0.6,
            child: Card(
              child: Column(
                children: [
                  _Row(
                    icon: LucideIcons.sparkles,
                    title: l10n.offlineAiChat,
                    color: muted,
                    tint: greyTile,
                  ),
                  const Divider(height: 1, indent: 64),
                  _Row(
                    icon: LucideIcons.mapPin,
                    title: l10n.offlineGarageMap,
                    color: muted,
                    tint: greyTile,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.tint,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final Color tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 19, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 13, color: muted),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(LucideIcons.chevronRight, size: 18, color: muted),
          ],
        ),
      ),
    );
  }
}
