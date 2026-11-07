import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/warning_light_repository.dart';
import '../domain/warning_light.dart';
import 'widgets/light_visuals.dart';

class IconLibraryScreen extends ConsumerStatefulWidget {
  const IconLibraryScreen({super.key});

  @override
  ConsumerState<IconLibraryScreen> createState() => _IconLibraryScreenState();
}

class _IconLibraryScreenState extends ConsumerState<IconLibraryScreen> {
  final _search = TextEditingController();
  String _query = '';
  LightSeverity? _filter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<WarningLight> _visible(List<WarningLight> all) {
    return all
        .where((l) => _filter == null || l.severity == _filter)
        .where((l) => l.matches(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final lights = ref.watch(warningLightsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Warning lights')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search lights',
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip(null, 'All'),
                for (final s in LightSeverity.values) _chip(s, s.label),
              ],
            ),
          ),
          Expanded(
            child: lights.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) =>
                  const Center(child: Text('Could not load the light list.')),
              data: (all) {
                final shown = _visible(all);
                if (shown.isEmpty) return const _NoResults();
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: shown.length,
                  itemBuilder: (context, i) => _LightTile(light: shown[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(LightSeverity? severity, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: severity == null
            ? null
            : Icon(severity.icon, size: 16, color: severity.color(context)),
        label: Text(label),
        selected: _filter == severity,
        showCheckmark: false,
        onSelected: (_) => setState(() => _filter = severity),
      ),
    );
  }
}

class _LightTile extends StatelessWidget {
  const _LightTile({required this.light});

  final WarningLight light;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/library/${light.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LightIconCircle(light: light),
              const SizedBox(height: 10),
              Text(
                light.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              SeverityBadge(severity: light.severity),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.searchX,
            size: 44,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No lights match your search',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
