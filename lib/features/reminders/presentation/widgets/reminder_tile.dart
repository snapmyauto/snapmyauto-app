import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/severity_colors.dart';
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
  });

  final Reminder reminder;
  final String? vehicleName;
  final VoidCallback onToggleDone;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sev = context.severity;
    final overdue = reminder.isOverdue;
    final done = reminder.done;

    final accent = overdue ? sev.stop : colors.primary;
    final details = [
      done
          ? 'Done'
          : '${overdue ? 'Overdue' : 'Due'} ${relativeDue(reminder.dueDate)} '
                '· ${shortDate(reminder.dueDate)}',
      ?vehicleName,
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
        subtitle: Text(
          details,
          style: TextStyle(color: overdue ? sev.stop : null),
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
