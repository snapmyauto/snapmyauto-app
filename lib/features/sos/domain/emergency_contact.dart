import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContact {
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.relation,
    this.isPrimary = false,
    this.createdAt,
  });

  final String id;
  final String name;
  // stored as typed, e.g. 0771234567 or +94771234567
  final String phone;
  // e.g. father, friend, mechanic
  final String? relation;
  // the one called first in sos
  final bool isPrimary;
  final DateTime? createdAt;

  factory EmergencyContact.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EmergencyContact(
      id: doc.id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      relation: data['relation'] as String?,
      isPrimary: data['isPrimary'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // id and createdAt are left out, the repository handles them
  Map<String, dynamic> toMap() => {
    'name': name.trim(),
    'phone': phone.replaceAll(' ', ''),
    'relation': relation,
    'isPrimary': isPrimary,
  };

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? relation,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relation: relation ?? this.relation,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt,
    );
  }
}
