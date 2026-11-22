import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/severity_colors.dart';
import '../../../core/theme/theme_providers.dart';

const _modelRepo = 'https://github.com/snapmyauto/dashlight';
final _packageInfoProvider = FutureProvider(
  (ref) => PackageInfo.fromPlatform(),
);

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sev = context.severity;
    final accent = ref.watch(accentProvider);
    final info = ref.watch(_packageInfoProvider).value;
    final logo = accent == AppAccent.blue
        ? 'assets/images/logo-blue.svg'
        : 'assets/images/logo-green.svg';

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: EdgeInsets.all(20),
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
          const _NoteCard(
            icon: LucideIcons.shieldCheck,
            title: 'Your privacy',
            text:
                'Photos are checked on your phone and are never uploaded. '
                'Your vehicles, scans and reminders are saved to your own '
                'account only.',
          ),
          const SizedBox(height: 16),
          _NoteCard(
            icon: LucideIcons.triangleAlert,
            title: 'Safety first',
            text:
                'SnapMyAuto gives general advice. It does not replace a '
                'mechanic. If a red light comes on, stop safely before you '
                'check the app.',
            color: sev.soon,
            background: sev.soonTint,
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.fileText),
                  title: const Text('Terms and privacy'),
                  trailing: const Icon(LucideIcons.chevronRight, size: 18),
                  onTap: () => context.push('/terms'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.code),
                  title: const Text('DashLight model on GitHub'),
                  trailing: const Icon(LucideIcons.externalLink, size: 18),
                  onTap: () => launchUrl(
                    Uri.parse(_modelRepo),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ],
            ),
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
          _CardTitle(icon: icon, title: title, color: colors.primary),
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

// card with a title and one paragraph, only the icon takes the custom colour
class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.icon,
    required this.title,
    required this.text,
    this.color,
    this.background,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background ?? colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: icon, title: title, color: color ?? colors.primary),
          const SizedBox(height: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              // tinted cards need full contrast text
              color: background == null
                  ? colors.onSurfaceVariant
                  : colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
