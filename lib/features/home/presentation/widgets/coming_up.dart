import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/severity_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/l10n.dart';
import '../../../reminders/data/reminder_repository.dart';
import '../../../reminders/domain/reminder.dart';
import '../../../reminders/presentation/widgets/reminder_type_ui.dart';
import '../../data/home_providers.dart';
import 'date_labels.dart';
import 'home_section_title.dart';

class ComingUp extends ConsumerWidget {
  const ComingUp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final loading = ref.watch(remindersProvider).isLoading;
    final reminders = ref.watch(upcomingRemindersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionTitle(
          l10n.homeComingUp,
          actionLabel: l10n.homeSeeAll,
          onAction: () => context.push('/reminders'),
        ),
        const SizedBox(height: 6),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (reminders.isEmpty)
          _EmptyRow(
            text: l10n.homeNoReminders,
            action: l10n.homeAddReminder,
            onTap: () => context.push('/reminders/new'),
          )
        else
          for (final r in reminders) _ReminderRow(reminder: r),
      ],
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final overdue = reminder.isOverdue;
    final color = overdue ? context.severity.stop : colors.primary;
    final tint = overdue ? context.severity.stopTint : colors.primaryContainer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/reminders/${reminder.id}/edit'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(reminder.type.icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        formatDate(reminder.dueDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    dueLabel(context, reminder.dueDate),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
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

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({
    required this.text,
    required this.action,
    required this.onTap,
  });

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onTap,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}
