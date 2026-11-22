import 'package:flutter/material.dart';

class CardRings extends StatelessWidget {
  const CardRings({
    super.key,
    this.size = 220,
    this.offset = 70,
    this.radii = const [108, 78, 48],
    this.opacity = 0.1,
  });

  final double size;
  // how far the rings stick out past the top right corner
  final double offset;
  final List<double> radii;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -offset,
      right: -offset,
      width: size,
      height: size,
      child: IgnorePointer(
        child: CustomPaint(
          painter: _RingsPainter(
            radii: radii,
            color: Colors.white.withValues(alpha: opacity),
          ),
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({required this.radii, required this.color});

  final List<double> radii;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final center = size.center(Offset.zero);
    for (final r in radii) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.color != color || old.radii != radii;
}
