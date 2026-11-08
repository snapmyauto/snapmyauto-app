import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/severity_colors.dart';
import '../../../../core/widgets/app_button.dart';

enum ScanFailedAction { retry, pickPhoto }

class ScanFailedSheet extends StatelessWidget {
  const ScanFailedSheet({super.key});

  static Future<ScanFailedAction?> show(BuildContext context) {
    return showModalBottomSheet<ScanFailedAction>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const ScanFailedSheet(),
    );
  }

  static const _tips = [
    'Turn the ignition on so lights show',
    'Get closer, fill the frame with the cluster',
    'Avoid glare, tilt the phone slightly',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sev = context.severity;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: sev.soonTint,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(LucideIcons.searchX, color: sev.soon),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No warning light found',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "Let's try that again",
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    for (final (i, tip) in _tips.indexed)
                      Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 13,
                              backgroundColor: colors.primaryContainer,
                              foregroundColor: colors.onPrimaryContainer,
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Try again',
              icon: LucideIcons.scan,
              onPressed: () => Navigator.pop(context, ScanFailedAction.retry),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Pick a photo',
              icon: LucideIcons.image,
              onPressed: () =>
                  Navigator.pop(context, ScanFailedAction.pickPhoto),
            ),
          ],
        ),
      ),
    );
  }
}
