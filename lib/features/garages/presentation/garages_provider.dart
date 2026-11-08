import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/location_service.dart';
import '../data/garage_repository.dart';
import '../domain/garage.dart';

class NearbyGarages {
  const NearbyGarages({required this.me, required this.garages});

  final LatLng me;
  final List<Garage> garages;
}

// Location first, then garages around it.
// retry is off so a denied permission doesn't get asked again and again.
final nearbyGaragesProvider = FutureProvider<NearbyGarages>((ref) async {
  final me = await ref.read(locationServiceProvider).current();
  final garages = await ref.read(garageRepositoryProvider).nearby(me);
  return NearbyGarages(me: me, garages: garages);
}, retry: (_, _) => null);

// Garage currently highlighted on the map.
class SelectedGarageNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedGarageProvider =
    NotifierProvider<SelectedGarageNotifier, String?>(
      SelectedGarageNotifier.new,
    );
