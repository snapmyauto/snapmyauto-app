import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/utils/shared_prefs.dart';

// about 4 g without gravity, a hard knock but more than normal driving
const crashForce = 40.0;
const crashCooldown = Duration(seconds: 30);

bool isCrashForce(double x, double y, double z) {
  return sqrt(x * x + y * y + z * z) >= crashForce;
}

// one event per hit, then quiet for the cooldown so it can't fire twice
Stream<DateTime> crashEvents(Stream<UserAccelerometerEvent> source) async* {
  DateTime? last;
  await for (final e in source) {
    if (!isCrashForce(e.x, e.y, e.z)) continue;
    final now = e.timestamp;
    if (last != null && now.difference(last) < crashCooldown) continue;
    last = now;
    yield now;
  }
}

class CrashDetectionNotifier extends Notifier<bool> {
  static const _key = 'crashDetection';

  @override
  bool build() => ref.read(sharedPrefsProvider).getBool(_key) ?? false;

  Future<void> change(bool on) async {
    state = on;
    await ref.read(sharedPrefsProvider).setBool(_key, on);
  }
}

final crashDetectionProvider = NotifierProvider<CrashDetectionNotifier, bool>(
  CrashDetectionNotifier.new,
);

// only listens to the sensor while the switch is on
final crashProvider = StreamProvider<DateTime>((ref) {
  if (!ref.watch(crashDetectionProvider)) return const Stream.empty();
  return crashEvents(
    userAccelerometerEventStream(samplingPeriod: SensorInterval.gameInterval),
  );
});
