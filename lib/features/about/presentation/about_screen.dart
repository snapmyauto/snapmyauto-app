import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_providers.dart';

final _packageInfoProvider = FutureProvider(
  (ref) => PackageInfo.fromPlatform(),
);

const _team = [
  ('Sasmitha', 'Team lead · scan, AI and data'),
  ('Thilina', 'Onboarding and triage'),
  ('Thevinu', 'Vehicles and profile'),
  ('Ravindu', 'Home, history and settings'),
  ('Wanuja', 'Garages and SOS'),
  ('Nimeshika', 'Icon library, reminders and about'),
];

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = ref.watch(accentProvider);
    final info = ref.watch(_packageInfoProvider).value;
    final logo = accent == AppAccent.blue
        ? 'assets/images/logo-blue.svg'
        : 'assets/images/logo-green.svg';

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Center(child: SvgPicture.asset(logo, width: 88, height: 88)),
          const SizedBox(height: 14),
          Text(
            'SnapMyAuto',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            info == null
                ? ' '
                : 'Version ${info.version} (${info.buildNumber})',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Snap a photo of your dashboard to find out what a warning light '
            'means and what to do next.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          const _Card(
            icon: LucideIcons.scanLine,
            title: 'DashLight model',
            lines: [
              ('Version', 'v1.0'),
              ('Lights it can detect', '15'),
              ('Accuracy (mAP@50)', '0.847'),
              ('Runs', 'On your phone, no internet needed'),
            ],
          ),
          const SizedBox(height: 16),
          const _Card(
            icon: LucideIcons.graduationCap,
            title: 'Project',
            lines: [
              ('Module', 'SE303.3 Mobile Application Development'),
              ('University', 'NSBM Green University'),
              ('Group', '100'),
            ],
          ),
          const SizedBox(height: 16),
          _Card(
            icon: LucideIcons.users,
            title: 'Team',
            lines: [for (final m in _team) (m.$1, m.$2)],
          ),
          const SizedBox(height: 24),
          Text(
            'Map data © OpenStreetMap contributors',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: 'SnapMyAuto',
              applicationVersion: info?.version,
            ),
            child: const Text('Open source licences'),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.icon, required this.title, required this.lines});

  final IconData icon;
  final String title;
  final List<(String, String)> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final (label, value) in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
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
