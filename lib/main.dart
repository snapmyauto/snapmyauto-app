import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/severity_colors.dart';
import 'core/theme/theme_providers.dart';
import 'core/utils/shared_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: const SnapMyAutoApp(),
  ));
}

class SnapMyAutoApp extends ConsumerWidget {
  const SnapMyAutoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentProvider);
    final mode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'SnapMyAuto',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(accent, Brightness.light),
      darkTheme: buildTheme(accent, Brightness.dark),
      themeMode: mode,
      home: const _ThemeTestPage(),
    );
  }
}

// temp test page, removed in step 5
class _ThemeTestPage extends ConsumerWidget {
  const _ThemeTestPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentProvider);
    final mode = ref.watch(themeModeProvider);
    final sev = context.severity;
    Widget chip(String label, Color fg, Color bg, IconData icon) => Chip(
          avatar: Icon(icon, color: fg, size: 18),
          label: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w800)),
          backgroundColor: bg,
          side: BorderSide.none,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Theme test')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('Accent', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<AppAccent>(
            segments: const [
              ButtonSegment(value: AppAccent.green, label: Text('Green')),
              ButtonSegment(value: AppAccent.blue, label: Text('Blue')),
            ],
            selected: {accent},
            onSelectionChanged: (s) => ref.read(accentProvider.notifier).change(s.first),
          ),
          const SizedBox(height: 16),
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ],
            selected: {mode},
            onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).change(s.first),
          ),
          const SizedBox(height: 24),
          Wrap(spacing: 8, runSpacing: 8, children: [
            chip('Stop now', sev.stop, sev.stopTint, Icons.error),
            chip('Garage soon', sev.soon, sev.soonTint, Icons.warning_amber),
            chip('Safe', sev.safe, sev.safeTint, Icons.check_circle),
            chip('Info', sev.info, sev.infoTint, Icons.info),
          ]),
          const SizedBox(height: 24),
          FilledButton(onPressed: () {}, child: const Text('Scan a warning light')),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () {}, child: const Text('Find garage')),
        ],
      ),
    );
  }
}
