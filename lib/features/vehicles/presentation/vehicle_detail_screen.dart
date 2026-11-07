import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/severity_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/data/auth_repository.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';
import 'vehicle_providers.dart';
import 'widgets/fuel_type_ui.dart';

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
            title: Text(vehicle.displayName),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _HeaderCard(vehicle: vehicle),
              const SizedBox(height: 24),
              _RecentScans(vehicleId: vehicleId),
              const SizedBox(height: 24),
              _Reminders(vehicleId: vehicleId),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final odometer = vehicle.odometerKm;
    final added = vehicle.createdAt;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(LucideIcons.carFront, size: 36, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              '${vehicle.make} ${vehicle.model}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onPrimaryContainer,
              ),
            ),
            if (vehicle.nickname?.isNotEmpty ?? false)
              Text(
                '"${vehicle.nickname}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
            const SizedBox(height: 16),
            _InfoRow(LucideIcons.calendar, 'Year', '${vehicle.year}'),
            _InfoRow(LucideIcons.hash, 'Plate', vehicle.plate ?? 'Not set'),
            _InfoRow(vehicle.fuelType.icon, 'Fuel', vehicle.fuelType.label),
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
    final theme = Theme.of(context);
    final onColor = theme.colorScheme.onPrimaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: onColor),
          const SizedBox(width: 10),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: onColor),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _RecentScans extends ConsumerWidget {
  const _RecentScans({required this.vehicleId});

  final String vehicleId;

  String _labelText(List<String> labels) {
    if (labels.isEmpty) return 'No warning lights';
    return labels.map((l) => l.replaceAll('_', ' ')).join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scans = ref.watch(vehicleScansProvider(vehicleId));
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Recent scans'),
        if (scans.isEmpty) const _EmptyNote('No scans saved for this car yet.'),
        for (final scan in scans)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(LucideIcons.scanLine, color: colors.primary),
            title: Text(
              _labelText(scan.lights.map((l) => l.label).toSet().toList()),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              scan.createdAt == null ? 'Just now' : formatDate(scan.createdAt!),
            ),
          ),
      ],
    );
  }
}

class _Reminders extends ConsumerWidget {
  const _Reminders({required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(vehicleRemindersProvider(vehicleId));
    final colors = Theme.of(context).colorScheme;
    final severity = context.severity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Reminders'),
        if (reminders.isEmpty) const _EmptyNote('No reminders for this car.'),
        for (final r in reminders)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              LucideIcons.bell,
              color: r.isOverdue ? severity.stop : colors.primary,
            ),
            title: Text(r.title),
            subtitle: Text(
              r.isOverdue
                  ? 'Overdue since ${formatDate(r.dueDate)}'
                  : 'Due ${formatDate(r.dueDate)}',
              style: r.isOverdue ? TextStyle(color: severity.stop) : null,
            ),
          ),
      ],
    );
  }
}
