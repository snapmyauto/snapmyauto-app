import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/vehicle.dart';
import 'fuel_type_ui.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.vehicle, this.onTap});

  final Vehicle vehicle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final odometer = vehicle.odometerKm;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  vehicle.type.icon,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        '${vehicle.year}',
                        if (vehicle.plate?.isNotEmpty ?? false) vehicle.plate!,
                      ].join(' · '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _Tag(
                          icon: vehicle.fuelType.icon,
                          text: vehicle.fuelType.label,
                        ),
                        _Tag(
                          icon: LucideIcons.cog,
                          text: vehicle.transmission.label,
                        ),
                        if (odometer != null)
                          _Tag(
                            icon: LucideIcons.gauge,
                            text: formatKm(odometer),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.labelMedium),
      ],
    );
  }
}
