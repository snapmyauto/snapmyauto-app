import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../domain/garage.dart';

// Thrown when the Overpass API can't be reached.
class GarageLoadException implements Exception {
  const GarageLoadException({this.offline = false});

  final bool offline;
}

class GarageRepository {
  GarageRepository(this._client);

  final http.Client _client;

  static const _endpoint = 'https://overpass-api.de/api/interpreter';

  Future<List<Garage>> nearby(LatLng from, {int radiusMeters = 5000}) async {
    final around = '(around:$radiusMeters,${from.latitude},${from.longitude})';
    final query =
        '''
[out:json][timeout:25];
(
  nwr["shop"="car_repair"]$around;
  nwr["amenity"="car_repair"]$around;
);
out center tags;
''';

    final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {'User-Agent': 'SnapMyAuto/1.0 (student project)'},
            body: {'data': query},
          )
          .timeout(const Duration(seconds: 30));
    } on SocketException {
      throw const GarageLoadException(offline: true);
    } on http.ClientException {
      throw const GarageLoadException(offline: true);
    } on TimeoutException {
      throw const GarageLoadException();
    }

    if (res.statusCode != 200) throw const GarageLoadException();

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final elements = (body['elements'] as List? ?? [])
        .cast<Map<String, dynamic>>();

    final garages = elements
        .map((e) => Garage.fromOverpass(e, from))
        .whereType<Garage>()
        .toList();
    garages.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return garages;
  }
}

final garageRepositoryProvider = Provider<GarageRepository>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return GarageRepository(client);
});
