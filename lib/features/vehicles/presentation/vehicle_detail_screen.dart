import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/severity_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/card_rings.dart';
import '../../auth/data/auth_repository.dart';
import '../../history/presentation/widgets/scan_tile.dart';
import '../../home/presentation/widgets/date_labels.dart';
import '../../home/presentation/widgets/home_section_title.dart';
import '../../reminders/domain/reminder.dart';
import '../../scan/domain/scan_record.dart';
import '../../reminders/presentation/widgets/reminder_type_ui.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';
import 'vehicle_providers.dart';
import 'widgets/fuel_type_ui.dart';
import 'widgets/warnings_chart.dart';

class VehicleDetailScreen extends ConsumerWidget {
  const VehicleDetailScreen({super.key, required this.vehicleId});

  final String vehicleId;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${vehicle.displayName}?'),
        content: const Text(
          'This removes the vehicle. Old scans and reminders stay in your history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: ctx.severity.stop),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref.read(vehicleRepositoryProvider).delete(uid, vehicle.id);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleByIdProvider(vehicleId));

    return vehicleAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Could not load this vehicle.')),
      ),
      data: (vehicle) {
        if (vehicle == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This vehicle no longer exists.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              vehicle.displayName,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(LucideIcons.pencil),
                onPressed: () => context.push('/vehicles/$vehicleId/edit'),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(LucideIcons.trash2),
                onPressed: () => _delete(context, ref, vehicle),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            children: [
              _HeaderCard(vehicle: vehicle),
              const SizedBox(height: 14),
              WarningsChart(
                counts: ref.watch(vehicleLightCountsProvider(vehicleId)),
              ),
              const SizedBox(height: 14),
              _Reminders(vehicleId: vehicleId),
              const SizedBox(height: 6),
              _Tabs(vehicleId: vehicleId),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final fg = context.brand.onFill;
    final odometer = vehicle.odometerKm;
    final added = vehicle.createdAt;

    return Material(
      color: context.brand.fill,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const CardRings(size: 160, offset: 40, radii: [78, 50]),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: fg.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(vehicle.type.icon, size: 26, color: fg),
                ),
                const SizedBox(height: 12),
                Text(
                  '${vehicle.make} ${vehicle.model}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: fg,
                  ),
                ),
                if (vehicle.nickname?.isNotEmpty ?? false)
                  Text(
                    vehicle.nickname!,
                    style: TextStyle(
                      fontSize: 14,
                      color: fg.withValues(alpha: 0.75),
                    ),
                  ),
                const SizedBox(height: 14),
                _InfoRow(LucideIcons.calendar, 'Year', '${vehicle.year}'),
                _InfoRow(LucideIcons.hash, 'Plate', vehicle.plate ?? 'Not set'),
                _InfoRow(vehicle.type.icon, 'Type', vehicle.type.label),
                _InfoRow(vehicle.fuelType.icon, 'Fuel', vehicle.fuelType.label),
                _InfoRow(
                  LucideIcons.cog,
                  'Transmission',
                  vehicle.transmission.label,
                ),
                _InfoRow(
                  LucideIcons.gauge,
                  'Odometer',
                  odometer == null ? 'Not set' : formatKm(odometer),
                ),
                if (added != null)
                  _InfoRow(LucideIcons.badgeCheck, 'Added', formatDate(added)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final fg = context.brand.onFill;
    final soft = fg.withValues(alpha: 0.75);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: soft),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 14, color: soft)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// scans, service log and documents, one at a time
class _Tabs extends ConsumerStatefulWidget {
  const _Tabs({required this.vehicleId});

  final String vehicleId;

  @override
  ConsumerState<_Tabs> createState() => _TabsState();
}

class _TabsState extends ConsumerState<_Tabs> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final id = widget.vehicleId;

    final List<Widget> content = switch (_tab) {
      0 => _scans(ref.watch(allVehicleScansProvider(id))),
      1 => _log(ref.watch(vehicleServiceLogProvider(id))),
      _ => _documents(ref.watch(vehicleDocumentsProvider(id))),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 0, label: Text('Scans')),
            ButtonSegment(value: 1, label: Text('Service log')),
            ButtonSegment(value: 2, label: Text('Documents')),
          ],
          selected: {_tab},
          onSelectionChanged: (s) => setState(() => _tab = s.first),
        ),
        const SizedBox(height: 12),
        ...content,
      ],
    );
  }

  List<Widget> _scans(List<ScanRecord> scans) {
    if (scans.isEmpty) {
      return [const _EmptyNote('No scans saved for this car yet.')];
    }
    return [
      for (final scan in scans)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ScanTile(scan: scan),
        ),
    ];
  }

  List<Widget> _log(List<Reminder> done) {
    if (done.isEmpty) {
      return [
        const _EmptyNote(
          'Nothing here yet. Reminders you tick off show up as your service log.',
        ),
      ];
    }
    return [for (final r in done) _ReminderRow(reminder: r)];
  }

  List<Widget> _documents(List<Reminder> docs) {
    if (docs.isEmpty) {
      return [
        const _EmptyNote(
          'Add insurance, revenue licence or emission test reminders '
          'to track their expiry here.',
        ),
      ];
    }
    return [for (final r in docs) _ReminderRow(reminder: r)];
  }
}

class _Reminders extends ConsumerWidget {
  const _Reminders({required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(vehicleRemindersProvider(vehicleId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionTitle('Reminders'),
        const SizedBox(height: 6),
        if (reminders.isEmpty) const _EmptyNote('No reminders for this car.'),
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
    final done = reminder.done;
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
                    done ? 'Done' : dueLabel(context, reminder.dueDate),
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
