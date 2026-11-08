import 'package:flutter/widgets.dart';

import '../../../../core/utils/l10n.dart';

int _daysFromToday(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  return day.difference(today).inDays;
}

// "Today", "Tomorrow", "12 days", "Overdue"
String dueLabel(BuildContext context, DateTime due) {
  final l10n = context.l10n;
  final days = _daysFromToday(due);
  if (days < 0) return l10n.dueOverdue;
  if (days == 0) return l10n.dueToday;
  if (days == 1) return l10n.dueTomorrow;
  return l10n.dueInDays(days);
}

// "today", "yesterday", "3 days ago"
String agoLabel(BuildContext context, DateTime date) {
  final l10n = context.l10n;
  final days = -_daysFromToday(date);
  if (days <= 0) return l10n.agoToday;
  if (days == 1) return l10n.agoYesterday;
  return l10n.agoDays(days);
}
