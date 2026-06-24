import 'package:cloud_firestore/cloud_firestore.dart';

class PremiumUser {
  final String uid;
  final String? email;
  final String? name;
  final bool isActive;
  final DateTime? requestedAt;
  final DateTime? activatedAt;

  PremiumUser({
    required this.uid,
    this.email,
    this.name,
    required this.isActive,
    this.requestedAt,
    this.activatedAt,
  });

  factory PremiumUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PremiumUser(
      uid: doc.id,
      email: data['email'],
      name: data['name'],
      isActive: data['is_active'] ?? false,
      requestedAt: (data['requested_at'] as Timestamp?)?.toDate(),
      activatedAt: (data['activated_at'] as Timestamp?)?.toDate(),
    );
  }
}
