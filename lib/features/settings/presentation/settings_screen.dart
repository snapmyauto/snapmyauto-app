import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/severity_colors.dart';
import '../../../core/theme/theme_providers.dart';
import '../../../core/utils/l10n.dart';
import '../../ai_chat/data/chat_bubble_setting.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/user_repository.dart';
import '../data/app_settings.dart';
import 'widgets/appearance_pickers.dart';
import 'widgets/settings_group.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _languages = {'en': 'English', 'si': 'සිංහල', 'ta': 'தமிழ்'};

  Future<T?> _pick<T>(
    BuildContext context, {
    required String title,
    required Map<T, String> options,
    required T current,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final entry in options.entries)
              ListTile(
                title: Text(entry.value),
                trailing: entry.key == current
                    ? const Icon(LucideIcons.check)
                    : null,
                onTap: () => Navigator.pop(context, entry.key),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(authRepositoryProvider).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final accent = ref.watch(accentProvider);
    final mode = ref.watch(themeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    final unit = ref.watch(distanceUnitProvider);
    final alerts = ref.watch(reminderAlertsProvider);
    final showBubble = ref.watch(chatBubbleProvider);
    final profile = ref.watch(userProfileProvider).value;

    final languageName = locale == null
        ? l10n.languageSystem
        : _languages[locale.languageCode] ?? l10n.languageSystem;
    final unitNames = {
      DistanceUnit.km: l10n.unitsKm,
      DistanceUnit.miles: l10n.unitsMiles,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        // room at the bottom for the glass bar and the ai button
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 170),
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                foregroundImage: profile?.photoUrl != null
                    ? NetworkImage(profile!.photoUrl!)
                    : null,
                child: Text(
                  profile?.initials ?? '?',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              title: Text(
                (profile?.name.isNotEmpty ?? false)
                    ? profile!.name
                    : l10n.homeProfile,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(profile?.email ?? ''),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: () => context.push('/profile'),
            ),
          ),
          const SizedBox(height: 20),
          SettingsGroup(
            title: l10n.settingsAppearance,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.settingsTheme,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    PillPicker<ThemeMode>(
                      options: {
                        ThemeMode.light: l10n.themeLight,
                        ThemeMode.dark: l10n.themeDark,
                        ThemeMode.system: l10n.themeSystem,
                      },
                      selected: mode,
                      onChanged: (m) =>
                          ref.read(themeModeProvider.notifier).change(m),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.settingsAccent,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    AccentPicker(
                      selected: accent,
                      labels: {
                        AppAccent.green: l10n.accentGreen,
                        AppAccent.blue: l10n.accentBlue,
                      },
                      onChanged: (a) =>
                          ref.read(accentProvider.notifier).change(a),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: l10n.settingsGeneral,
            children: [
              SettingsLink(
                icon: LucideIcons.globe,
                title: l10n.settingsLanguage,
                value: languageName,
                onTap: () async {
                  final picked = await _pick<String>(
                    context,
                    title: l10n.settingsLanguage,
                    options: {'': l10n.languageSystem, ..._languages},
                    current: locale?.languageCode ?? '',
                  );
                  if (picked == null) return;
                  await ref
                      .read(appLocaleProvider.notifier)
                      .change(picked.isEmpty ? null : Locale(picked));
                },
              ),
              SettingsLink(
                icon: LucideIcons.ruler,
                title: l10n.settingsUnits,
                value: unit.name,
                onTap: () async {
                  final picked = await _pick<DistanceUnit>(
                    context,
                    title: l10n.settingsUnits,
                    options: unitNames,
                    current: unit,
                  );
                  if (picked != null) {
                    await ref
                        .read(distanceUnitProvider.notifier)
                        .change(picked);
                  }
                },
              ),
              SwitchListTile(
                secondary: const SettingsIcon(LucideIcons.sparkles),
                title: Text(
                  l10n.settingsAiButton,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(l10n.settingsAiButtonSub),
                value: showBubble,
                onChanged: (on) =>
                    ref.read(chatBubbleProvider.notifier).change(on),
              ),
            ],
          ),
          SettingsGroup(
            title: l10n.settingsNotifications,
            children: [
              SwitchListTile(
                secondary: const SettingsIcon(LucideIcons.bell),
                title: Text(
                  l10n.settingsReminderAlerts,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(l10n.settingsReminderAlertsSub),
                value: alerts,
                onChanged: (on) =>
                    ref.read(reminderAlertsProvider.notifier).change(on),
              ),
            ],
          ),
          SettingsGroup(
            title: l10n.settingsAccount,
            children: [
              SettingsLink(
                icon: LucideIcons.carFront,
                title: l10n.settingsMyVehicles,
                onTap: () => context.push('/vehicles'),
              ),
              SettingsLink(
                icon: LucideIcons.phone,
                title: l10n.settingsEmergency,
                onTap: () => context.push('/sos'),
              ),
              SettingsLink(
                icon: LucideIcons.bookOpen,
                title: l10n.homeIconLibrary,
                onTap: () => context.push('/library'),
              ),
              SettingsLink(
                icon: LucideIcons.bellRing,
                title: l10n.homeReminders,
                onTap: () => context.push('/reminders'),
              ),
              SettingsLink(
                icon: LucideIcons.info,
                title: l10n.settingsAbout,
                onTap: () => context.push('/about'),
              ),
            ],
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: context.severity.stop,
              side: BorderSide(color: colors.outlineVariant),
            ),
            icon: const Icon(LucideIcons.logOut, size: 18),
            label: Text(l10n.logout),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }
}
