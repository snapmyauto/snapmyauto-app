import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/severity_colors.dart';
import '../../../../core/utils/l10n.dart';
import '../../../scan/data/scan_repository.dart';
import '../../../sos/data/contact_repository.dart';
import '../../../vehicles/data/vehicle_repository.dart';

// setup list for new users, goes away once every step is done
class GetStarted extends ConsumerWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);
    final contacts = ref.watch(contactsProvider);
    final scans = ref.watch(scansProvider);
    // wait for real data so the card doesn't flash for old users
    if (!vehicles.hasValue || !contacts.hasValue || !scans.hasValue) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final steps = [
      (l10n.homeStepAccount, true, null),
      (l10n.homeStepCar, vehicles.value!.isNotEmpty, '/vehicles/new'),
      (l10n.homeStepSos, contacts.value!.isNotEmpty, '/sos/contacts'),
      (l10n.homeStepScan, scans.value!.isNotEmpty, '/scan'),
    ];
    final done = steps.where((s) => s.$2).length;
    if (done == steps.length) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.homeGetStarted,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    l10n.homeStepsDone(done, steps.length),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: done / steps.length,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              for (final (label, isDone, path) in steps)
                _Step(
                  label: label,
                  done: isDone,
                  onTap: isDone || path == null
                      ? null
                      : () => context.push(path),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.done, this.onTap});

  final String label;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sev = context.severity;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      onTap: onTap,
      leading: Icon(
        done ? LucideIcons.circleCheck : LucideIcons.circle,
        color: done ? sev.safe : colors.outline,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          decoration: done ? TextDecoration.lineThrough : null,
          color: done ? colors.onSurfaceVariant : colors.onSurface,
        ),
      ),
      trailing: done ? null : const Icon(LucideIcons.chevronRight, size: 18),
    );
  }
}
