import '../../../core/theme/severity.dart';

enum HealthLevel { good, fair, poor }

class HealthScore {
  const HealthScore({
    required this.score,
    required this.overdue,
    required this.dueSoon,
    this.light,
  });

  final int score;
  final int overdue;
  final int dueSoon;
  // worst light from a recent scan, null when it was fine
  final Severity? light;

  HealthLevel get level => score >= 80
      ? HealthLevel.good
      : score >= 50
      ? HealthLevel.fair
      : HealthLevel.poor;

  bool get perfect => score == 100;
}

// starts at 100 and takes points off for things that need attention
HealthScore scoreHealth({
  required Severity? recentLight,
  required int overdue,
  required int dueSoon,
}) {
  var score = 100;
  final light = switch (recentLight) {
    Severity.stop => Severity.stop,
    Severity.soon => Severity.soon,
    _ => null,
  };
  if (light == Severity.stop) score -= 35;
  if (light == Severity.soon) score -= 15;
  score -= (overdue * 15).clamp(0, 45);
  score -= (dueSoon * 5).clamp(0, 15);

  return HealthScore(
    score: score.clamp(0, 100),
    overdue: overdue,
    dueSoon: dueSoon,
    light: light,
  );
}
