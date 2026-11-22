const _days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

// reads simple osm hours like "Mo-Fr 08:00-18:00; Sa 08:00-13:00; Su off".
// returns null when the text is missing or too complex to read.
bool? isOpenAt(String? hours, DateTime time) {
  final text = hours?.trim() ?? '';
  if (text.isEmpty) return null;
  if (text == '24/7') return true;

  final today = time.weekday - 1;
  final minute = time.hour * 60 + time.minute;
  bool? open;

  for (final part in text.split(';')) {
    final rule = part.trim();
    if (rule.isEmpty) continue;

    final lower = rule.toLowerCase();
    final closed = lower.endsWith(' off') || lower.endsWith(' closed');
    final firstDigit = rule.indexOf(RegExp(r'\d'));
    if (!closed && firstDigit < 0) return null;

    final dayText = closed
        ? rule.substring(0, rule.lastIndexOf(' ')).trim()
        : rule.substring(0, firstDigit).trim();
    // later rules win over earlier ones, same as osm
    if (!_readDays(dayText).contains(today)) continue;
    if (closed) {
      open = false;
      continue;
    }

    final ranges = _readRanges(rule.substring(firstDigit));
    if (ranges == null) return null;
    open = ranges.any((r) => _inside(r, minute));
  }

  return open ?? false;
}

Set<int> _readDays(String text) {
  if (text.isEmpty) return {0, 1, 2, 3, 4, 5, 6};

  final days = <int>{};
  for (final piece in text.split(',')) {
    final ends = piece.trim().split('-');
    final from = _days.indexOf(ends.first.trim());
    final to = _days.indexOf(ends.last.trim());
    // things like PH (public holiday) are skipped
    if (from < 0 || to < 0) continue;
    for (var d = from; ; d = (d + 1) % 7) {
      days.add(d);
      if (d == to) break;
    }
  }
  return days;
}

List<(int, int)>? _readRanges(String text) {
  final pattern = RegExp(r'^(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})\+?$');
  final ranges = <(int, int)>[];

  for (final piece in text.split(',')) {
    final m = pattern.firstMatch(piece.trim());
    if (m == null) return null;
    final start = int.parse(m[1]!) * 60 + int.parse(m[2]!);
    final end = int.parse(m[3]!) * 60 + int.parse(m[4]!);
    ranges.add((start, end));
  }
  return ranges;
}

bool _inside((int, int) range, int minute) {
  final (start, end) = range;
  if (end > start) return minute >= start && minute < end;
  // goes past midnight, like 18:00-02:00
  return minute >= start || minute < end;
}
