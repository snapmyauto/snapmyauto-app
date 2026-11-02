import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/severity_colors.dart';
import '../../../core/theme/theme_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentProvider);
    final mode = ref.watch(themeModeProvider);
    final sev = context.severity;
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    Widget chip(String label, Color fg, Color bg, IconData icon) => Chip(
      avatar: Icon(icon, color: fg, size: 18),
      label: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800),
      ),
      backgroundColor: bg,
      side: BorderSide.none,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        // extra bottom space so the glass bar doesn't cover the last item
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
        children: [
          Text('Accent colour', style: titleStyle),
          const SizedBox(height: 8),
          SegmentedButton<AppAccent>(
            segments: const [
              ButtonSegment(value: AppAccent.green, label: Text('Green')),
              ButtonSegment(value: AppAccent.blue, label: Text('Blue')),
            ],
            selected: {accent},
            onSelectionChanged: (s) =>
                ref.read(accentProvider.notifier).change(s.first),
          ),
          const SizedBox(height: 16),
          Text('Theme', style: titleStyle),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ],
            selected: {mode},
            onSelectionChanged: (s) =>
                ref.read(themeModeProvider.notifier).change(s.first),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              chip('Stop now', sev.stop, sev.stopTint, Icons.error),
              chip('Garage soon', sev.soon, sev.soonTint, Icons.warning_amber),
              chip('Safe', sev.safe, sev.safeTint, Icons.check_circle),
              chip('Info', sev.info, sev.infoTint, Icons.info),
            ],
          ),
        ],
      ),
    );
  }
}
