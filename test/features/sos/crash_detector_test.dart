import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:snapmyauto/features/sos/data/crash_detector.dart';

UserAccelerometerEvent hit(double force, int second) {
  return UserAccelerometerEvent(
    force,
    0,
    0,
    DateTime(2026, 11, 21, 8, 0, second),
  );
}

void main() {
  test('only a hard knock counts as a crash', () {
    expect(isCrashForce(3, 2, 1), false);
    expect(isCrashForce(30, 30, 10), true);
  });

  test('one crash per cooldown', () async {
    final events = Stream.fromIterable([
      hit(5, 0),
      hit(45, 1),
      hit(50, 2),
      hit(60, 40),
    ]);
    final crashes = await crashEvents(events).toList();
    expect(crashes, [
      DateTime(2026, 11, 21, 8, 0, 1),
      DateTime(2026, 11, 21, 8, 0, 40),
    ]);
  });
}
