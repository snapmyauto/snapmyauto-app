import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vehicles/data/vehicle_repository.dart';

class VehicleChips extends ConsumerWidget {
  const VehicleChips({
    super.key,
    required this.selectedId,
    required this.onChanged,
  });

  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider).value ?? const [];
    if (vehicles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Which car is this?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in vehicles)
              ChoiceChip(
                label: Text(v.displayName),
                selected: v.id == selectedId,
                onSelected: (on) => onChanged(on ? v.id : null),
              ),
            ChoiceChip(
              label: const Text('Other car'),
              selected: selectedId == null,
              onSelected: (_) => onChanged(null),
            ),
          ],
        ),
      ],
    );
  }
}
