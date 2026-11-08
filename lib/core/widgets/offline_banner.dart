import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/severity_colors.dart';
import '../utils/connectivity.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(isOfflineProvider).value ?? false;
    if (!offline) return const SizedBox.shrink();

    final sev = context.severity;
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: sev.soonTint,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 6, 8, 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: sev.soon.withValues(alpha: 0.4)),
            ),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.wifiOff, size: 20, color: sev.soon),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "You're offline",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => ref.invalidate(isOfflineProvider),
                style: TextButton.styleFrom(foregroundColor: colors.onSurface),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}