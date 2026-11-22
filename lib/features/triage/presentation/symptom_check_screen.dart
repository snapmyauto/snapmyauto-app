import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/app_button.dart';
import '../domain/symptom.dart';
import '../domain/triage_result.dart';

class SymptomCheckScreen extends StatefulWidget {
  // the scan result when coming from the result page, null from home
  final TriageResult? base;

  const SymptomCheckScreen({super.key, this.base});

  @override
  State<SymptomCheckScreen> createState() => _SymptomCheckScreenState();
}

class _SymptomCheckScreenState extends State<SymptomCheckScreen> {
  final Set<Symptom> _selected = {};
  bool _nothingUnusual = false;

  @override
  void initState() {
    super.initState();
    if (widget.base != null) {
      _selected.addAll(widget.base!.symptoms);
    }
  }

  bool _canContinue() {
    return _selected.isNotEmpty || _nothingUnusual;
  }

  void _onSymptomTap(Symptom symptom, bool selected) {
    setState(() {
      _nothingUnusual = false;
      if (selected) {
        _selected.add(symptom);
      } else {
        _selected.remove(symptom);
      }
    });
  }

  void _onNothingTap(bool selected) {
    setState(() {
      _nothingUnusual = selected;
      if (selected) {
        _selected.clear();
      }
    });
  }

  void _getResult() {
    final lights = widget.base?.lights ?? [];
    final result = TriageResult.from(lights, symptoms: _selected);
    // replace this page so back skips it
    context.pushReplacement('/triage', extra: result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Symptom check',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          const Text(
            'Did you notice any of these?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This helps us decide how serious it is. Pick all that apply.',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(spacing: 10, runSpacing: 10, children: _buildChips(theme)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 8, 18, 16),
        child: PrimaryButton(
          label: 'Get my result',
          icon: LucideIcons.arrowRight,
          onPressed: _canContinue() ? _getResult : null,
        ),
      ),
    );
  }

  List<Widget> _buildChips(ThemeData theme) {
    final chips = <Widget>[];

    for (final symptom in Symptom.values) {
      chips.add(
        _buildChip(
          theme,
          label: symptom.label,
          selected: _selected.contains(symptom),
          onSelected: (value) => _onSymptomTap(symptom, value),
        ),
      );
    }

    chips.add(
      _buildChip(
        theme,
        label: 'Nothing unusual',
        selected: _nothingUnusual,
        onSelected: _onNothingTap,
      ),
    );

    return chips;
  }

  Widget _buildChip(
    ThemeData theme, {
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    final colors = theme.colorScheme;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: true,
      checkmarkColor: colors.primary,
      selectedColor: colors.primaryContainer,
      backgroundColor: colors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
        color: selected ? colors.primary : colors.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    );
  }
}
