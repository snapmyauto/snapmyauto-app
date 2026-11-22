import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderType {
  service,
  oilChange,
  tyres,
  insurance,
  revenueLicence,
  emissionTest,
  other,
}

class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.type,
    required this.dueDate,
    this.vehicleId,
    this.repeatMonths,
    this.dueKm,
    this.notifyDaysBefore = 0,
    this.notes,
    this.done = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final ReminderType type;
  final DateTime dueDate;
  // which car this is for, null if not linked
  final String? vehicleId;
  // null means it does not repeat
  final int? repeatMonths;
  // also due at this odometer reading, whichever comes first
  final int? dueKm;
  final int notifyDaysBefore;
  final String? notes;
  final bool done;
  final DateTime? createdAt;

  bool get isOverdue => !done && dueDate.isBefore(DateTime.now());

  // things you renew instead of fix
  bool get isRenewal => const {
    ReminderType.insurance,
    ReminderType.revenueLicence,
    ReminderType.emissionTest,
  }.contains(type);

  // km left before the mileage limit, null when there is none
  int? kmLeft(int? odometerKm) {
    if (dueKm == null || odometerKm == null) return null;
    return dueKm! - odometerKm;
  }

  // overdue by date, or the car already passed the km
  bool isOverdueAt(int? odometerKm) {
    if (done) return false;
    return isOverdue || (kmLeft(odometerKm) ?? 1) <= 0;
  }

  // next copy for a repeating reminder, null if it does not repeat
  Reminder? nextRepeat() {
    final months = repeatMonths;
    if (months == null || months <= 0) return null;
    return Reminder(
      id: '',
      title: title,
      type: type,
      dueDate: DateTime(dueDate.year, dueDate.month + months, dueDate.day),
      vehicleId: vehicleId,
      repeatMonths: repeatMonths,
      notifyDaysBefore: notifyDaysBefore,
      notes: notes,
    );
  }

  factory Reminder.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Reminder(
      id: doc.id,
      title: data['title'] as String? ?? '',
      type: ReminderType.values.asNameMap()[data['type']] ?? ReminderType.other,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      vehicleId: data['vehicleId'] as String?,
      repeatMonths: (data['repeatMonths'] as num?)?.toInt(),
      dueKm: (data['dueKm'] as num?)?.toInt(),
      notifyDaysBefore: (data['notifyDaysBefore'] as num?)?.toInt() ?? 0,
      notes: data['notes'] as String?,
      done: data['done'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // id and createdAt are left out, the repository handles them
  Map<String, dynamic> toMap() => {
    'title': title,
    'type': type.name,
    'dueDate': Timestamp.fromDate(dueDate),
    'vehicleId': vehicleId,
    'repeatMonths': repeatMonths,
    'dueKm': dueKm,
    'notifyDaysBefore': notifyDaysBefore,
    'notes': notes,
    'done': done,
  };

  Reminder copyWith({
    String? id,
    String? title,
    ReminderType? type,
    DateTime? dueDate,
    String? vehicleId,
    int? repeatMonths,
    int? dueKm,
    int? notifyDaysBefore,
    String? notes,
    bool? done,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      vehicleId: vehicleId ?? this.vehicleId,
      repeatMonths: repeatMonths ?? this.repeatMonths,
      dueKm: dueKm ?? this.dueKm,
      notifyDaysBefore: notifyDaysBefore ?? this.notifyDaysBefore,
      notes: notes ?? this.notes,
      done: done ?? this.done,
      createdAt: createdAt,
    );
  }
}
