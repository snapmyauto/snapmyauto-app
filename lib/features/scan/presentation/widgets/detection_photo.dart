import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PhotoBox {
  const PhotoBox({
    required this.rect,
    required this.tag,
    required this.color,
    required this.active,
  });

  // edges as 0..1 of the photo size
  final Rect rect;
  final String tag;
  final Color color;
  final bool active;
}

class DetectionPhoto extends StatelessWidget {
  const DetectionPhoto({
    super.key,
    required this.photo,
    required this.width,
    required this.height,
    required this.boxes,
    this.onRetake,
  });

  final Uint8List photo;
  final int width;
  final int height;
  final List<PhotoBox> boxes;
  final VoidCallback? onRetake;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: ColoredBox(
        color: Colors.black,
        child: SizedBox(
          height: 240,
          width: double.infinity,
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: width / height,
                  child: LayoutBuilder(
                    builder: (context, size) => Stack(
                      children: [
                        Positioned.fill(
                          child: Image.memory(
                            photo,
                            fit: BoxFit.fill,
                            gaplessPlayback: true,
                          ),
                        ),
                        for (final box in boxes)
                          _Box(box: box, area: size.biggest),
                      ],
                    ),
                  ),
                ),
              ),
              if (onRetake != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: FilledButton.icon(
                    onPressed: onRetake,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: Colors.white.withValues(alpha: 0.16),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    icon: const Icon(LucideIcons.rotateCcw, size: 16),
                    label: const Text('Retake'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.box, required this.area});

  final PhotoBox box;
  final Size area;

  @override
  Widget build(BuildContext context) {
    final r = box.rect;
    final color = box.active ? box.color : Colors.white54;
    final tagAbove = r.top > 0.12;
    final dark = ThemeData.estimateBrightnessForColor(color) == Brightness.dark;

    return Positioned(
      left: r.left * area.width,
      top: r.top * area.height,
      width: r.width * area.width,
      height: r.height * area.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            left: -2,
            top: tagAbove ? -24 : null,
            bottom: tagAbove ? null : -24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                box.tag,
                style: TextStyle(
                  color: dark ? Colors.white : Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
