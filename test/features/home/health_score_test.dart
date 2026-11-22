import 'package:flutter_test/flutter_test.dart';
import 'package:snapmyauto/core/theme/severity.dart';
import 'package:snapmyauto/features/home/domain/health_score.dart';

void main() {
  test('nothing wrong is 100', () {
    final h = scoreHealth(recentLight: Severity.safe, overdue: 0, dueSoon: 0);
    expect(h.score, 100);
    expect(h.light, null);
    expect(h.level, HealthLevel.good);
  });

  test('lights and reminders take points off', () {
    final h = scoreHealth(recentLight: Severity.soon, overdue: 1, dueSoon: 1);
    expect(h.score, 65);
    expect(h.level, HealthLevel.fair);
  });

  test('score never goes below 0 and caps each part', () {
    final h = scoreHealth(recentLight: Severity.stop, overdue: 9, dueSoon: 9);
    expect(h.score, 5);
    expect(h.level, HealthLevel.poor);
  });
}
