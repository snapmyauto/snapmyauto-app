import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(firestoreProvider)),
);
