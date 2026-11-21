import 'garage.dart';
import 'opening_hours.dart';

const nearestMeters = 2000;

class GarageFilter {
  const GarageFilter({
    this.query = '',
    this.nearest = false,
    this.openNow = false,
    this.tyreShops = false,
  });

  final String query;
  final bool nearest;
  final bool openNow;
  final bool tyreShops;

  GarageFilter copyWith({
    String? query,
    bool? nearest,
    bool? openNow,
    bool? tyreShops,
  }) {
    return GarageFilter(
      query: query ?? this.query,
      nearest: nearest ?? this.nearest,
      openNow: openNow ?? this.openNow,
      tyreShops: tyreShops ?? this.tyreShops,
    );
  }

  List<Garage> apply(List<Garage> garages, DateTime now) {
    final words = query.trim().toLowerCase();

    return garages.where((g) {
      if (nearest && g.distanceMeters > nearestMeters) return false;
      if (tyreShops && !g.isTyreShop) return false;
      if (openNow && isOpenAt(g.openingHours, now) != true) return false;
      if (words.isEmpty) return true;
      final text = '${g.name} ${g.address ?? ''}'.toLowerCase();
      return text.contains(words);
    }).toList();
  }
}
