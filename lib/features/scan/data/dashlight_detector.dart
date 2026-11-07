import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class Detection {
  const Detection({
    required this.label,
    required this.classIndex,
    required this.score,
    required this.box,
  });

  final String label;
  final int classIndex;
  final double score;
  // box in original photo pixels
  final Rect box;
}

class DetectionResult {
  const DetectionResult({
    required this.detections,
    required this.imageWidth,
    required this.imageHeight,
    required this.elapsed,
  });

  final List<Detection> detections;
  final int imageWidth;
  final int imageHeight;
  final Duration elapsed;
}

class DashlightDetector {
  Interpreter? _interpreter;
  List<String> labels = [];
  bool _running = false;

  bool get isLoaded => _interpreter != null;

  Future<void> load() async {
    if (isLoaded) return;
    _interpreter = await Interpreter.fromAsset(
      'assets/models/dashlight.tflite',
      options: InterpreterOptions()..threads = 4,
    );
    final raw = await rootBundle.loadString('assets/models/labels.txt');
    labels = raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  Future<DetectionResult> detect(Uint8List photoBytes) async {
    final interpreter = _interpreter;
    if (interpreter == null) throw StateError('model not loaded');
    if (_running) throw StateError('detection already running');
    _running = true;
    try {
      final address = interpreter.address;
      final names = List<String>.of(labels);
      // heavy work runs in a background isolate so the ui keeps moving
      return await Isolate.run(
        () => _detectSync(Interpreter.fromAddress(address), names, photoBytes),
      );
    } finally {
      _running = false;
    }
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}

final dashlightDetectorProvider = Provider<DashlightDetector>((ref) {
  final detector = DashlightDetector();
  ref.onDispose(detector.close);
  return detector;
});

const _size = 640;
const _anchors = 8400;
const _scoreThreshold = 0.35;
const _iouThreshold = 0.45;

DetectionResult _detectSync(
  Interpreter interpreter,
  List<String> labels,
  Uint8List bytes,
) {
  final watch = Stopwatch()..start();

  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw ArgumentError('could not read image');
  final photo = img.bakeOrientation(decoded);

  // letterbox: fit inside 640x640 without stretching, pad with grey
  final scale = math.min(_size / photo.width, _size / photo.height);
  final newW = (photo.width * scale).round();
  final newH = (photo.height * scale).round();
  final padX = (_size - newW) ~/ 2;
  final padY = (_size - newH) ~/ 2;

  final resized = img.copyResize(photo, width: newW, height: newH);
  final canvas = img.Image(width: _size, height: _size);
  img.fill(canvas, color: img.ColorRgb8(114, 114, 114));
  img.compositeImage(canvas, resized, dstX: padX, dstY: padY);

  // model wants [1, 3, 640, 640]: all red values, then green, then blue
  final rgb = canvas.getBytes(order: img.ChannelOrder.rgb);
  const plane = _size * _size;
  final input = Float32List(3 * plane);
  for (var p = 0; p < plane; p++) {
    input[p] = rgb[p * 3] / 255.0;
    input[plane + p] = rgb[p * 3 + 1] / 255.0;
    input[2 * plane + p] = rgb[p * 3 + 2] / 255.0;
  }

  // flat buffers are much faster than nested lists
  final rows = 4 + labels.length;
  final output = Float32List(rows * _anchors);
  interpreter.run(input.buffer, output.buffer);
  double at(int row, int i) => output[row * _anchors + i];

  // some exports give boxes as 0..1, others as 0..640
  var maxCoord = 0.0;
  for (var i = 0; i < _anchors; i++) {
    maxCoord = math.max(maxCoord, at(2, i));
  }
  final coordScale = maxCoord <= 1.5 ? _size.toDouble() : 1.0;

  final candidates = <Detection>[];
  for (var i = 0; i < _anchors; i++) {
    var best = 0;
    var bestScore = 0.0;
    for (var c = 0; c < labels.length; c++) {
      final s = at(4 + c, i);
      if (s > bestScore) {
        bestScore = s;
        best = c;
      }
    }
    if (bestScore < _scoreThreshold) continue;

    final cx = at(0, i) * coordScale;
    final cy = at(1, i) * coordScale;
    final w = at(2, i) * coordScale;
    final h = at(3, i) * coordScale;

    // undo letterbox to get original photo pixels
    final left = ((cx - w / 2) - padX) / scale;
    final top = ((cy - h / 2) - padY) / scale;
    final right = ((cx + w / 2) - padX) / scale;
    final bottom = ((cy + h / 2) - padY) / scale;

    candidates.add(
      Detection(
        label: labels[best],
        classIndex: best,
        score: bestScore,
        box: Rect.fromLTRB(
          left.clamp(0, photo.width.toDouble()),
          top.clamp(0, photo.height.toDouble()),
          right.clamp(0, photo.width.toDouble()),
          bottom.clamp(0, photo.height.toDouble()),
        ),
      ),
    );
  }

  watch.stop();
  return DetectionResult(
    detections: _nms(candidates),
    imageWidth: photo.width,
    imageHeight: photo.height,
    elapsed: watch.elapsed,
  );
}

// keep the best box, drop others of the same class that overlap it a lot
List<Detection> _nms(List<Detection> items) {
  items.sort((a, b) => b.score.compareTo(a.score));
  final kept = <Detection>[];
  for (final d in items) {
    final overlaps = kept.any(
      (k) => k.classIndex == d.classIndex && _iou(k.box, d.box) > _iouThreshold,
    );
    if (!overlaps) kept.add(d);
  }
  return kept;
}

double _iou(Rect a, Rect b) {
  final inter = a.intersect(b);
  if (inter.width <= 0 || inter.height <= 0) return 0;
  final interArea = inter.width * inter.height;
  final union = a.width * a.height + b.width * b.height - interArea;
  return union <= 0 ? 0 : interArea / union;
}
