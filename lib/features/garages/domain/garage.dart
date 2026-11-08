import 'package:latlong2/latlong.dart';

class Garage {
  const Garage({
    required this.id,
    required this.name,
    required this.location,
    required this.distanceMeters,
    this.phone,
    this.address,
    this.openingHours,
  });

  final String id;
  final String name;
  final LatLng location;
  final double distanceMeters;
  final String? phone;
  final String? address;
  final String? openingHours;

  String get distanceText {
    if (distanceMeters < 1000) return '${distanceMeters.round()} m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  // ways come with a center point instead of lat/lon
  static Garage? fromOverpass(Map<String, dynamic> json, LatLng from) {
    final center = json['center'] as Map<String, dynamic>?;
    final lat = (json['lat'] ?? center?['lat']) as num?;
    final lon = (json['lon'] ?? center?['lon']) as num?;
    if (lat == null || lon == null) return null;

    final tags = (json['tags'] as Map?)?.cast<String, dynamic>() ?? {};
    final point = LatLng(lat.toDouble(), lon.toDouble());

    return Garage(
      id: '${json['type']}/${json['id']}',
      name: (tags['name'] as String?)?.trim().isNotEmpty == true
          ? tags['name'] as String
          : 'Unnamed garage',
      location: point,
      distanceMeters: const Distance().as(LengthUnit.Meter, from, point),
      phone: (tags['phone'] ?? tags['contact:phone']) as String?,
      address: _address(tags),
      openingHours: tags['opening_hours'] as String?,
    );
  }

  // nominatim sends lat/lon as text and the address as one long line
  static Garage? fromNominatim(Map<String, dynamic> json, LatLng from) {
    final lat = double.tryParse('${json['lat']}');
    final lon = double.tryParse('${json['lon']}');
    if (lat == null || lon == null) return null;

    final extra = (json['extratags'] as Map?)?.cast<String, dynamic>() ?? {};
    final name = (json['name'] as String?)?.trim() ?? '';
    final parts = (json['display_name'] as String? ?? '')
        .split(', ')
        .where((p) => p.trim().isNotEmpty)
        .toList();
    if (name.isNotEmpty && parts.isNotEmpty && parts.first == name) {
      parts.removeAt(0);
    }
    final point = LatLng(lat, lon);

    return Garage(
      id: '${json['osm_type']}/${json['osm_id']}',
      name: name.isEmpty ? 'Unnamed garage' : name,
      location: point,
      distanceMeters: const Distance().as(LengthUnit.Meter, from, point),
      phone: (extra['phone'] ?? extra['contact:phone']) as String?,
      address: parts.isEmpty ? null : parts.take(3).join(', '),
      openingHours: extra['opening_hours'] as String?,
    );
  }

  static String? _address(Map<String, dynamic> tags) {
    final parts = [
      tags['addr:housenumber'],
      tags['addr:street'],
      tags['addr:city'],
    ].whereType<String>().where((p) => p.trim().isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(', ');
  }
}
