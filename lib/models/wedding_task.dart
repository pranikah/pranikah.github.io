enum TaskStatus { belumMulai, sedangProses, selesai }
enum TaskPhase { month12, month6, month3, month1, week1 }
enum TaskPriority { high, medium, low }

extension TaskPriorityExt on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.high: return 'High';
      case TaskPriority.medium: return 'Medium';
      case TaskPriority.low: return 'Low';
    }
  }

  int get sortOrder {
    switch (this) {
      case TaskPriority.high: return 0;
      case TaskPriority.medium: return 1;
      case TaskPriority.low: return 2;
    }
  }

  /// Offset hari dalam fase: high = awal, medium = tengah, low = akhir
  int get dayOffset {
    switch (this) {
      case TaskPriority.high: return 0;
      case TaskPriority.medium: return 7;
      case TaskPriority.low: return 14;
    }
  }
}

extension TaskPhaseExt on TaskPhase {
  String get label {
    switch (this) {
      case TaskPhase.month12: return '12 Bulan Sebelum';
      case TaskPhase.month6: return '6 Bulan Sebelum';
      case TaskPhase.month3: return '3 Bulan Sebelum';
      case TaskPhase.month1: return '1 Bulan Sebelum';
      case TaskPhase.week1: return '1 Minggu Sebelum';
    }
  }

  int get monthsBefore {
    switch (this) {
      case TaskPhase.month12: return 12;
      case TaskPhase.month6: return 6;
      case TaskPhase.month3: return 3;
      case TaskPhase.month1: return 1;
      case TaskPhase.week1: return 0;
    }
  }
}

extension TaskStatusExt on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.belumMulai: return 'Belum Mulai';
      case TaskStatus.sedangProses: return 'Sedang Proses';
      case TaskStatus.selesai: return 'Selesai';
    }
  }
}

class WeddingTask {
  final String id;
  final String title;
  final DateTime dueDate;
  final TaskStatus status;
  final TaskPhase phase;
  final TaskPriority priority;

  WeddingTask({
    required this.id,
    required this.title,
    required this.dueDate,
    this.status = TaskStatus.belumMulai,
    required this.phase,
    this.priority = TaskPriority.medium,
  });

  factory WeddingTask.fromMap(String id, Map<String, dynamic> data) {
    return WeddingTask(
      id: id,
      title: data['title'] ?? '',
      dueDate: DateTime.parse(data['dueDate']),
      status: TaskStatus.values[data['status'] ?? 0],
      phase: TaskPhase.values[data['phase'] ?? 0],
      priority: TaskPriority.values[data['priority'] ?? 1],
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'dueDate': dueDate.toIso8601String(),
    'status': status.index,
    'phase': phase.index,
    'priority': priority.index,
  };

  WeddingTask copyWith({TaskStatus? status, TaskPriority? priority, DateTime? dueDate}) => WeddingTask(
    id: id,
    title: title,
    dueDate: dueDate ?? this.dueDate,
    status: status ?? this.status,
    phase: phase,
    priority: priority ?? this.priority,
  );
}
