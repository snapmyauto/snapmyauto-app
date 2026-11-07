import 'package:cloud_firestore/cloud_firestore.dart';

enum FuelType { petrol, diesel, hybrid, electric }

class Vehicle {
  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.nickname,
    this.plate,
    this.fuelType = FuelType.petrol,
    this.odometerKm,
    this.createdAt,
  });

  // firestore doc id, empty for a vehicle not saved yet
  final String id;
  final String make;
  final String model;
  final int year;
  final String? nickname;
  final String? plate;
  final FuelType fuelType;
  final int? odometerKm;
  final DateTime? createdAt;

  // name shown in lists, nickname wins if set
  String get displayName => (nickname != null && nickname!.trim().isNotEmpty)
      ? nickname!
      : '$make $model';

  factory Vehicle.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Vehicle(
      id: doc.id,
      make: data['make'] as String? ?? '',
      model: data['model'] as String? ?? '',
      year: (data['year'] as num?)?.toInt() ?? 0,
      nickname: data['nickname'] as String?,
      plate: data['plate'] as String?,
      fuelType:
          FuelType.values.asNameMap()[data['fuelType']] ?? FuelType.petrol,
      odometerKm: (data['odometerKm'] as num?)?.toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // id and createdAt are left out, the repository handles them
  Map<String, dynamic> toMap() => {
    'make': make,
    'model': model,
    'year': year,
    'nickname': nickname,
    'plate': plate,
    'fuelType': fuelType.name,
    'odometerKm': odometerKm,
  };

  Vehicle copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? nickname,
    String? plate,
    FuelType? fuelType,
    int? odometerKm,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      nickname: nickname ?? this.nickname,
      plate: plate ?? this.plate,
      fuelType: fuelType ?? this.fuelType,
      odometerKm: odometerKm ?? this.odometerKm,
      createdAt: createdAt,
    );
  }
}
