import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/premium_user.dart';

class PremiumService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _col = 'premium_users';

  /// Stream status premium user (realtime)
  Stream<PremiumUser?> getPremiumStatus(String uid) =>
      _db.collection(_col).doc(uid).snapshots().map(
        (doc) => doc.exists ? PremiumUser.fromFirestore(doc) : null,
      );

  /// Cek sekali apakah user premium
  Future<bool> isPremium(String uid) async {
    final doc = await _db.collection(_col).doc(uid).get();
    if (!doc.exists) return false;
    final user = PremiumUser.fromFirestore(doc);
    return user.isActive;
  }

  // --- Admin Methods ---

  /// User request premium (setelah transfer)
  Future<void> requestPremium(String uid, String email, String name) =>
      _db.collection(_col).doc(uid).set({
        'email': email,
        'name': name,
        'is_active': false,
        'requested_at': FieldValue.serverTimestamp(),
      });

  /// Admin: stream semua premium requests
  Stream<List<PremiumUser>> getAllRequests() =>
      _db.collection(_col).orderBy('requested_at', descending: true).snapshots().map(
        (snap) => snap.docs.map((d) => PremiumUser.fromFirestore(d)).toList(),
      );

  /// Admin: activate premium
  Future<void> activatePremium(String uid) =>
      _db.collection(_col).doc(uid).update({
        'is_active': true,
        'activated_at': FieldValue.serverTimestamp(),
      });

  /// Admin: deactivate premium
  Future<void> deactivatePremium(String uid) =>
      _db.collection(_col).doc(uid).update({'is_active': false});
}
