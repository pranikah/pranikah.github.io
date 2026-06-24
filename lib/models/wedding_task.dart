import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { belumMulai, sedangProses, selesai }
enum TaskPhase { month12, month6, month3, month1, week1 }

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

  WeddingTask({
    required this.id,
    required this.title,
    required this.dueDate,
    this.status = TaskStatus.belumMulai,
    required this.phase,
  });

  factory WeddingTask.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeddingTask(
      id: doc.id,
      title: data['title'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: TaskStatus.values[data['status'] ?? 0],
      phase: TaskPhase.values[data['phase'] ?? 0],
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'dueDate': Timestamp.fromDate(dueDate),
    'status': status.index,
    'phase': phase.index,
  };

  WeddingTask copyWith({TaskStatus? status}) => WeddingTask(
    id: id,
    title: title,
    dueDate: dueDate,
    status: status ?? this.status,
    phase: phase,
  );
}
