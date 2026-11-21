import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../domain/garage.dart';

class GarageLoadException implements Exception {
  const GarageLoadException({this.offline = false});

  final bool offline;
}

class GarageRepository {
  GarageRepository(this._client);

  final http.Client _client;

  static const _overpass = 'https://overpass-api.de/api/interpreter';
  static const _headers = {'User-Agent': 'SnapMyAuto/1.0 (student project)'};

  Future<List<Garage>> nearby(LatLng from, {int radiusMeters = 5000}) async {
    List<Garage> garages;
    try {
      garages = await _fromOverpass(from, radiusMeters);
    } on GarageLoadException catch (e) {
      if (e.offline) rethrow;
      // the public overpass server is often busy, so try nominatim instead
      garages = await _fromNominatim(from, radiusMeters);
    }
    garages.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return garages;
  }

  Future<List<Garage>> _fromOverpass(LatLng from, int radiusMeters) async {
    final around = '(around:$radiusMeters,${from.latitude},${from.longitude})';
    final query =
        '''
[out:json][timeout:25];
(
  nwr["shop"="car_repair"]$around;
  nwr["amenity"="car_repair"]$around;
  nwr["shop"="tyres"]$around;
);
out center tags;
''';

    final res = await _send(
      _client.post(
        Uri.parse(_overpass),
        headers: _headers,
        body: {'data': query},
      ),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final elements = (body['elements'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    return elements
        .map((e) => Garage.fromOverpass(e, from))
        .whereType<Garage>()
        .toList();
  }

  Future<List<Garage>> _fromNominatim(LatLng from, int radiusMeters) async {
    // turn the radius into a box around the user
    final dLat = radiusMeters / 111320;
    final dLon = dLat / cos(from.latitude * pi / 180);
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': 'car repair',
      'format': 'jsonv2',
      'viewbox':
          '${from.longitude - dLon},${from.latitude + dLat},'
          '${from.longitude + dLon},${from.latitude - dLat}',
      'bounded': '1',
      'limit': '40',
      'extratags': '1',
    });

    final res = await _send(_client.get(uri, headers: _headers));

    final places = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    return places
        .map((p) => Garage.fromNominatim(p, from))
        .whereType<Garage>()
        .toList();
  }

  Future<http.Response> _send(Future<http.Response> request) async {
    final http.Response res;
    try {
      res = await request.timeout(const Duration(seconds: 15));
    } on SocketException {
      throw const GarageLoadException(offline: true);
    } on http.ClientException {
      throw const GarageLoadException(offline: true);
    } on TimeoutException {
      throw const GarageLoadException();
    }
    if (res.statusCode != 200) throw const GarageLoadException();
    return res;
  }
}

final garageRepositoryProvider = Provider<GarageRepository>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return GarageRepository(client);
});
