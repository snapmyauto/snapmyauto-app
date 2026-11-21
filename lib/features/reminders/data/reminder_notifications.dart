import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder.dart';

// local notification on the due date at 9:00
class ReminderNotifications {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Service, licence and insurance reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Colombo'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    _ready = true;
  }

  // android 13+ asks the user once
  Future<void> askPermission() async {
    await _init();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // String.hashCode is not promised to stay the same between app runs,
  // so a simple fixed hash is used to get the same id every time
  int idFor(String reminderId) {
    var hash = 0;
    for (final unit in reminderId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  Future<void> schedule(Reminder reminder) async {
    await _init();
    await _plugin.cancel(id: idFor(reminder.id));
    if (reminder.done) return;

    final days = reminder.notifyDaysBefore;
    final due = reminder.dueDate;
    final at = tz.TZDateTime(tz.local, due.year, due.month, due.day - days, 9);
    if (at.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id: idFor(reminder.id),
      scheduledDate: at,
      title: reminder.title,
      body: days == 0
          ? 'Due today. Open SnapMyAuto to mark it done.'
          : 'Due in ${days == 7 ? 'a week' : '$days days'}. '
                'Open SnapMyAuto for details.',
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelAll() async {
    await _init();
    await _plugin.cancelAll();
  }

  Future<void> cancel(String reminderId) async {
    await _init();
    await _plugin.cancel(id: idFor(reminderId));
  }
}

final reminderNotificationsProvider = Provider(
  (ref) => ReminderNotifications(),
);
