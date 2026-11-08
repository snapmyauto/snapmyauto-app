import 'dart:typed_data';

import '../data/dashlight_detector.dart';
import 'scan_record.dart';

class ScanDraft {
  const ScanDraft({
    required this.photo,
    required this.result,
    required this.source,
  });

  final Uint8List photo;
  final DetectionResult result;
  final ScanSource source;
}
