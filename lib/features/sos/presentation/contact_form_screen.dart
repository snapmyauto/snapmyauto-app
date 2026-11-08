import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_repository.dart';
import '../data/contact_repository.dart';
import '../domain/emergency_contact.dart';

// Used for both adding (contact == null) and editing.
class ContactFormScreen extends ConsumerStatefulWidget {
  const ContactFormScreen({super.key, this.contact});

  final EmergencyContact? contact;

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.contact?.name);
  late final _phone = TextEditingController(text: widget.contact?.phone);
  late final _relation = TextEditingController(text: widget.contact?.relation);
  late bool _primary = widget.contact?.isPrimary ?? false;
  bool _saving = false;

  bool get _isEdit => widget.contact != null;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _relation.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (digits.isEmpty) return 'Enter a phone number';
    if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(digits)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    setState(() => _saving = true);
    final repo = ref.read(contactRepositoryProvider);
    final existing = ref.read(contactsProvider).value ?? [];
    final relation = _relation.text.trim();

    final contact = EmergencyContact(
      id: widget.contact?.id ?? '',
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      relation: relation.isEmpty ? null : relation,
      // isPrimary is handled by setPrimary below.
      isPrimary: widget.contact?.isPrimary ?? false,
    );

    try {
      final saved = _isEdit ? contact : await repo.add(uid, contact);
      if (_isEdit) await repo.update(uid, contact);

      // The very first contact becomes primary automatically.
      final makePrimary = _primary || existing.isEmpty;
      if (makePrimary && !contact.isPrimary) {
        await repo.setPrimary(uid, saved.id);
      }
      if (mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit contact' : 'Add contact')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '0771234567',
                border: OutlineInputBorder(),
              ),
              validator: _validatePhone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _relation,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Relation (optional)',
                hintText: 'Father, friend, mechanic...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            if (!(widget.contact?.isPrimary ?? false))
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Primary contact'),
                subtitle: const Text('Called first when you press SOS'),
                value: _primary,
                onChanged: (v) => setState(() => _primary = v),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
