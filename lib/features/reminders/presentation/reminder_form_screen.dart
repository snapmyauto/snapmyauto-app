import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../vehicles/data/vehicle_repository.dart';
import '../data/reminder_actions.dart';
import '../data/reminder_repository.dart';
import '../domain/reminder.dart';
import 'widgets/reminder_type_ui.dart';

// new reminder when reminderId is null, otherwise edit
class ReminderFormScreen extends ConsumerStatefulWidget {
  const ReminderFormScreen({super.key, this.reminderId});

  final String? reminderId;

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _notes = TextEditingController();

  Reminder? _old;
  ReminderType _type = ReminderType.service;
  DateTime _due = DateTime.now().add(const Duration(days: 30));
  String? _vehicleId;
  int? _repeat;
  bool _saving = false;

  static const _repeatOptions = [null, 1, 3, 6, 12];

  @override
  void initState() {
    super.initState();
    final id = widget.reminderId;
    final all = ref.read(remindersProvider).value ?? const <Reminder>[];
    for (final r in all) {
      if (r.id == id) _old = r;
    }
    final old = _old;
    if (old == null) {
      _title.text = _type.label;
      return;
    }
    _type = old.type;
    _title.text = old.title;
    _notes.text = old.notes ?? '';
    _due = old.dueDate;
    _vehicleId = old.vehicleId;
    _repeat = old.repeatMonths;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _changeType(ReminderType type) {
    // keep a custom title, but swap the default one
    final usedDefault = ReminderType.values.any((t) => t.label == _title.text);
    setState(() {
      _type = type;
      if (_title.text.isEmpty || usedDefault) _title.text = type.label;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _due = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final notes = _notes.text.trim();
    final reminder = Reminder(
      id: _old?.id ?? '',
      title: _title.text.trim(),
      type: _type,
      dueDate: _due,
      vehicleId: _vehicleId,
      repeatMonths: _repeat,
      notes: notes.isEmpty ? null : notes,
      done: _old?.done ?? false,
    );

    try {
      await ref.read(reminderActionsProvider).save(reminder);
      if (mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saving failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(vehiclesProvider).value ?? const [];
    // a deleted car should not break the dropdown
    final vehicleValue = vehicles.any((v) => v.id == _vehicleId)
        ? _vehicleId
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_old == null ? 'New reminder' : 'Edit reminder'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<ReminderType>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final t in ReminderType.values)
                  DropdownMenuItem(
                    value: t,
                    child: Row(
                      children: [
                        Icon(t.icon, size: 18),
                        const SizedBox(width: 10),
                        Text(t.label),
                      ],
                    ),
                  ),
              ],
              onChanged: (t) => _changeType(t ?? ReminderType.other),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Please add a title' : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Due date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(LucideIcons.calendar),
                ),
                child: Text(shortDate(_due)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: vehicleValue,
              decoration: const InputDecoration(
                labelText: 'Vehicle',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('No vehicle')),
                for (final v in vehicles)
                  DropdownMenuItem(value: v.id, child: Text(v.displayName)),
              ],
              onChanged: (id) => setState(() => _vehicleId = id),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _repeatOptions.contains(_repeat) ? _repeat : null,
              decoration: const InputDecoration(
                labelText: 'Repeat',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final m in _repeatOptions)
                  DropdownMenuItem(
                    value: m,
                    child: Text(
                      m == null
                          ? 'Doesn\'t repeat'
                          : m == 1
                          ? 'Every month'
                          : 'Every $m months',
                    ),
                  ),
              ],
              onChanged: (m) => setState(() => _repeat = m),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll get a notification on the due date at 9:00 AM.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
