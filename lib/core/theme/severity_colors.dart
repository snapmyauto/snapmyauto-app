import 'package:flutter/material.dart';

// warning colours stay the same in green and blue themes
// always show an icon + text with them, never colour alone
@immutable
class SeverityColors extends ThemeExtension<SeverityColors> {
  const SeverityColors({
    required this.stop,
    required this.stopTint,
    required this.soon,
    required this.soonTint,
    required this.safe,
    required this.safeTint,
    required this.info,
    required this.infoTint,
  });

  final Color stop, stopTint, soon, soonTint, safe, safeTint, info, infoTint;

  static const light = SeverityColors(
    stop: Color(0xFFD92D20), stopTint: Color(0xFFFEE4E2),
    soon: Color(0xFFF79009), soonTint: Color(0xFFFFF6E5),
    safe: Color(0xFF079455), safeTint: Color(0xFFDCFAE6),
    info: Color(0xFF0369A1), infoTint: Color(0xFFE0F2FE),
  );

  static const dark = SeverityColors(
    stop: Color(0xFFF97066), stopTint: Color(0xFF3A1512),
    soon: Color(0xFFFDB022), soonTint: Color(0xFF3A2A0E),
    safe: Color(0xFF47CD89), safeTint: Color(0xFF0E2E1E),
    info: Color(0xFF7CD4FD), infoTint: Color(0xFF0B2A3D),
  );

  @override
  SeverityColors copyWith({
    Color? stop, Color? stopTint, Color? soon, Color? soonTint,
    Color? safe, Color? safeTint, Color? info, Color? infoTint,
  }) =>
      SeverityColors(
        stop: stop ?? this.stop, stopTint: stopTint ?? this.stopTint,
        soon: soon ?? this.soon, soonTint: soonTint ?? this.soonTint,
        safe: safe ?? this.safe, safeTint: safeTint ?? this.safeTint,
        info: info ?? this.info, infoTint: infoTint ?? this.infoTint,
      );

  @override
  SeverityColors lerp(SeverityColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SeverityColors(
      stop: l(stop, other.stop), stopTint: l(stopTint, other.stopTint),
      soon: l(soon, other.soon), soonTint: l(soonTint, other.soonTint),
      safe: l(safe, other.safe), safeTint: l(safeTint, other.safeTint),
      info: l(info, other.info), infoTint: l(infoTint, other.infoTint),
    );
  }
}

extension SeverityX on BuildContext {
  SeverityColors get severity => Theme.of(this).extension<SeverityColors>()!;
}
