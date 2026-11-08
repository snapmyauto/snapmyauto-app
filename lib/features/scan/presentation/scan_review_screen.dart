import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/severity.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/severity_badge.dart';
import '../../../core/widgets/state_views.dart';
import '../../icon_library/data/warning_light_repository.dart';
import '../../icon_library/domain/warning_light.dart';
import '../../icon_library/presentation/widgets/light_visuals.dart';
import '../../triage/domain/triage_result.dart';
import '../domain/scan_draft.dart';
import '../domain/scan_record.dart';
import 'widgets/detection_photo.dart';

const _unsureBelow = 0.6;

class _Item {
  _Item(this.light, this.alternatives);

  ScanLight light;
  final List<String> alternatives;
  bool included = true;

  bool get unsure => light.score < _unsureBelow;
}

class ScanReviewScreen extends ConsumerStatefulWidget {
  const ScanReviewScreen({super.key, required this.draft});

  final ScanDraft draft;

  @override
  ConsumerState<ScanReviewScreen> createState() => _ScanReviewScreenState();
}

class _ScanReviewScreenState extends ConsumerState<ScanReviewScreen> {
  late final List<_Item> _items = [
    for (final d in widget.draft.result.detections)
      _Item(
        ScanLight.fromDetection(
          d,
          widget.draft.result.imageWidth,
          widget.draft.result.imageHeight,
        ),
        d.alternatives,
      ),
  ];

  List<ScanLight> get _kept => [
    for (final item in _items)
      if (item.included) item.light,
  ];

  void _setLabel(_Item item, String label) {
    setState(() {
      item.light = item.light.copyWith(label: label);
      item.included = true;
    });
  }

  Future<void> _change(_Item item, List<WarningLight> library) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          _LightPicker(library: library, current: item.light.label),
    );
    if (picked != null) _setLabel(item, picked);
  }

  // temp: feat/save-scans saves the scan and opens the triage result
  void _continue(List<WarningLight> library) {
    final result = TriageResult.fromLabels(_kept.map((l) => l.label), library);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SeverityBadge(severity: result.severity),
            const SizedBox(height: 12),
            Text(
              result.worstLight?.name ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(result.worstLight?.driveNote ?? ''),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lights = ref.watch(warningLightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review detection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text('Step 1 of 3', style: TextStyle(fontSize: 12)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: const LinearProgressIndicator(value: 1 / 3, minHeight: 6),
            ),
          ),
        ),
      ),
      body: lights.when(
        loading: () => const LoadingState(),
        error: (_, _) => ErrorState(
          message: 'Could not load the light list.',
          onRetry: () => ref.invalidate(warningLightsProvider),
        ),
        data: _body,
      ),
    );
  }

  Widget _body(List<WarningLight> library) {
    final byId = {for (final l in library) l.id: l};
    final draft = widget.draft;
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            children: [
              DetectionPhoto(
                photo: draft.photo,
                width: draft.result.imageWidth,
                height: draft.result.imageHeight,
                onRetake: () => context.pop(),
                boxes: [
                  for (final (i, item) in _items.indexed)
                    PhotoBox(
                      rect: Rect.fromLTRB(
                        item.light.left,
                        item.light.top,
                        item.light.right,
                        item.light.bottom,
                      ),
                      tag: '${i + 1} · ${_percent(item.light.score)}',
                      color:
                          byId[item.light.label]?.severity.color(context) ??
                          colors.primary,
                      active: item.included,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _items.length == 1
                          ? '1 warning light found'
                          : '${_items.length} warning lights found',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    'Tap to include',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final (i, item) in _items.indexed) ...[
                _LightRow(
                  number: i + 1,
                  item: item,
                  byId: byId,
                  onToggle: () =>
                      setState(() => item.included = !item.included),
                  onChange: () => _change(item, library),
                  onPick: (label) => _setLabel(item, label),
                ),
                const SizedBox(height: 10),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.push('/library'),
                  icon: const Icon(LucideIcons.bookOpen, size: 16),
                  label: const Text('Not right? Find it in the icon library'),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: PrimaryButton(
              label: 'Continue',
              onPressed: _kept.isEmpty ? null : () => _continue(library),
            ),
          ),
        ),
      ],
    );
  }
}

class _LightRow extends StatelessWidget {
  const _LightRow({
    required this.number,
    required this.item,
    required this.byId,
    required this.onToggle,
    required this.onChange,
    required this.onPick,
  });

  final int number;
  final _Item item;
  final Map<String, WarningLight> byId;
  final VoidCallback onToggle;
  final VoidCallback onChange;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final light = byId[item.light.label];
    final options = item.alternatives.where(byId.containsKey).toList();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: item.included
            ? BorderSide(color: colors.primary, width: 2)
            : BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (light != null) ...[
                    LightIcon(light: light, size: 44),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$number. ${light?.name ?? item.light.label}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (light != null)
                          Text(
                            light.severity.lightColour,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _Check(on: item.included),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Confidence',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: item.light.score,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _percent(item.light.score),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              if (item.unsure && options.length > 1) ...[
                const SizedBox(height: 12),
                const Text(
                  'Not sure, is it one of these?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final id in options)
                      ChoiceChip(
                        label: Text(byId[id]!.name),
                        selected: id == item.light.label,
                        onSelected: (_) => onPick(id),
                      ),
                  ],
                ),
              ],
              TextButton.icon(
                onPressed: onChange,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 44),
                ),
                icon: const Icon(LucideIcons.pencil, size: 16),
                label: const Text('Change light'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      label: on ? 'Included' : 'Not included',
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: on ? colors.primary : null,
          border: on ? null : Border.all(color: colors.outline, width: 2),
        ),
        child: on
            ? Icon(LucideIcons.check, size: 16, color: colors.onPrimary)
            : null,
      ),
    );
  }
}

class _LightPicker extends StatelessWidget {
  const _LightPicker({required this.library, required this.current});

  final List<WarningLight> library;
  final String current;

  @override
  Widget build(BuildContext context) {
    final options = library.where((l) => l.detectable).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Which light is it?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          for (final light in options)
            ListTile(
              leading: LightIcon(light: light, size: 40),
              title: Text(
                light.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: light.id == current
                  ? const Icon(LucideIcons.check, size: 20)
                  : null,
              onTap: () => Navigator.pop(context, light.id),
            ),
        ],
      ),
    );
  }
}

String _percent(double score) => '${(score * 100).round()}%';
