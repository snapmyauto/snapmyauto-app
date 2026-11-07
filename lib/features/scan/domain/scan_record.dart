import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/dashlight_detector.dart';

enum ScanSource { camera, gallery }

// one warning light the user kept after review
class ScanLight {
  const ScanLight({
    required this.label,
    required this.score,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final String label;
  final double score;
  // box edges as 0..1 of the photo size, so they work at any size
  final double left;
  final double top;
  final double right;
  final double bottom;

  factory ScanLight.fromDetection(Detection d, int width, int height) {
    return ScanLight(
      label: d.label,
      score: d.score,
      left: d.box.left / width,
      top: d.box.top / height,
      right: d.box.right / width,
      bottom: d.box.bottom / height,
    );
  }

  factory ScanLight.fromMap(Map<String, dynamic> map) {
    double read(String key) => (map[key] as num?)?.toDouble() ?? 0;
    return ScanLight(
      label: map['label'] as String? ?? '',
      score: read('score'),
      left: read('left'),
      top: read('top'),
      right: read('right'),
      bottom: read('bottom'),
    );
  }

  Map<String, dynamic> toMap() => {
    'label': label,
    'score': score,
    'left': left,
    'top': top,
    'right': right,
    'bottom': bottom,
  };

  ScanLight copyWith({String? label}) {
    return ScanLight(
      label: label ?? this.label,
      score: score,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }
}

class ScanRecord {
  const ScanRecord({
    required this.id,
    required this.lights,
    this.source = ScanSource.camera,
    this.vehicleId,
    this.createdAt,
  });

  final String id;
  final List<ScanLight> lights;
  final ScanSource source;
  // which car this scan was for, null if none picked
  final String? vehicleId;
  final DateTime? createdAt;

  bool get isEmpty => lights.isEmpty;

  factory ScanRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final raw = data['lights'] as List<dynamic>? ?? [];
    return ScanRecord(
      id: doc.id,
      lights: raw
          .map((e) => ScanLight.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      source:
          ScanSource.values.asNameMap()[data['source']] ?? ScanSource.camera,
      vehicleId: data['vehicleId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // id and createdAt are left out, the repository handles them
  Map<String, dynamic> toMap() => {
    'lights': lights.map((l) => l.toMap()).toList(),
    'labels': lights.map((l) => l.label).toSet().toList(),
    'source': source.name,
    'vehicleId': vehicleId,
  };

  ScanRecord copyWith({
    String? id,
    List<ScanLight>? lights,
    ScanSource? source,
    String? vehicleId,
  }) {
    return ScanRecord(
      id: id ?? this.id,
      lights: lights ?? this.lights,
      source: source ?? this.source,
      vehicleId: vehicleId ?? this.vehicleId,
      createdAt: createdAt,
    );
  }
}
