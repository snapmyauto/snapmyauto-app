import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/severity_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/reminder.dart';
import 'reminder_type_ui.dart';

class ReminderTile extends StatelessWidget {
  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggleDone,
    required this.onTap,
    required this.onDelete,
    this.vehicleName,
    this.odometerKm,
  });

  final Reminder reminder;
  final String? vehicleName;
  // the linked car's odometer, for mileage reminders
  final int? odometerKm;
  final VoidCallback onToggleDone;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sev = context.severity;
    final kmLeft = reminder.kmLeft(odometerKm);
    final overdue = reminder.isOverdueAt(odometerKm);
    final done = reminder.done;

    final accent = overdue ? sev.stop : colors.primary;
    final details = [
      done
          ? 'Done'
          : '${overdue ? 'Overdue' : 'Due'} ${relativeDue(reminder.dueDate)} '
                '· ${shortDate(reminder.dueDate)}',
      ?vehicleName,
      if (reminder.dueKm != null)
        kmLeft == null || kmLeft <= 0
            ? 'at ${formatKm(reminder.dueKm!)}'
            : 'or in ${formatKm(kmLeft)}',
      if (reminder.repeatMonths != null)
        'every ${reminder.repeatMonths} months',
    ].join(' · ');

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: overdue ? sev.stopTint : colors.surfaceContainerHighest,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.only(left: 4, right: 4),
        leading: Checkbox(value: done, onChanged: (_) => onToggleDone()),
        title: Row(
          children: [
            Icon(reminder.type.icon, size: 16, color: accent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                reminder.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(details, style: TextStyle(color: overdue ? sev.stop : null)),
            if (reminder.isRenewal && !done)
              TextButton.icon(
                onPressed: onToggleDone,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(LucideIcons.badgeCheck, size: 16),
                label: const Text('Mark as renewed'),
              ),
          ],
        ),
        trailing: IconButton(
          tooltip: 'Delete',
          icon: const Icon(LucideIcons.trash2, size: 20),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
