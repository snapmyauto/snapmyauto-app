import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/severity.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/card_rings.dart';
import '../../../core/widgets/severity_badge.dart';
import '../../ai_chat/domain/chat_context.dart';
import '../../auth/data/auth_repository.dart';
import '../../icon_library/presentation/widgets/light_visuals.dart';
import '../../settings/data/app_settings.dart';
import '../domain/triage_result.dart';
import 'triage_advice.dart';
import 'widgets/read_aloud_button.dart';

class TriageResultScreen extends ConsumerWidget {
  final TriageResult result;

  const TriageResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLoggedIn = ref.watch(currentUidProvider) != null;
    final reasons = TriageAdvice.reasons(result);

    final children = <Widget>[_buildHero(context, theme)];

    if (result.worstLight != null) {
      children.add(const SizedBox(height: 14));
      children.add(_buildLightCard(context, theme));
    }
    if (reasons.isNotEmpty) {
      children.add(const SizedBox(height: 14));
      children.add(_buildReasonsCard(theme, reasons));
    }
    children.add(const SizedBox(height: 14));
    children.add(_buildStepsCard(theme));

    if (result.symptoms.isEmpty) {
      children.add(const SizedBox(height: 6));
      children.add(
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(LucideIcons.stethoscope, size: 18),
            label: const Text('Add symptoms'),
            onPressed: () {
              context.pushReplacement('/symptoms', extra: result);
            },
          ),
        ),
      );
    }

    children.add(const SizedBox(height: 10));
    children.add(
      Text(
        "AI guidance only, not a mechanic's diagnosis. "
        'If in doubt, stop and get help.',
        style: TextStyle(
          fontSize: 12,
          height: 1.45,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(LucideIcons.x),
          onPressed: () => _close(context),
        ),
        title: const Text(
          'Your result',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          ReadAloudButton(
            text: TriageAdvice.speech(result),
            autoStart: ref.read(readResultsProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: children,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 8, 18, 16),
        child: isLoggedIn
            ? _buildActions(context)
            : _buildGuestActions(context, theme),
      ),
    );
  }

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Widget _buildHero(BuildContext context, ThemeData theme) {
    final severity = result.severity;
    final background = severity.color(context);
    // same colours as the severity badge, works in light and dark
    final foreground = theme.colorScheme.surface;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          const CardRings(size: 180, offset: 50, radii: [88, 58]),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: foreground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(severity.icon, size: 28, color: background),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SEVERITY',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: foreground.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            severity.label,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  TriageAdvice.summary(severity),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(result.canDrive.icon, size: 18, color: foreground),
                    const SizedBox(width: 8),
                    Text(
                      'Can I keep driving? ${result.canDrive.answer}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightCard(BuildContext context, ThemeData theme) {
    final light = result.worstLight!;
    final otherLights = result.lights.skip(1).toList();
    final muted = theme.colorScheme.onSurfaceVariant;

    final content = <Widget>[
      Row(
        children: [
          LightIcon(light: light, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  light.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${light.severity.lightColour} · ${light.severity.label}',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Text(light.meaning, style: const TextStyle(fontSize: 14, height: 1.5)),
    ];

    if (otherLights.isNotEmpty) {
      content.add(const Divider(height: 24));
      content.add(
        Text(
          'Also found',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: muted,
          ),
        ),
      );
      content.add(const SizedBox(height: 8));
      content.add(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: otherLights
              .map((l) => SeverityChip(severity: l.severity, label: l.name))
              .toList(),
        ),
      );
    }

    return _buildCard(null, content);
  }

  Widget _buildReasonsCard(ThemeData theme, List<String> reasons) {
    final chips = reasons.map((reason) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          reason,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      );
    }).toList();

    return _buildCard('Why this decision', [
      Wrap(spacing: 8, runSpacing: 8, children: chips),
    ]);
  }

  Widget _buildStepsCard(ThemeData theme) {
    final steps = TriageAdvice.steps(result);
    final rows = <Widget>[];

    for (int i = 0; i < steps.length; i++) {
      if (i > 0) rows.add(const SizedBox(height: 10));
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                steps[i],
                style: const TextStyle(fontSize: 14, height: 1.45),
              ),
            ),
          ],
        ),
      );
    }

    return _buildCard('Do this now', rows);
  }

  Widget _buildCard(String? title, List<Widget> content) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
            ],
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Find garage',
                icon: LucideIcons.mapPin,
                onPressed: () => context.go('/garages'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SecondaryButton(
                label: 'Ask AI',
                icon: LucideIcons.messageSquare,
                onPressed: () {
                  context.push('/chat', extra: ChatContext(triage: result));
                },
              ),
            ),
          ],
        ),
        TextButton.icon(
          icon: const Icon(LucideIcons.phone, size: 18),
          label: const Text('Call help'),
          onPressed: () => context.push('/sos'),
        ),
      ],
    );
  }

  // garages, ai chat and sos need an account
  Widget _buildGuestActions(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Log in to save scans, ask the AI and find garages.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: 'Log in',
            icon: LucideIcons.logIn,
            onPressed: () => context.go('/auth/login'),
          ),
        ),
      ],
    );
  }
}
