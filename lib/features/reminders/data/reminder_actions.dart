import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../domain/reminder.dart';
import 'reminder_notifications.dart';
import 'reminder_repository.dart';

// keeps firestore and the phone notifications in sync
class ReminderActions {
  ReminderActions(this._ref);

  final Ref _ref;

  String get _uid => _ref.read(currentUidProvider) ?? '';
  ReminderRepository get _repo => _ref.read(reminderRepositoryProvider);
  ReminderNotifications get _notes => _ref.read(reminderNotificationsProvider);

  Future<void> save(Reminder reminder) async {
    await _notes.askPermission();
    if (reminder.id.isEmpty) {
      final saved = await _repo.add(_uid, reminder);
      await _notes.schedule(saved);
    } else {
      await _repo.update(_uid, reminder);
      await _notes.schedule(reminder);
    }
  }

  Future<void> markDone(Reminder reminder) async {
    final next = await _repo.markDone(_uid, reminder);
    await _notes.cancel(reminder.id);
    if (next != null) await _notes.schedule(next);
  }

  // undo a done tick (the next repeat, if any, stays)
  Future<void> markNotDone(Reminder reminder) async {
    final open = reminder.copyWith(done: false);
    await _repo.update(_uid, open);
    await _notes.schedule(open);
  }

  Future<void> delete(Reminder reminder) async {
    await _repo.delete(_uid, reminder.id);
    await _notes.cancel(reminder.id);
  }
}

final reminderActionsProvider = Provider((ref) => ReminderActions(ref));
