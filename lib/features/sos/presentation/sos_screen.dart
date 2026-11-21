import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/severity_colors.dart';
import '../data/contact_repository.dart';
import '../data/crash_detector.dart';
import '../data/sos_service.dart';
import '../domain/emergency_contact.dart';
import 'widgets/hold_sos_button.dart';
import 'widgets/sms_preview_sheet.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _callPrimary(EmergencyContact? primary) async {
    if (primary == null) {
      _snack('Add an emergency contact first');
      return;
    }
    final ok = await ref.read(sosServiceProvider).call(primary);
    if (!ok && mounted) _snack('Could not open the phone app');
  }

  void _previewSms(List<EmergencyContact> contacts) {
    if (contacts.isEmpty) {
      _snack('Add an emergency contact first');
      return;
    }
    showSmsPreview(context, contacts);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sev = context.severity;
    final contacts = ref.watch(contactsProvider).value ?? [];
    final primary = ref.read(sosServiceProvider).primaryOf(contacts);
    final crashOn = ref.watch(crashDetectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency SOS',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Emergency contacts',
            icon: const Icon(LucideIcons.users),
            onPressed: () => context.push('/sos/contacts'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              primary == null
                  ? 'No emergency contact yet'
                  : 'Hold to call ${primary.name}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: HoldSosButton(onTriggered: () => _callPrimary(primary)),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              icon: const Icon(LucideIcons.messageSquare, size: 18),
              label: const Text('Send my location by SMS'),
              onPressed: () => _previewSms(contacts),
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                secondary: const Icon(LucideIcons.carFront),
                title: const Text(
                  'Crash detection',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'A hard knock starts a 10 second countdown, then calls '
                  'your contact. Works while the app is open.',
                ),
                value: crashOn,
                onChanged: (on) =>
                    ref.read(crashDetectionProvider.notifier).change(on),
              ),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              icon: const Icon(LucideIcons.timer, size: 18),
              label: const Text('Test crash countdown'),
              onPressed: () => context.push('/sos/countdown'),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(LucideIcons.info, color: sev.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        contacts.isEmpty
                            ? 'Add at least one emergency contact so SOS can work.'
                            : 'SMS goes to all ${contacts.length} of your contacts '
                                  'with a map link to where you are.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
