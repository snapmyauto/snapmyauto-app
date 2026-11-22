import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../profile/data/user_repository.dart';
import '../domain/scan_record.dart';

class ScanRepository {
  ScanRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('scans');

  // live list, newest first, a just-saved scan stays on top
  Stream<List<ScanRecord>> watchAll(String uid) {
    return _col(uid).snapshots().map((snap) {
      final list = snap.docs.map(ScanRecord.fromDoc).toList();
      list.sort((a, b) {
        final at = a.createdAt;
        final bt = b.createdAt;
        if (at == null && bt == null) return 0;
        if (at == null) return -1;
        if (bt == null) return 1;
        return bt.compareTo(at);
      });
      return list;
    });
  }

  Stream<ScanRecord?> watchOne(String uid, String id) {
    return _col(uid)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? ScanRecord.fromDoc(doc) : null);
  }

  // returns at once with the new id, firestore keeps the write and
  // sends it when the phone is online
  ScanRecord add(String uid, ScanRecord scan) {
    final ref = _col(uid).doc();
    unawaited(
      ref.set({...scan.toMap(), 'createdAt': FieldValue.serverTimestamp()}),
    );
    return scan.copyWith(id: ref.id);
  }

  Future<void> delete(String uid, String id) {
    return _col(uid).doc(id).delete();
  }
}

final scanRepositoryProvider = Provider<ScanRepository>(
  (ref) => ScanRepository(ref.watch(firestoreProvider)),
);

// all scans of the signed-in user, newest first
final scansProvider = StreamProvider<List<ScanRecord>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(scanRepositoryProvider).watchAll(uid);
});

// one scan by id, for the history detail screen
final scanProvider = StreamProvider.family<ScanRecord?, String>((ref, id) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(scanRepositoryProvider).watchOne(uid, id);
});
