import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/severity_colors.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../data/reminder_actions.dart';
import '../data/reminder_repository.dart';
import '../domain/reminder.dart';
import 'widgets/reminder_tile.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Reminder r,
  ) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: Text('"${r.title}" will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes == true) await ref.read(reminderActionsProvider).delete(r);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);
    final vehicles = ref.watch(vehiclesProvider).value ?? const [];
    final names = {for (final v in vehicles) v.id: v.displayName};
    final odometers = {for (final v in vehicles) v.id: v.odometerKm};
    final actions = ref.read(reminderActionsProvider);

    Widget tile(Reminder r) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ReminderTile(
        reminder: r,
        vehicleName: names[r.vehicleId],
        odometerKm: odometers[r.vehicleId],
        onTap: () => context.push('/reminders/${r.id}/edit'),
        onDelete: () => _confirmDelete(context, ref, r),
        onToggleDone: () =>
            r.done ? actions.markNotDone(r) : actions.markDone(r),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reminders/new'),
        icon: const Icon(LucideIcons.plus),
        label: const Text('New reminder'),
      ),
      body: reminders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _Message(
          icon: LucideIcons.wifiOff,
          title: 'Can\'t load reminders',
          text: 'Check your internet connection and try again.',
        ),
        data: (all) {
          if (all.isEmpty) {
            return const _Message(
              icon: LucideIcons.calendarClock,
              title: 'No reminders yet',
              text: 'Add your next service, licence or insurance date and we\'ll remind you.',
            );
          }
          bool late(Reminder r) => r.isOverdueAt(odometers[r.vehicleId]);
          final overdue = all.where(late).toList();
          final upcoming = all.where((r) => !r.done && !late(r)).toList();
          final done = all.where((r) => r.done).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              if (overdue.isNotEmpty) ...[
                _Header('Overdue', color: context.severity.stop),
                ...overdue.map(tile),
              ],
              if (upcoming.isNotEmpty) ...[
                const _Header('Upcoming'),
                ...upcoming.map(tile),
              ],
              if (done.isNotEmpty) ...[
                const _Header('Done'),
                ...done.map(tile),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text, {this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
