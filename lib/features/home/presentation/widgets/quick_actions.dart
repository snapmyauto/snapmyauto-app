import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/severity_colors.dart';
import '../../../../core/utils/l10n.dart';
import 'home_section_title.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sev = context.severity;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionTitle(l10n.homeQuickActions),
        const SizedBox(height: 6),
        Row(
          children: [
            _Action(
              icon: LucideIcons.bookOpen,
              label: l10n.homeIconLibrary,
              color: colors.primary,
              tint: colors.primaryContainer,
              onTap: () => context.push('/library'),
            ),
            const SizedBox(width: 10),
            _Action(
              icon: LucideIcons.mapPin,
              label: l10n.navGarages,
              color: sev.info,
              tint: sev.infoTint,
              onTap: () => context.go('/garages'),
            ),
            const SizedBox(width: 10),
            _Action(
              icon: LucideIcons.calendar,
              label: l10n.homeReminders,
              color: colors.primary,
              tint: colors.primaryContainer,
              onTap: () => context.push('/reminders'),
            ),
            const SizedBox(width: 10),
            _Action(
              icon: LucideIcons.phone,
              label: l10n.homeSos,
              color: sev.stop,
              tint: sev.stopTint,
              onTap: () => context.push('/sos'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
