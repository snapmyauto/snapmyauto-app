import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/warning_light_repository.dart';
import '../domain/warning_light.dart';
import 'widgets/light_visuals.dart';

class LightDetailScreen extends ConsumerWidget {
  const LightDetailScreen({super.key, required this.lightId});

  final String lightId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final light = ref.watch(warningLightProvider(lightId));

    return Scaffold(
      appBar: AppBar(),
      body: light.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Could not load this light.')),
        data: (l) => l == null
            ? const Center(child: Text('Light not found.'))
            : _Body(light: l),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.light});

  final WarningLight light;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final drive = light.canDrive;
    final driveSeverity = switch (drive) {
      CanDrive.yes => LightSeverity.safe,
      CanDrive.short => LightSeverity.soon,
      CanDrive.no => LightSeverity.stop,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Center(child: LightIconCircle(light: light, size: 110)),
        const SizedBox(height: 16),
        Text(
          light.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Center(child: SeverityBadge(severity: light.severity)),
        const SizedBox(height: 24),
        _Section(
          icon: LucideIcons.info,
          title: 'What it means',
          text: light.meaning,
        ),
        _Section(
          icon: LucideIcons.wrench,
          title: 'What to do',
          text: light.action,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: driveSeverity.tint(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(driveSeverity.icon, color: driveSeverity.color(context)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Can I keep driving?',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: driveSeverity.color(context),
                      ),
                    ),
                    Text(
                      drive.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: driveSeverity.color(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(
              light.detectable ? LucideIcons.scanLine : LucideIcons.bookOpen,
              size: 16,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                light.detectable
                    ? 'SnapMyAuto can detect this light from a photo.'
                    : 'Reference only. Scanning can\'t detect this light yet.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(text, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
