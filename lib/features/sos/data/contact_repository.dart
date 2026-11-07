import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../profile/data/user_repository.dart';
import '../domain/emergency_contact.dart';

class ContactRepository {
  ContactRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('contacts');

  // primary first, then by name
  Stream<List<EmergencyContact>> watchAll(String uid) {
    return _col(uid).snapshots().map((snap) {
      final list = snap.docs.map(EmergencyContact.fromDoc).toList();
      list.sort((a, b) {
        if (a.isPrimary != b.isPrimary) return a.isPrimary ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      return list;
    });
  }

  // returns the contact with its new id
  Future<EmergencyContact> add(String uid, EmergencyContact contact) async {
    final ref = _col(uid).doc();
    await ref.set({
      ...contact.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return contact.copyWith(id: ref.id);
  }

  Future<void> update(String uid, EmergencyContact contact) {
    return _col(uid).doc(contact.id).update(contact.toMap());
  }

  // only one primary, so turn it off on all others in the same batch
  Future<void> setPrimary(String uid, String id) async {
    final snap = await _col(uid).where('isPrimary', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      if (doc.id != id) batch.update(doc.reference, {'isPrimary': false});
    }
    batch.update(_col(uid).doc(id), {'isPrimary': true});
    await batch.commit();
  }

  Future<void> delete(String uid, String id) {
    return _col(uid).doc(id).delete();
  }
}

final contactRepositoryProvider = Provider<ContactRepository>(
  (ref) => ContactRepository(ref.watch(firestoreProvider)),
);

// all emergency contacts of the signed-in user, updates live
final contactsProvider = StreamProvider<List<EmergencyContact>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(contactRepositoryProvider).watchAll(uid);
});
