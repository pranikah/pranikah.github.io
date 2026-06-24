import 'package:cloud_firestore/cloud_firestore.dart';

class WeddingPlan {
  final String id;
  final DateTime weddingDate;
  final DateTime startDate;
  final double totalBudget;
  final String groomName;
  final String brideName;

  WeddingPlan({
    required this.id,
    required this.weddingDate,
    required this.startDate,
    required this.totalBudget,
    this.groomName = '',
    this.brideName = '',
  });

  int get totalDurationDays => weddingDate.difference(startDate).inDays;
  int get daysRemaining => weddingDate.difference(DateTime.now()).inDays;
  double get progressPercentage {
    final total = totalDurationDays;
    if (total <= 0) return 100;
    final elapsed = DateTime.now().difference(startDate).inDays;
    return (elapsed / total * 100).clamp(0, 100);
  }

  factory WeddingPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeddingPlan(
      id: doc.id,
      weddingDate: (data['weddingDate'] as Timestamp).toDate(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      totalBudget: (data['totalBudget'] as num).toDouble(),
      groomName: data['groomName'] ?? '',
      brideName: data['brideName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'weddingDate': Timestamp.fromDate(weddingDate),
    'startDate': Timestamp.fromDate(startDate),
    'totalBudget': totalBudget,
    'groomName': groomName,
    'brideName': brideName,
  };
}
