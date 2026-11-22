import 'package:cloud_firestore/cloud_firestore.dart';

/// The users/{uid} document.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime? createdAt;

  /// "Kasun Perera" -> "KP", falls back to the email.
  String get initials {
    final source = name.trim().isNotEmpty ? name.trim() : email;
    final parts = source.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
