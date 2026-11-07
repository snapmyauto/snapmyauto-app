import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../domain/reminder.dart';

extension ReminderTypeUi on ReminderType {
  String get label {
    switch (this) {
      case ReminderType.service:
        return 'Service';
      case ReminderType.oilChange:
        return 'Oil change';
      case ReminderType.tyres:
        return 'Tyres';
      case ReminderType.insurance:
        return 'Insurance';
      case ReminderType.revenueLicence:
        return 'Revenue licence';
      case ReminderType.emissionTest:
        return 'Emission test';
      case ReminderType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ReminderType.service:
        return LucideIcons.wrench;
      case ReminderType.oilChange:
        return LucideIcons.droplet;
      case ReminderType.tyres:
        return LucideIcons.circleDot;
      case ReminderType.insurance:
        return LucideIcons.shieldCheck;
      case ReminderType.revenueLicence:
        return LucideIcons.fileText;
      case ReminderType.emissionTest:
        return LucideIcons.cloud;
      case ReminderType.other:
        return LucideIcons.bell;
    }
  }
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

// "today", "in 3 days", "5 days ago"
String relativeDue(DateTime due) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(due.year, due.month, due.day);
  final diff = day.difference(today).inDays;
  if (diff == 0) return 'today';
  if (diff == 1) return 'tomorrow';
  if (diff == -1) return 'yesterday';
  return diff > 0 ? 'in $diff days' : '${-diff} days ago';
}
