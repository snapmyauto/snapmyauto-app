import '../../../core/theme/severity.dart';
import '../../scan/domain/scan_record.dart';
import '../../triage/domain/triage_result.dart';

enum DateGroup { today, yesterday, thisWeek, older }

DateGroup groupFor(DateTime? date, DateTime now) {
  // a scan saved offline has no server time yet, so it is new
  if (date == null) return DateGroup.today;
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final days = today.difference(day).inDays;
  if (days <= 0) return DateGroup.today;
  if (days == 1) return DateGroup.yesterday;
  if (days < 7) return DateGroup.thisWeek;
  return DateGroup.older;
}

class HistoryFilter {
  const HistoryFilter({this.vehicleId, this.severity, this.query = ''});

  final String? vehicleId;
  final Severity? severity;
  final String query;

  bool get isEmpty => vehicleId == null && severity == null && query.isEmpty;

  bool matches(ScanRecord scan, TriageResult? result) {
    if (vehicleId != null && scan.vehicleId != vehicleId) return false;
    if (severity != null && result?.severity != severity) return false;

    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final names = result?.lights.map((l) => l.name) ?? const <String>[];
    final labels = scan.lights.map((l) => l.label.replaceAll('_', ' '));
    return [...names, ...labels].any((n) => n.toLowerCase().contains(q));
  }

  HistoryFilter copyWith({
    String? Function()? vehicleId,
    Severity? Function()? severity,
    String? query,
  }) {
    return HistoryFilter(
      vehicleId: vehicleId == null ? this.vehicleId : vehicleId(),
      severity: severity == null ? this.severity : severity(),
      query: query ?? this.query,
    );
  }
}
