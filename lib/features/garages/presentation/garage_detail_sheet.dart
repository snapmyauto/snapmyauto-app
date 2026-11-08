import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/garage.dart';

Future<void> showGarageDetail(BuildContext context, Garage garage) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (_) => GarageDetailSheet(garage: garage),
  );
}

class GarageDetailSheet extends StatelessWidget {
  const GarageDetailSheet({super.key, required this.garage});

  final Garage garage;

  Future<void> _open(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this on your phone')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final phone = garage.phone;
    final lat = garage.location.latitude;
    final lng = garage.location.longitude;

    Widget infoRow(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              garage.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${garage.distanceText} away',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            if (garage.address != null)
              infoRow(LucideIcons.mapPin, garage.address!),
            if (garage.openingHours != null)
              infoRow(LucideIcons.clock, garage.openingHours!),
            infoRow(LucideIcons.phone, phone ?? 'No phone number listed'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(LucideIcons.phone, size: 18),
                    label: const Text('Call'),
                    onPressed: phone == null
                        ? null
                        : () => _open(
                            context,
                            Uri(scheme: 'tel', path: phone.replaceAll(' ', '')),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(LucideIcons.navigation, size: 18),
                    label: const Text('Directions'),
                    onPressed: () => _open(
                      context,
                      Uri.parse(
                        'https://www.google.com/maps/dir/?api=1'
                        '&destination=$lat,$lng',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
