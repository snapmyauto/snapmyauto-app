import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../profile/data/user_repository.dart';
import '../domain/reminder.dart';

class ReminderRepository {
  ReminderRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('reminders');

  // open ones first by soonest due date, done ones at the end
  Stream<List<Reminder>> watchAll(String uid) {
    return _col(uid).snapshots().map((snap) {
      final list = snap.docs.map(Reminder.fromDoc).toList();
      list.sort((a, b) {
        if (a.done != b.done) return a.done ? 1 : -1;
        return a.dueDate.compareTo(b.dueDate);
      });
      return list;
    });
  }

  // returns the reminder with its new id
  Future<Reminder> add(String uid, Reminder reminder) async {
    final ref = _col(uid).doc();
    await ref.set({
      ...reminder.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return reminder.copyWith(id: ref.id);
  }

  Future<void> update(String uid, Reminder reminder) {
    return _col(uid).doc(reminder.id).update(reminder.toMap());
  }

  // marks done and adds the next one if it repeats, both or nothing
  Future<Reminder?> markDone(String uid, Reminder reminder) async {
    final batch = _db.batch();
    batch.update(_col(uid).doc(reminder.id), {'done': true});
    final next = reminder.nextRepeat();
    Reminder? saved;
    if (next != null) {
      final ref = _col(uid).doc();
      batch.set(ref, {
        ...next.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      saved = next.copyWith(id: ref.id);
    }
    await batch.commit();
    return saved;
  }

  Future<void> delete(String uid, String id) {
    return _col(uid).doc(id).delete();
  }
}

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepository(ref.watch(firestoreProvider)),
);

// all reminders of the signed-in user, updates live
final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(reminderRepositoryProvider).watchAll(uid);
});
