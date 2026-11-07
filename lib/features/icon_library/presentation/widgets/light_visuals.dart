import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/severity_colors.dart';
import '../../domain/warning_light.dart';

// icon shown for each light id
IconData lightIcon(String id) {
  switch (id) {
    case 'abs':
      return LucideIcons.disc;
    case 'airbag':
      return LucideIcons.personStanding;
    case 'battery':
      return LucideIcons.batteryWarning;
    case 'brake_system':
      return LucideIcons.octagonAlert;
    case 'check_engine':
      return LucideIcons.cog;
    case 'coolant_temp':
      return LucideIcons.thermometer;
    case 'door_open':
      return LucideIcons.doorOpen;
    case 'fog_light':
      return LucideIcons.cloudFog;
    case 'low_fuel':
      return LucideIcons.fuel;
    case 'oil_pressure':
      return LucideIcons.droplet;
    case 'power_steering':
      return LucideIcons.lifeBuoy;
    case 'seatbelt':
      return LucideIcons.userCheck;
    case 'traction_control':
      return LucideIcons.waves;
    case 'tyre_pressure':
      return LucideIcons.circleDot;
    case 'washer_fluid':
      return LucideIcons.sprayCan;
    case 'high_beam':
      return LucideIcons.lightbulb;
    case 'cruise_control':
      return LucideIcons.gauge;
    case 'glow_plug':
      return LucideIcons.flame;
    case 'transmission_temp':
      return LucideIcons.thermometerSun;
    default:
      return LucideIcons.triangleAlert;
  }
}

extension LightSeverityStyle on LightSeverity {
  String get label {
    switch (this) {
      case LightSeverity.stop:
        return 'Stop now';
      case LightSeverity.soon:
        return 'Garage soon';
      case LightSeverity.safe:
        return 'Safe';
      case LightSeverity.info:
        return 'Info';
    }
  }

  IconData get icon {
    switch (this) {
      case LightSeverity.stop:
        return LucideIcons.octagonX;
      case LightSeverity.soon:
        return LucideIcons.triangleAlert;
      case LightSeverity.safe:
        return LucideIcons.circleCheck;
      case LightSeverity.info:
        return LucideIcons.info;
    }
  }

  Color color(BuildContext context) {
    final s = context.severity;
    switch (this) {
      case LightSeverity.stop:
        return s.stop;
      case LightSeverity.soon:
        return s.soon;
      case LightSeverity.safe:
        return s.safe;
      case LightSeverity.info:
        return s.info;
    }
  }

  Color tint(BuildContext context) {
    final s = context.severity;
    switch (this) {
      case LightSeverity.stop:
        return s.stopTint;
      case LightSeverity.soon:
        return s.soonTint;
      case LightSeverity.safe:
        return s.safeTint;
      case LightSeverity.info:
        return s.infoTint;
    }
  }
}

extension CanDriveText on CanDrive {
  String get label {
    switch (this) {
      case CanDrive.yes:
        return 'Yes, you can keep driving';
      case CanDrive.short:
        return 'Only a short distance, carefully';
      case CanDrive.no:
        return 'No, stop when it is safe';
    }
  }
}

// small coloured pill: icon + text, never colour alone
class SeverityBadge extends StatelessWidget {
  const SeverityBadge({super.key, required this.severity});

  final LightSeverity severity;

  @override
  Widget build(BuildContext context) {
    final fg = severity.color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: severity.tint(context),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(severity.icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            severity.label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// round icon in the severity colour
class LightIconCircle extends StatelessWidget {
  const LightIconCircle({super.key, required this.light, this.size = 56});

  final WarningLight light;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: light.severity.tint(context),
        shape: BoxShape.circle,
      ),
      child: Icon(
        lightIcon(light.id),
        size: size * 0.5,
        color: light.severity.color(context),
      ),
    );
  }
}
