import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../domain/user_profile.dart';

class UserRepository {
  UserRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  // makes sure users/{uid} exists, safe to call on every login
  Future<void> ensureProfile(User user, {String? name}) async {
    final ref = _doc(user.uid);
    final snap = await ref.get();
    final data = <String, dynamic>{
      'name': name ?? user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': user.photoURL,
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
    if (!snap.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await ref.set(data, SetOptions(merge: true));
  }

  Stream<UserProfile?> watchProfile(String uid) {
    return _doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromDoc(doc) : null);
  }

  Future<void> updateName(String uid, String name) {
    return _doc(uid).update({'name': name.trim()});
  }

  /// Firestore doesn't delete sub-collections with the parent doc,
  /// so every collection under users/{uid} is cleared first.
  Future<void> deleteAllData(String uid) async {
    const collections = ['vehicles', 'scans', 'reminders', 'contacts'];
    for (final name in collections) {
      final snap = await _doc(uid).collection(name).get();
      // a batch can hold at most 500 writes
      for (var i = 0; i < snap.docs.length; i += 400) {
        final batch = _db.batch();
        for (final doc in snap.docs.skip(i).take(400)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }
    await _doc(uid).delete();
  }
}

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(firestoreProvider)),
);

/// Profile of the signed-in user, updates live.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchProfile(uid);
});
