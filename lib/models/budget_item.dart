enum BudgetCategory { venue, catering, dekorasi, dokumentasi, busana, undangan, lainnya }

extension BudgetCategoryExt on BudgetCategory {
  String get label {
    switch (this) {
      case BudgetCategory.venue: return 'Venue';
      case BudgetCategory.catering: return 'Catering';
      case BudgetCategory.dekorasi: return 'Dekorasi';
      case BudgetCategory.dokumentasi: return 'Dokumentasi';
      case BudgetCategory.busana: return 'Busana';
      case BudgetCategory.undangan: return 'Undangan';
      case BudgetCategory.lainnya: return 'Lain-lain';
    }
  }

  String get icon {
    switch (this) {
      case BudgetCategory.venue: return '🏛️';
      case BudgetCategory.catering: return '🍽️';
      case BudgetCategory.dekorasi: return '🌸';
      case BudgetCategory.dokumentasi: return '📷';
      case BudgetCategory.busana: return '👗';
      case BudgetCategory.undangan: return '💌';
      case BudgetCategory.lainnya: return '📦';
    }
  }
}

class BudgetItem {
  final String id;
  final BudgetCategory category;
  final double plannedCost;
  final double actualCost;

  BudgetItem({
    required this.id,
    required this.category,
    required this.plannedCost,
    this.actualCost = 0,
  });

  double get remaining => plannedCost - actualCost;
  double get progressPercent => plannedCost > 0 ? (actualCost / plannedCost * 100).clamp(0, 100) : 0;

  factory BudgetItem.fromMap(String id, Map<String, dynamic> data) {
    return BudgetItem(
      id: id,
      category: BudgetCategory.values[data['category'] ?? 6],
      plannedCost: (data['plannedCost'] as num).toDouble(),
      actualCost: (data['actualCost'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'category': category.index,
    'plannedCost': plannedCost,
    'actualCost': actualCost,
  };

  BudgetItem copyWith({double? plannedCost, double? actualCost}) => BudgetItem(
    id: id,
    category: category,
    plannedCost: plannedCost ?? this.plannedCost,
    actualCost: actualCost ?? this.actualCost,
  );
}
