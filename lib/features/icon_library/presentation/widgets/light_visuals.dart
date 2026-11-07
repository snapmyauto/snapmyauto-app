import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/severity_colors.dart';
import '../../domain/warning_light.dart';

extension LightSeverityStyle on LightSeverity {
  String get label => switch (this) {
    LightSeverity.stop => 'Stop now',
    LightSeverity.soon => 'Garage soon',
    LightSeverity.safe => 'Safe',
    LightSeverity.info => 'Info',
  };

  // colour of the real light on the dashboard
  String get lightColour => switch (this) {
    LightSeverity.stop => 'Red light',
    LightSeverity.soon => 'Amber light',
    LightSeverity.safe => 'Green light',
    LightSeverity.info => 'Blue light',
  };

  IconData get icon => switch (this) {
    LightSeverity.stop => LucideIcons.octagonX,
    LightSeverity.soon => LucideIcons.triangleAlert,
    LightSeverity.safe => LucideIcons.circleCheck,
    LightSeverity.info => LucideIcons.info,
  };

  Color color(BuildContext context) {
    final s = context.severity;
    return switch (this) {
      LightSeverity.stop => s.stop,
      LightSeverity.soon => s.soon,
      LightSeverity.safe => s.safe,
      LightSeverity.info => s.info,
    };
  }

  Color tint(BuildContext context) {
    final s = context.severity;
    return switch (this) {
      LightSeverity.stop => s.stopTint,
      LightSeverity.soon => s.soonTint,
      LightSeverity.safe => s.safeTint,
      LightSeverity.info => s.infoTint,
    };
  }
}

extension LightCategoryText on LightCategory {
  String get label => switch (this) {
    LightCategory.engine => 'Engine',
    LightCategory.brakes => 'Brakes',
    LightCategory.safety => 'Safety',
    LightCategory.lights => 'Lights',
  };
}

extension CanDriveStyle on CanDrive {
  String get answer => switch (this) {
    CanDrive.yes => 'Yes',
    CanDrive.short => 'Carefully',
    CanDrive.no => 'No',
  };

  IconData get icon => switch (this) {
    CanDrive.yes => LucideIcons.check,
    CanDrive.short => LucideIcons.triangleAlert,
    CanDrive.no => LucideIcons.x,
  };

  LightSeverity get severity => switch (this) {
    CanDrive.yes => LightSeverity.safe,
    CanDrive.short => LightSeverity.soon,
    CanDrive.no => LightSeverity.stop,
  };
}

// dashboard symbol on a rounded tile, tile is the severity tint by default
class LightIcon extends StatelessWidget {
  const LightIcon({
    super.key,
    required this.light,
    this.size = 48,
    this.background,
  });

  final WarningLight light;
  final double size;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final color = light.severity.color(context);
    final symbol = size * 0.56;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? light.severity.tint(context),
        borderRadius: BorderRadius.circular(size * 0.29),
      ),
      child: light.id == 'abs'
          ? _AbsSymbol(size: symbol, color: color)
          : SvgPicture.asset(
              'assets/icons/lights/${light.id}.svg',
              width: symbol,
              height: symbol,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              // unknown id, fall back to a general warning sign
              errorBuilder: (_, _, _) =>
                  Icon(LucideIcons.triangleAlert, size: symbol, color: color),
            ),
    );
  }
}

// abs is just the letters in a circle, easier as text than svg
class _AbsSymbol extends StatelessWidget {
  const _AbsSymbol({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: size * 0.08),
      ),
      child: Text(
        'ABS',
        style: TextStyle(
          color: color,
          fontSize: size * 0.3,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

// solid pill, e.g. "Usually: Stop now"
class SeverityBadge extends StatelessWidget {
  const SeverityBadge({super.key, required this.severity, this.prefix = ''});

  final LightSeverity severity;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    // surface colour reads well on the severity colour in light and dark
    final fg = Theme.of(context).colorScheme.surface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: severity.color(context),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(severity.icon, size: 13, color: fg),
          const SizedBox(width: 6),
          Text(
            '$prefix${severity.label}',
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

// old round icon, still used by the detail screen until it moves to LightIcon
class LightIconCircle extends StatelessWidget {
  const LightIconCircle({super.key, required this.light, this.size = 56});

  final WarningLight light;
  final double size;

  @override
  Widget build(BuildContext context) => LightIcon(light: light, size: size);
}

extension CanDriveText on CanDrive {
  String get label => switch (this) {
    CanDrive.yes => 'Yes, you can keep driving',
    CanDrive.short => 'Only a short distance, carefully',
    CanDrive.no => 'No, stop when it is safe',
  };
}
