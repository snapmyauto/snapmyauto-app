import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/warning_light.dart';

class WarningLightRepository {
  static const _path = 'assets/data/warning_lights.json';

  Future<List<WarningLight>> loadAll() async {
    final raw = await rootBundle.loadString(_path);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => WarningLight.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final warningLightRepositoryProvider = Provider(
  (ref) => WarningLightRepository(),
);

// loaded once from the asset file and kept in memory
final warningLightsProvider = FutureProvider<List<WarningLight>>(
  (ref) => ref.watch(warningLightRepositoryProvider).loadAll(),
);

// look up one light by its id (also used by triage after a scan)
final warningLightProvider = Provider.family<AsyncValue<WarningLight?>, String>(
  (ref, id) => ref.watch(warningLightsProvider).whenData((lights) {
    for (final light in lights) {
      if (light.id == id) return light;
    }
    return null;
  }),
);
