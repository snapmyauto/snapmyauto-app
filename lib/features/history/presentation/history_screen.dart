import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/severity.dart';
import '../../../core/utils/l10n.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/data/auth_repository.dart';
import '../../scan/data/scan_repository.dart';
import '../../scan/data/scan_results.dart';
import '../../scan/domain/scan_record.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../domain/history_filter.dart';
import 'widgets/scan_tile.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _search = TextEditingController();
  var _filter = const HistoryFilter();
  // swiped away but not deleted yet, so undo can bring them back
  final _hidden = <String>{};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setFilter(HistoryFilter filter) => setState(() => _filter = filter);

  void _clearFilters() {
    _search.clear();
    _setFilter(const HistoryFilter());
  }

  Future<void> _delete(ScanRecord scan) async {
    setState(() => _hidden.add(scan.id));
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final reason = await messenger
        .showSnackBar(
          SnackBar(
            content: Text(l10n.historyDeleted),
            action: SnackBarAction(label: l10n.historyUndo, onPressed: () {}),
          ),
        )
        .closed;

    if (reason == SnackBarClosedReason.action) {
      if (mounted) setState(() => _hidden.remove(scan.id));
      return;
    }
    final uid = ref.read(currentUidProvider);
    if (uid != null) {
      await ref.read(scanRepositoryProvider).delete(uid, scan.id);
    }
    _hidden.remove(scan.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scans = ref.watch(scansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.historyTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [_VehicleFilter(filter: _filter, onChanged: _setFilter)],
      ),
      body: scans.when(
        loading: () => const LoadingState(),
        error: (_, _) =>
            ErrorState(onRetry: () => ref.invalidate(scansProvider)),
        data: (all) {
          if (all.isEmpty) {
            return EmptyState(
              icon: LucideIcons.history,
              title: l10n.historyEmptyTitle,
              message: l10n.historyEmptyBody,
              actionLabel: l10n.navScan,
              actionIcon: LucideIcons.scanLine,
              onAction: () => context.push('/scan'),
            );
          }
          return _list(all);
        },
      ),
    );
  }

  Widget _list(List<ScanRecord> all) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final shown = [
      for (final scan in all)
        if (!_hidden.contains(scan.id) &&
            _filter.matches(scan, ref.watch(scanResultProvider(scan.id))))
          scan,
    ];

    final groups = <DateGroup, List<ScanRecord>>{};
    for (final scan in shown) {
      groups.putIfAbsent(groupFor(scan.createdAt, now), () => []).add(scan);
    }

    String groupName(DateGroup g) => switch (g) {
      DateGroup.today => l10n.groupToday,
      DateGroup.yesterday => l10n.groupYesterday,
      DateGroup.thisWeek => l10n.groupThisWeek,
      DateGroup.older => l10n.groupOlder,
    };

    return ListView(
      // room at the bottom for the glass bar
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 130),
      children: [
        TextField(
          controller: _search,
          onChanged: (v) => _setFilter(_filter.copyWith(query: v)),
          decoration: InputDecoration(
            hintText: l10n.historySearch,
            prefixIcon: const Icon(LucideIcons.search, size: 18),
          ),
        ),
        const SizedBox(height: 12),
        _SeverityChips(
          selected: _filter.severity,
          onChanged: (s) => _setFilter(_filter.copyWith(severity: () => s)),
        ),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: EmptyState(
              icon: LucideIcons.searchX,
              title: l10n.historyNoMatch,
              message: l10n.historyNoMatchBody,
              actionLabel: l10n.historyClearFilters,
              onAction: _clearFilters,
            ),
          ),
        for (final group in DateGroup.values)
          if (groups[group] case final list?) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
              child: Text(
                groupName(group),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            for (final scan in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Dismissible(
                  key: ValueKey(scan.id),
                  direction: DismissDirection.endToStart,
                  background: const _DeleteBackground(),
                  onDismissed: (_) => _delete(scan),
                  child: ScanTile(scan: scan),
                ),
              ),
          ],
      ],
    );
  }
}

class _VehicleFilter extends ConsumerWidget {
  const _VehicleFilter({required this.filter, required this.onChanged});

  final HistoryFilter filter;
  final ValueChanged<HistoryFilter> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider).value ?? const [];
    if (vehicles.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final selected = vehicles.where((v) => v.id == filter.vehicleId);
    final label = selected.isEmpty
        ? l10n.historyAllVehicles
        : selected.first.displayName;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      // '' means all cars, a null value would count as closing the menu
      child: PopupMenuButton<String>(
        initialValue: filter.vehicleId ?? '',
        onSelected: (id) =>
            onChanged(filter.copyWith(vehicleId: () => id.isEmpty ? null : id)),
        itemBuilder: (context) => [
          PopupMenuItem(value: '', child: Text(l10n.historyAllVehicles)),
          for (final v in vehicles)
            PopupMenuItem(value: v.id, child: Text(v.displayName)),
        ],
        child: Chip(
          avatar: const Icon(LucideIcons.carFront, size: 16),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: 4),
              const Icon(LucideIcons.chevronDown, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeverityChips extends StatelessWidget {
  const _SeverityChips({required this.selected, required this.onChanged});

  final Severity? selected;
  final ValueChanged<Severity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text(context.l10n.historyAll),
          selected: selected == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final s in [Severity.stop, Severity.soon, Severity.safe])
          ChoiceChip(
            avatar: CircleAvatar(radius: 4, backgroundColor: s.color(context)),
            label: Text(s.label),
            selected: selected == s,
            onSelected: (on) => onChanged(on ? s : null),
          ),
      ],
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.trash2, color: colors.onErrorContainer),
          const SizedBox(width: 6),
          Text(
            context.l10n.historyDelete,
            style: TextStyle(
              color: colors.onErrorContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
