import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/severity.dart';
import '../../../core/theme/severity_colors.dart';
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
  // null means all categories
  LightCategory? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lights = ref.watch(warningLightsProvider);
    final sev = context.severity;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Icon library',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: sev.safeTint,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'Works offline',
              style: TextStyle(
                color: sev.safe,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: lights.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Could not load the light list.')),
        data: (all) {
          final shown = all
              .where((l) => _category == null || l.category == _category)
              .where((l) => l.matches(_query))
              .toList();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                sliver: SliverList.list(
                  children: [
                    TextField(
                      controller: _search,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Search e.g. battery, brake',
                        prefixIcon: const Icon(LucideIcons.search, size: 18),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear',
                                icon: const Icon(LucideIcons.x, size: 18),
                                onPressed: () {
                                  _search.clear();
                                  setState(() => _query = '');
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _CategoryChip(
                          label: 'All',
                          selected: _category == null,
                          onTap: () => setState(() => _category = null),
                        ),
                        for (final c in LightCategory.values)
                          _CategoryChip(
                            label: c.label,
                            selected: _category == c,
                            onTap: () => setState(() => _category = c),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (shown.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _NoResults(),
                )
              else
                SliverPadding(
                  // bottom space for the phone's gesture bar
                  padding: EdgeInsets.fromLTRB(
                    18,
                    0,
                    18,
                    24 + MediaQuery.paddingOf(context).bottom,
                  ),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.88,
                        ),
                    itemCount: shown.length,
                    itemBuilder: (context, i) => _LightTile(light: shown[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: selected ? colors.primary : colors.surfaceContainerLowest,
      shape: StadiumBorder(
        side: selected
            ? BorderSide.none
            : BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? colors.onPrimary : colors.onSurface,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _LightTile extends StatelessWidget {
  const _LightTile({required this.light});

  final WarningLight light;

  static const _fontSize = 12.0;
  static const _lineHeight = 1.3;

  @override
  Widget build(BuildContext context) {
    // room for two lines of name, so one line and two line tiles match
    final nameHeight =
        MediaQuery.textScalerOf(context).scale(_fontSize) * _lineHeight * 2;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => context.push('/library/${light.id}'),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LightIcon(light: light),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: nameHeight,
                      child: Text(
                        light.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: _fontSize,
                          height: _lineHeight,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: light.severity.color(context),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
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
    return Padding(
      padding: const EdgeInsets.all(32),
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
