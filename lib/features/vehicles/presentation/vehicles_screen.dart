import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/vehicle_repository.dart';
import 'widgets/vehicle_card.dart';

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My vehicles')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vehicles/new'),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add vehicle'),
      ),
      body: vehicles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('Could not load your vehicles. Check your connection.'),
        ),
        data: (list) {
          if (list.isEmpty) return const _EmptyVehicles();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => VehicleCard(
              vehicle: list[i],
              onTap: () => context.push('/vehicles/${list[i].id}'),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyVehicles extends StatelessWidget {
  const _EmptyVehicles();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.carFront,
                size: 40,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add your first vehicle',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save your car so scans and reminders can be linked to it.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push('/vehicles/new'),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Add vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}
