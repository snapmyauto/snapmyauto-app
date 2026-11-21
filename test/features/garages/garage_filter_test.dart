import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:snapmyauto/features/garages/domain/garage.dart';
import 'package:snapmyauto/features/garages/domain/garage_filter.dart';
import 'package:snapmyauto/features/garages/domain/opening_hours.dart';

Garage garage(
  String name, {
  double meters = 500,
  String? hours,
  bool tyres = false,
  String? address,
}) {
  return Garage(
    id: name,
    name: name,
    location: const LatLng(6.9, 79.9),
    distanceMeters: meters,
    openingHours: hours,
    isTyreShop: tyres,
    address: address,
  );
}

void main() {
  // a wednesday
  final wedNoon = DateTime(2026, 11, 18, 12);
  final wedNight = DateTime(2026, 11, 18, 22);
  final sunday = DateTime(2026, 11, 22, 10);

  test('reads simple opening hours', () {
    const hours = 'Mo-Fr 08:00-18:00; Sa 08:00-13:00; Su off';
    expect(isOpenAt(hours, wedNoon), true);
    expect(isOpenAt(hours, wedNight), false);
    expect(isOpenAt(hours, sunday), false);
    expect(isOpenAt('24/7', sunday), true);
    expect(isOpenAt('08:00-12:00,13:00-17:00', wedNoon), false);
    expect(isOpenAt('Tu-Th 18:00-02:00', wedNight), true);
  });

  test('unknown or odd hours give null', () {
    expect(isOpenAt(null, wedNoon), null);
    expect(isOpenAt('by appointment', wedNoon), null);
  });

  test('filters by search, distance, hours and type', () {
    final list = [
      garage('Lanka Motors', meters: 800, hours: 'Mo-Sa 08:00-17:00'),
      garage('Tyre House', meters: 1500, tyres: true),
      garage('Far Garage', meters: 4200, address: 'Galle Road'),
    ];

    expect(const GarageFilter().apply(list, wedNoon).length, 3);
    expect(
      const GarageFilter(query: 'galle').apply(list, wedNoon).single.name,
      'Far Garage',
    );
    expect(const GarageFilter(nearest: true).apply(list, wedNoon).length, 2);
    expect(
      const GarageFilter(openNow: true).apply(list, wedNoon).single.name,
      'Lanka Motors',
    );
    expect(
      const GarageFilter(tyreShops: true).apply(list, wedNoon).single.name,
      'Tyre House',
    );
  });
}
