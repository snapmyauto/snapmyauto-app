import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/severity_colors.dart';
import '../../../core/utils/location_service.dart';
import '../data/garage_repository.dart';
import '../domain/garage.dart';
import 'garage_detail_sheet.dart';
import 'garages_provider.dart';

class GaragesScreen extends ConsumerStatefulWidget {
  const GaragesScreen({super.key});

  @override
  ConsumerState<GaragesScreen> createState() => _GaragesScreenState();
}

class _GaragesScreenState extends ConsumerState<GaragesScreen> {
  final _map = MapController();

  void _refresh() {
    ref.read(selectedGarageProvider.notifier).select(null);
    ref.invalidate(nearbyGaragesProvider);
  }

  void _openGarage(Garage garage) {
    ref.read(selectedGarageProvider.notifier).select(garage.id);
    _map.move(garage.location, 15);
    showGarageDetail(context, garage);
  }

  @override
  Widget build(BuildContext context) {
    final nearby = ref.watch(nearbyGaragesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Garages nearby',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: nearby.isLoading ? null : _refresh,
          ),
        ],
      ),
      body: nearby.when(
        loading: () => const _Loading(),
        error: (e, _) => _errorView(e),
        data: (data) {
          if (data.garages.isEmpty) {
            return _StateMessage(
              icon: LucideIcons.searchX,
              title: 'No garages found',
              message: 'We couldn\'t find any garages within 5 km of you.',
              actionLabel: 'Try again',
              onAction: _refresh,
            );
          }
          return Column(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.38,
                child: _GarageMap(
                  controller: _map,
                  data: data,
                  onTapGarage: _openGarage,
                ),
              ),
              Expanded(
                child: _GarageList(
                  garages: data.garages,
                  onTapGarage: _openGarage,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _errorView(Object error) {
    if (error is LocationException) {
      final service = ref.read(locationServiceProvider);
      return switch (error.problem) {
        LocationProblem.serviceOff => _StateMessage(
          icon: LucideIcons.mapPinOff,
          title: 'Location is turned off',
          message: 'Turn on location so we can find garages near you.',
          actionLabel: 'Open settings',
          onAction: () => service.openSettings(error.problem),
          secondaryLabel: 'Try again',
          onSecondary: _refresh,
        ),
        LocationProblem.denied => _StateMessage(
          icon: LucideIcons.mapPinOff,
          title: 'Location permission needed',
          message: 'SnapMyAuto needs your location to show nearby garages.',
          actionLabel: 'Allow location',
          onAction: _refresh,
        ),
        LocationProblem.deniedForever => _StateMessage(
          icon: LucideIcons.mapPinOff,
          title: 'Location permission blocked',
          message: 'Allow location for SnapMyAuto in your phone settings.',
          actionLabel: 'Open settings',
          onAction: () => service.openSettings(error.problem),
          secondaryLabel: 'Try again',
          onSecondary: _refresh,
        ),
      };
    }
    if (error is GarageLoadException && error.offline) {
      return _StateMessage(
        icon: LucideIcons.wifiOff,
        title: 'You\'re offline',
        message: 'Connect to the internet to load garages near you.',
        actionLabel: 'Try again',
        onAction: _refresh,
      );
    }
    return _StateMessage(
      icon: LucideIcons.triangleAlert,
      title: 'Something went wrong',
      message: 'We couldn\'t load garages right now. Please try again.',
      actionLabel: 'Try again',
      onAction: _refresh,
    );
  }
}

class _GarageMap extends ConsumerWidget {
  const _GarageMap({
    required this.controller,
    required this.data,
    required this.onTapGarage,
  });

  final MapController controller;
  final NearbyGarages data;
  final ValueChanged<Garage> onTapGarage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final selectedId = ref.watch(selectedGarageProvider);

    return FlutterMap(
      mapController: controller,
      options: MapOptions(initialCenter: data.me, initialZoom: 13.5),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.snapmyauto.snapmyauto',
        ),
        MarkerLayer(
          markers: [
            for (final g in data.garages)
              Marker(
                point: g.location,
                width: 40,
                height: 40,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => onTapGarage(g),
                  child: Icon(
                    Icons.location_on,
                    size: g.id == selectedId ? 40 : 34,
                    color: g.id == selectedId
                        ? context.brand.fill
                        : scheme.primary,
                  ),
                ),
              ),
            Marker(
              point: data.me,
              width: 22,
              height: 22,
              child: Container(
                decoration: BoxDecoration(
                  color: context.severity.info,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.surface, width: 3),
                ),
              ),
            ),
          ],
        ),
        const SimpleAttributionWidget(source: Text('OpenStreetMap')),
      ],
    );
  }
}

class _GarageList extends ConsumerWidget {
  const _GarageList({required this.garages, required this.onTapGarage});

  final List<Garage> garages;
  final ValueChanged<Garage> onTapGarage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selectedId = ref.watch(selectedGarageProvider);

    return ListView.separated(
      // Bottom padding keeps the last item above the glass nav bar.
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 170),
      itemCount: garages.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Text(
            '${garages.length} garages within 5 km',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          );
        }
        final g = garages[i - 1];
        final selected = g.id == selectedId;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: selected
                ? BorderSide(color: scheme.primary, width: 2)
                : BorderSide(color: scheme.outlineVariant),
          ),
          child: ListTile(
            onTap: () => onTapGarage(g),
            leading: CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: const Icon(LucideIcons.wrench, size: 20),
            ),
            title: Text(
              g.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              g.address ?? (g.phone != null ? g.phone! : 'No details listed'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              g.distanceText,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Finding garages near you...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: scheme.primaryContainer,
              child: Icon(icon, size: 32, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
            if (secondaryLabel != null) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
