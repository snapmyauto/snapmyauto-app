import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/sos_service.dart';
import '../../domain/emergency_contact.dart';

Future<void> showSmsPreview(
  BuildContext context,
  List<EmergencyContact> contacts,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useRootNavigator: true,
    builder: (_) => _SmsPreviewSheet(contacts: contacts),
  );
}

class _SmsPreviewSheet extends ConsumerStatefulWidget {
  const _SmsPreviewSheet({required this.contacts});

  final List<EmergencyContact> contacts;

  @override
  ConsumerState<_SmsPreviewSheet> createState() => _SmsPreviewSheetState();
}

class _SmsPreviewSheetState extends ConsumerState<_SmsPreviewSheet> {
  late final Future<String> _message = ref
      .read(sosServiceProvider)
      .locationMessage();

  Future<void> _send(String message) async {
    final ok = await ref
        .read(sosServiceProvider)
        .sendSms(widget.contacts, message);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the messages app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: FutureBuilder<String>(
          future: _message,
          builder: (context, snap) {
            final message = snap.data;
            final noLocation =
                message != null && !message.contains('maps.google.com');

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Message preview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'To',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in widget.contacts)
                      Chip(
                        avatar: const Icon(LucideIcons.user, size: 16),
                        label: Text(c.name),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: message == null
                      ? const Row(
                          children: [
                            SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Getting your location...'),
                          ],
                        )
                      : Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                          ),
                        ),
                ),
                if (noLocation) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Location not found, so the message has no map link.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton.icon(
                  icon: const Icon(LucideIcons.send, size: 18),
                  label: const Text('Open messages'),
                  onPressed: message == null ? null : () => _send(message),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your messages app opens. Press send there.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
