import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../profile/data/user_repository.dart';
import '../domain/vehicle.dart';

class VehicleRepository {
  VehicleRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('vehicles');

  // live list, oldest first, new unsaved ones at the end
  Stream<List<Vehicle>> watchAll(String uid) {
    return _col(uid).snapshots().map((snap) {
      final list = snap.docs.map(Vehicle.fromDoc).toList();
      list.sort((a, b) {
        final at = a.createdAt;
        final bt = b.createdAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return at.compareTo(bt);
      });
      return list;
    });
  }

  Future<Vehicle?> get(String uid, String id) async {
    final doc = await _col(uid).doc(id).get();
    return doc.exists ? Vehicle.fromDoc(doc) : null;
  }

  // returns the vehicle with its new id
  Future<Vehicle> add(String uid, Vehicle vehicle) async {
    final ref = _col(uid).doc();
    await ref.set({
      ...vehicle.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return vehicle.copyWith(id: ref.id);
  }

  Future<void> update(String uid, Vehicle vehicle) {
    return _col(uid).doc(vehicle.id).update(vehicle.toMap());
  }

  Future<void> delete(String uid, String id) {
    return _col(uid).doc(id).delete();
  }
}

final vehicleRepositoryProvider = Provider<VehicleRepository>(
  (ref) => VehicleRepository(ref.watch(firestoreProvider)),
);

// all vehicles of the signed-in user, updates live
final vehiclesProvider = StreamProvider<List<Vehicle>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(vehicleRepositoryProvider).watchAll(uid);
});
