import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/dashlight_detector.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _detector = DashlightDetector();
  final _picker = ImagePicker();
  Uint8List? _photo;
  DetectionResult? _result;
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await _detector.load();
    } catch (e) {
      _error = 'model failed to load: $e';
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, maxWidth: 1600);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _photo = bytes;
      _result = null;
      _error = null;
      _busy = true;
    });
    // let the spinner show before the heavy work
    await Future<void>.delayed(const Duration(milliseconds: 50));
    try {
      final result = await _detector.detect(bytes);
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) setState(() => _error = 'detection failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan (test)')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                  child: const Text('Pick photo'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _pick(ImageSource.camera),
                  child: const Text('Take photo'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_busy) const Center(child: CircularProgressIndicator()),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          if (_photo != null && result != null) ...[
            AspectRatio(
              aspectRatio: result.imageWidth / result.imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(_photo!, fit: BoxFit.fill),
                  CustomPaint(painter: _BoxPainter(result)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${result.detections.length} found in ${result.elapsed.inMilliseconds} ms',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            for (final d in result.detections)
              Text('${d.label}  ${(d.score * 100).toStringAsFixed(0)}%'),
          ],
        ],
      ),
    );
  }
}

class _BoxPainter extends CustomPainter {
  _BoxPainter(this.result);

  final DetectionResult result;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / result.imageWidth;
    final sy = size.height / result.imageHeight;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF6FD3B8);
    for (final d in result.detections) {
      final r = Rect.fromLTRB(d.box.left * sx, d.box.top * sy, d.box.right * sx, d.box.bottom * sy);
      canvas.drawRect(r, stroke);
      final tp = TextPainter(
        text: TextSpan(
          text: ' ${d.label} ${(d.score * 100).toStringAsFixed(0)}% ',
          style: const TextStyle(color: Colors.black, fontSize: 12, backgroundColor: Color(0xFF6FD3B8)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(r.left, (r.top - tp.height).clamp(0, size.height)));
    }
  }

  @override
  bool shouldRepaint(covariant _BoxPainter old) => old.result != result;
}