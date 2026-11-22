import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/severity_colors.dart';
import '../../auth/data/auth_repository.dart';
import '../data/contact_repository.dart';
import '../domain/emergency_contact.dart';

enum _ContactAction { edit, primary, delete }

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    EmergencyContact contact,
    _ContactAction action,
  ) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final repo = ref.read(contactRepositoryProvider);

    switch (action) {
      case _ContactAction.edit:
        context.push('/sos/contacts/edit', extra: contact);
      case _ContactAction.primary:
        await repo.setPrimary(uid, contact.id);
      case _ContactAction.delete:
        final sure = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Delete ${contact.name}?'),
            content: const Text('They will no longer get your SOS messages.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: ctx.severity.stop,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (sure == true) await repo.delete(uid, contact.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency contacts',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sos/contacts/new'),
        icon: const Icon(LucideIcons.userPlus),
        label: const Text('Add contact'),
      ),
      body: contacts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('Could not load contacts. Check your connection.'),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.users,
                      size: 48,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text('No contacts yet', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Add someone who should be called if you\'re in trouble.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = list[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: c.isPrimary
                        ? context.brand.fill
                        : scheme.primaryContainer,
                    foregroundColor: c.isPrimary
                        ? context.brand.onFill
                        : scheme.onPrimaryContainer,
                    child: Text(c.name.isEmpty ? '?' : c.name[0].toUpperCase()),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          c.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (c.isPrimary) ...[
                        const SizedBox(width: 8),
                        _PrimaryBadge(),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    [c.phone, if (c.relation != null) c.relation].join(' · '),
                  ),
                  trailing: PopupMenuButton<_ContactAction>(
                    onSelected: (a) => _onAction(context, ref, c, a),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: _ContactAction.edit,
                        child: Text('Edit'),
                      ),
                      if (!c.isPrimary)
                        const PopupMenuItem(
                          value: _ContactAction.primary,
                          child: Text('Set as primary'),
                        ),
                      const PopupMenuItem(
                        value: _ContactAction.delete,
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PrimaryBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Primary',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
