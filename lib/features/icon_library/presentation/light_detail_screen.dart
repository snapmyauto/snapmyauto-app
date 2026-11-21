import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/severity.dart';
import '../../../core/widgets/severity_badge.dart';
import '../../triage/presentation/widgets/read_aloud_button.dart';
import '../data/warning_light_repository.dart';
import '../domain/warning_light.dart';
import 'widgets/light_visuals.dart';

class LightDetailScreen extends ConsumerWidget {
  const LightDetailScreen({super.key, required this.lightId});

  final String lightId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final light = ref.watch(warningLightProvider(lightId));

    return light.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const _Message('Could not load this light.'),
      data: (l) => l == null
          ? const _Message('Light not found.')
          : Scaffold(body: _Body(light: l)),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.light});

  final WarningLight light;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(light: light),
        Padding(
          padding: EdgeInsets.fromLTRB(18, 16, 18, 24 + bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoCard(
                title: 'What it means',
                child: Text(
                  light.meaning,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
              if (light.causes.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Common causes',
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [for (final c in light.causes) _CauseChip(c)],
                  ),
                ),
              ],
              if (light.steps.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'What to do',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < light.steps.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${i + 1}. ${light.steps[i]}',
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _DriveCard(light: light),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/scan'),
                      icon: const Icon(LucideIcons.scanLine, size: 18),
                      label: const Text('Scan this light'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/garages'),
                      icon: const Icon(LucideIcons.mapPin, size: 18),
                      label: const Text('Find garage'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                light.detectable
                    ? 'SnapMyAuto can detect this light from a photo.'
                    : 'Reference only. Scanning can\'t detect this light yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.light});

  final WarningLight light;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.fromLTRB(18, top + 12, 18, 26),
      decoration: BoxDecoration(
        color: light.severity.tint(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filled(
                tooltip: 'Back',
                style: IconButton.styleFrom(
                  backgroundColor: colors.surface,
                  foregroundColor: colors.onSurface,
                  fixedSize: const Size(44, 44),
                ),
                onPressed: () => context.pop(),
                icon: const Icon(LucideIcons.chevronLeft, size: 20),
              ),
              ReadAloudButton(text: _speech(light)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              LightIcon(light: light, size: 86, background: colors.surface),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      light.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SeverityBadge(
                      severity: light.severity,
                      prefix: 'Usually: ',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${light.severity.lightColour} · ${light.category.label}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _speech(WarningLight light) {
  final text = StringBuffer(
    '${light.name}. Usually ${light.severity.label}. ${light.meaning} ',
  );
  if (light.steps.isNotEmpty) {
    text.write('What to do. ${light.steps.join('. ')}. ');
  }
  text.write(
    'Can I keep driving? ${light.canDrive.answer}. ${light.driveNote}',
  );
  return text.toString();
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}

class _CauseChip extends StatelessWidget {
  const _CauseChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DriveCard extends StatelessWidget {
  const _DriveCard({required this.light});

  final WarningLight light;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final drive = light.canDrive;
    final color = drive.severity.color(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: drive.severity.tint(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(drive.icon, size: 18, color: colors.surface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Can I keep driving? ${drive.answer}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                if (light.driveNote.isNotEmpty)
                  Text(
                    light.driveNote,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(text)),
    );
  }
}
