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
  int get daysRemaining {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final wedding = DateTime(weddingDate.year, weddingDate.month, weddingDate.day);
    return wedding.difference(today).inDays;
  }
  double get progressPercentage {
    final total = totalDurationDays;
    if (total <= 0) return 100;
    final elapsed = DateTime.now().difference(startDate).inDays;
    return (elapsed / total * 100).clamp(0, 100);
  }

  Map<String, dynamic> toMap() => {
    'weddingDate': weddingDate.toIso8601String(),
    'startDate': startDate.toIso8601String(),
    'totalBudget': totalBudget,
    'groomName': groomName,
    'brideName': brideName,
  };
}
