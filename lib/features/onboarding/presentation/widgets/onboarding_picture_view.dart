import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/severity.dart';
import '../../../../core/widgets/severity_badge.dart';
import '../../domain/onboarding_page.dart';

class OnboardingPictureView extends StatelessWidget {
  final OnboardingPicture picture;

  const OnboardingPictureView({super.key, required this.picture});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget inside;
    if (picture == OnboardingPicture.scan) {
      inside = _buildScan(context, theme);
    } else if (picture == OnboardingPicture.severity) {
      inside = _buildSeverity();
    } else {
      inside = _buildHelp(theme);
    }

    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: inside,
    );
  }

  // a small dashboard with three lights and a scan line
  Widget _buildScan(BuildContext context, ThemeData theme) {
    final lights = <String, Severity>{
      'oil_pressure': Severity.stop,
      'check_engine': Severity.soon,
      'low_fuel': Severity.safe,
    };

    final lightBoxes = <Widget>[];
    lights.forEach((id, severity) {
      lightBoxes.add(
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: severity.color(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SvgPicture.asset(
            'assets/icons/lights/$id.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      );
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 180,
          height: 124,
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: lightBoxes,
          ),
        ),
        Positioned(
          left: 30,
          right: 30,
          top: 128,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: theme.colorScheme.primary, blurRadius: 12),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 36,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              '3 lights found',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeverity() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SeverityBadge(severity: Severity.stop),
        SizedBox(height: 12),
        SeverityBadge(severity: Severity.soon),
        SizedBox(height: 12),
        SeverityBadge(severity: Severity.safe),
      ],
    );
  }

  Widget _buildHelp(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHelpItem(theme, LucideIcons.mapPin, 'Garages'),
        _buildHelpItem(theme, LucideIcons.phone, 'SOS'),
        _buildHelpItem(theme, LucideIcons.sparkles, 'Ask AI'),
      ],
    );
  }

  Widget _buildHelpItem(ThemeData theme, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
