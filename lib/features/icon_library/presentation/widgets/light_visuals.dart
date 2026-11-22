import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/severity.dart';
import '../../domain/warning_light.dart';

// colour of the real light on the dashboard
extension SeverityLightColour on Severity {
  String get lightColour => switch (this) {
    Severity.stop => 'Red light',
    Severity.soon => 'Amber light',
    Severity.safe => 'Green light',
    Severity.info => 'Blue light',
  };
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

  Severity get severity => switch (this) {
    CanDrive.yes => Severity.safe,
    CanDrive.short => Severity.soon,
    CanDrive.no => Severity.stop,
  };
}

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