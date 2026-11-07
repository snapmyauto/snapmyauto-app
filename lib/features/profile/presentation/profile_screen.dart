import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/severity_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/data/auth_repository.dart';
import '../../scan/data/scan_repository.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../data/user_repository.dart';
import '../domain/user_profile.dart';
import 'widgets/delete_account_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final controller = TextEditingController(text: profile.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || name == profile.name) return;

    await ref.read(userRepositoryProvider).updateName(profile.uid, name);
    await ref.read(authRepositoryProvider).updateDisplayName(name);
  }

  Future<void> _logOut(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can log back in any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(authRepositoryProvider).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final vehicleCount = ref.watch(vehiclesProvider).value?.length ?? 0;
    final scanCount = ref.watch(scansProvider).value?.length ?? 0;
    final colors = Theme.of(context).colorScheme;
    final severity = context.severity;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load profile.')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not found.'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              _ProfileHeader(
                profile: profile,
                onEditName: () => _editName(context, ref, profile),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: LucideIcons.carFront,
                      value: '$vehicleCount',
                      label: vehicleCount == 1 ? 'Vehicle' : 'Vehicles',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: LucideIcons.scanLine,
                      value: '$scanCount',
                      label: scanCount == 1 ? 'Scan' : 'Scans',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(LucideIcons.carFront),
                title: const Text('My vehicles'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () => context.push('/vehicles'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(LucideIcons.logOut),
                title: const Text('Log out'),
                onTap: () => _logOut(context, ref),
              ),
              const Divider(height: 32),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(LucideIcons.shieldAlert, color: severity.stop),
                title: Text(
                  'Delete account',
                  style: TextStyle(color: severity.stop),
                ),
                subtitle: Text(
                  'Removes your account and all saved data',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                onTap: () => showDeleteAccountDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.profile, required this.onEditName});

  final UserProfile profile;
  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final photo = profile.photoUrl;
    final since = profile.createdAt;

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: colors.primaryContainer,
          foregroundImage: photo != null ? NetworkImage(photo) : null,
          child: Text(
            profile.initials,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                profile.name.isEmpty ? 'Add your name' : profile.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Edit name',
              icon: const Icon(LucideIcons.pencil, size: 18),
              onPressed: onEditName,
            ),
          ],
        ),
        Text(
          profile.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        if (since != null) ...[
          const SizedBox(height: 4),
          Text(
            'Member since ${formatMonthYear(since)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

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
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
