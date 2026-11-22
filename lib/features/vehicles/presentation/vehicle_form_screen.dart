import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_repository.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';
import 'vehicle_providers.dart';
import 'widgets/fuel_type_ui.dart';

/// Add a new vehicle, or edit one when [vehicleId] is given.
class VehicleFormScreen extends ConsumerStatefulWidget {
  const VehicleFormScreen({super.key, this.vehicleId});

  final String? vehicleId;

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _nickname = TextEditingController();
  final _plate = TextEditingController();
  final _odometer = TextEditingController();

  FuelType _fuel = FuelType.petrol;
  VehicleType _type = VehicleType.car;
  Transmission _transmission = Transmission.automatic;
  Vehicle? _editing;
  bool _saving = false;

  int get _maxYear => DateTime.now().year + 1;

  @override
  void initState() {
    super.initState();
    final id = widget.vehicleId;
    if (id == null) return;

    final vehicle = ref.read(vehicleByIdProvider(id)).value;
    if (vehicle == null) return;
    _editing = vehicle;
    _make.text = vehicle.make;
    _model.text = vehicle.model;
    _year.text = '${vehicle.year}';
    _nickname.text = vehicle.nickname ?? '';
    _plate.text = vehicle.plate ?? '';
    _odometer.text = vehicle.odometerKm?.toString() ?? '';
    _fuel = vehicle.fuelType;
    _type = vehicle.type;
    _transmission = vehicle.transmission;
  }

  @override
  void dispose() {
    for (final c in [_make, _model, _year, _nickname, _plate, _odometer]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? value, String field) {
    return (value ?? '').trim().isEmpty ? 'Enter the $field' : null;
  }

  String? _validateYear(String? value) {
    final year = int.tryParse((value ?? '').trim());
    if (year == null) return 'Enter the year';
    if (year < 1980 || year > _maxYear) {
      return 'Year must be between 1980 and $_maxYear';
    }
    return null;
  }

  String? _optional(String text) => text.trim().isEmpty ? null : text.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    setState(() => _saving = true);
    final vehicle = Vehicle(
      id: _editing?.id ?? '',
      make: _make.text.trim(),
      model: _model.text.trim(),
      year: int.parse(_year.text.trim()),
      nickname: _optional(_nickname.text),
      plate: _optional(_plate.text)?.toUpperCase(),
      fuelType: _fuel,
      type: _type,
      transmission: _transmission,
      odometerKm: int.tryParse(_odometer.text.trim()),
    );

    final repo = ref.read(vehicleRepositoryProvider);
    try {
      if (_editing == null) {
        await repo.add(uid, vehicle);
      } else {
        await repo.update(uid, vehicle);
      }
      if (mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the vehicle. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _editing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit vehicle' : 'Add vehicle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Vehicle type', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in VehicleType.values)
                  ChoiceChip(
                    avatar: Icon(type.icon, size: 16),
                    label: Text(type.label),
                    selected: _type == type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    controller: _make,
                    label: 'Make',
                    hint: 'Toyota',
                    validator: (v) => _required(v, 'make'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    controller: _model,
                    label: 'Model',
                    hint: 'Aqua',
                    validator: (v) => _required(v, 'model'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _field(
              controller: _year,
              label: 'Year',
              hint: '2018',
              keyboard: TextInputType.number,
              digitsOnly: true,
              validator: _validateYear,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _nickname,
              label: 'Nickname (optional)',
              hint: 'My daily car',
            ),
            const SizedBox(height: 16),
            _field(
              controller: _plate,
              label: 'Number plate (optional)',
              hint: 'CAB-1234',
              caps: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _odometer,
              label: 'Odometer (km, optional)',
              hint: '85000',
              keyboard: TextInputType.number,
              digitsOnly: true,
            ),
            const SizedBox(height: 20),
            Text('Fuel type', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in FuelType.values)
                  ChoiceChip(
                    avatar: Icon(type.icon, size: 16),
                    label: Text(type.label),
                    selected: _fuel == type,
                    onSelected: (_) => setState(() => _fuel = type),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Transmission', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<Transmission>(
              segments: [
                for (final t in Transmission.values)
                  ButtonSegment(value: t, label: Text(t.label)),
              ],
              selected: {_transmission},
              onSelectionChanged: (picked) =>
                  setState(() => _transmission = picked.first),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Save changes' : 'Add vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboard,
    bool digitsOnly = false,
    TextCapitalization caps = TextCapitalization.words,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      textCapitalization: caps,
      textInputAction: TextInputAction.next,
      inputFormatters: digitsOnly
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
