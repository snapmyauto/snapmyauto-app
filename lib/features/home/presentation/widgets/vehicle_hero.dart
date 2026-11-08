import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n.dart';
import '../../../reminders/domain/reminder.dart';
import '../../../settings/data/app_settings.dart';
import '../../../vehicles/data/vehicle_repository.dart';
import '../../../vehicles/domain/vehicle.dart';
import '../../../vehicles/presentation/widgets/fuel_type_ui.dart';
import '../../data/home_providers.dart';
import 'date_labels.dart';

class VehicleHero extends ConsumerWidget {
  const VehicleHero({super.key, required this.vehicle});

  final Vehicle vehicle;

  Future<void> _pickCar(BuildContext context, WidgetRef ref) async {
    final vehicles = ref.read(vehiclesProvider).value ?? const [];
    final picked = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final v in vehicles)
              ListTile(
                leading: const Icon(LucideIcons.carFront),
                title: Text(v.displayName),
                subtitle: Text('${v.year} · ${v.fuelType.label}'),
                trailing: v.id == vehicle.id
                    ? const Icon(LucideIcons.check)
                    : null,
                onTap: () => Navigator.pop(context, v.id),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      await ref.read(selectedVehicleIdProvider.notifier).select(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final fg = context.brand.onFill;
    final soft = fg.withValues(alpha: 0.75);
    final km = vehicle.odometerKm;
    final unit = ref.watch(distanceUnitProvider);

    String due(ReminderType type) {
      final reminder = ref.watch(nextReminderProvider(type));
      return reminder == null
          ? l10n.homeNotSet
          : dueLabel(context, reminder.dueDate);
    }

    return Material(
      color: context.brand.fill,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/vehicles/${vehicle.id}'),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Tooltip(
                      message: l10n.homeChangeCar,
                      child: ActionChip(
                        onPressed: () => _pickCar(context, ref),
                        color: WidgetStatePropertyAll(
                          fg.withValues(alpha: 0.14),
                        ),
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                vehicle.displayName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: fg,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(LucideIcons.chevronDown, size: 16, color: fg),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${vehicle.year} · ${vehicle.fuelType.label}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: soft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.homeOdometer,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: soft,
                ),
              ),
              Text(
                km == null ? l10n.homeNoMileage : unit.format(km),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: fg,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Stat(
                    label: l10n.homeNextService,
                    value: due(ReminderType.service),
                  ),
                  const SizedBox(width: 8),
                  _Stat(
                    label: l10n.homeLicence,
                    value: due(ReminderType.revenueLicence),
                  ),
                  const SizedBox(width: 8),
                  _Stat(
                    label: l10n.homeInsurance,
                    value: due(ReminderType.insurance),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final fg = context.brand.onFill;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: fg.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCarCard extends StatelessWidget {
  const AddCarCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(LucideIcons.carFront, size: 32, color: colors.primary),
            const SizedBox(height: 10),
            Text(
              l10n.homeAddCarTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.homeAddCarBody,
              style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: () => context.push('/vehicles/new'),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text(l10n.homeAddCarButton),
            ),
          ],
        ),
      ),
    );
  }
}
