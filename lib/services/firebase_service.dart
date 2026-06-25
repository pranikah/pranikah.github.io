import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wedding_plan.dart';
import '../models/wedding_task.dart';
import '../models/budget_item.dart';
import '../models/vendor.dart';
import '../data/vendor_seeds.dart';
import 'data_service.dart';

class FirebaseService implements DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _plansCol = 'wedding_plans';
  static const String _tasksCol = 'tasks';
  static const String _budgetCol = 'budgets';

  // Wedding Plan
  @override
  Future<void> savePlan(WeddingPlan plan) =>
      _db.collection(_plansCol).doc(plan.id).set(plan.toMap());

  @override
  Future<void> updatePlan(String planId, Map<String, dynamic> data) =>
      _db.collection(_plansCol).doc(planId).update(data);

  @override
  Stream<WeddingPlan?> getPlan(String planId) =>
      _db.collection(_plansCol).doc(planId).snapshots().map(
        (doc) => doc.exists ? WeddingPlan.fromFirestore(doc) : null,
      );

  // Tasks
  @override
  Future<void> addTask(String planId, WeddingTask task) =>
      _db.collection(_plansCol).doc(planId).collection(_tasksCol).add(task.toMap());

  @override
  Future<void> updateTaskStatus(String planId, String taskId, TaskStatus status) =>
      _db.collection(_plansCol).doc(planId).collection(_tasksCol).doc(taskId).update({'status': status.index});

  @override
  Future<void> deleteTask(String planId, String taskId) =>
      _db.collection(_plansCol).doc(planId).collection(_tasksCol).doc(taskId).delete();

  @override
  Stream<List<WeddingTask>> getTasks(String planId) =>
      _db.collection(_plansCol).doc(planId).collection(_tasksCol).snapshots().map(
        (snap) => snap.docs.map((d) => WeddingTask.fromFirestore(d)).toList()
          ..sort((a, b) => a.phase.index.compareTo(b.phase.index)),
      );

  // Budget
  @override
  Future<void> addBudgetItem(String planId, BudgetItem item) =>
      _db.collection(_plansCol).doc(planId).collection(_budgetCol).add(item.toMap());

  @override
  Future<void> updateBudgetItem(String planId, BudgetItem item) =>
      _db.collection(_plansCol).doc(planId).collection(_budgetCol).doc(item.id).update(item.toMap());

  @override
  Stream<List<BudgetItem>> getBudgetItems(String planId) =>
      _db.collection(_plansCol).doc(planId).collection(_budgetCol).snapshots().map(
        (snap) => snap.docs.map((d) => BudgetItem.fromFirestore(d)).toList(),
      );

  @override
  Future<void> deleteBudgetItem(String planId, String itemId) =>
      _db.collection(_plansCol).doc(planId).collection(_budgetCol).doc(itemId).delete();

  // Generate default tasks
  @override
  Future<void> generateDefaultTasks(String planId, DateTime weddingDate) async {
    final defaultTasks = <Map<String, dynamic>>[
      {'title': 'Tentukan budget keseluruhan', 'phase': TaskPhase.month12},
      {'title': 'Cari dan booking venue', 'phase': TaskPhase.month12},
      {'title': 'Buat daftar tamu undangan', 'phase': TaskPhase.month12},
      {'title': 'Cari wedding organizer', 'phase': TaskPhase.month12},
      {'title': 'Pilih dan booking vendor catering', 'phase': TaskPhase.month6},
      {'title': 'Pilih vendor dekorasi', 'phase': TaskPhase.month6},
      {'title': 'Booking fotografer & videografer', 'phase': TaskPhase.month6},
      {'title': 'Pilih desain undangan', 'phase': TaskPhase.month6},
      {'title': 'Fitting baju pengantin', 'phase': TaskPhase.month3},
      {'title': 'Sesi foto prewedding', 'phase': TaskPhase.month3},
      {'title': 'Kirim undangan', 'phase': TaskPhase.month3},
      {'title': 'Urus dokumen pernikahan', 'phase': TaskPhase.month3},
      {'title': 'Konfirmasi semua vendor', 'phase': TaskPhase.month1},
      {'title': 'Fitting baju final', 'phase': TaskPhase.month1},
      {'title': 'Rundown acara detail', 'phase': TaskPhase.month1},
      {'title': 'Technical meeting vendor', 'phase': TaskPhase.week1},
      {'title': 'Persiapan seserahan/hantaran', 'phase': TaskPhase.week1},
      {'title': 'Rehearsal & doa bersama', 'phase': TaskPhase.week1},
    ];

    final batch = _db.batch();
    for (final task in defaultTasks) {
      final phase = task['phase'] as TaskPhase;
      final dueDate = phase == TaskPhase.week1
          ? weddingDate.subtract(const Duration(days: 7))
          : DateTime(weddingDate.year, weddingDate.month - phase.monthsBefore, weddingDate.day);
      final ref = _db.collection(_plansCol).doc(planId).collection(_tasksCol).doc();
      batch.set(ref, WeddingTask(
        id: ref.id,
        title: task['title'] as String,
        dueDate: dueDate,
        phase: phase,
      ).toMap());
    }
    await batch.commit();
  }

  // Vendors
  static const String _vendorsCol = 'vendors';

  @override
  Stream<List<Vendor>> getVendors({VendorCategory? category, String? city}) {
    Query query = _db.collection(_vendorsCol);
    if (category != null) query = query.where('category', isEqualTo: category.index);
    if (city != null) query = query.where('city', isEqualTo: city);
    return query.snapshots().map(
      (snap) => snap.docs.map((d) => Vendor.fromFirestore(d)).toList(),
    );
  }

  @override
  Future<void> addVendor(Vendor vendor) =>
      _db.collection(_vendorsCol).add(vendor.toMap());

  @override
  Future<void> deleteVendor(String id) =>
      _db.collection(_vendorsCol).doc(id).delete();

  /// Upload seed vendor data ke Firestore (jalankan sekali saja)
  @override
  Future<int> seedVendorData() async {
    final existing = await _db.collection(_vendorsCol).limit(1).get();
    if (existing.docs.isNotEmpty) return 0; // sudah ada data, skip

    final batch = _db.batch();
    for (final vendor in seedVendors) {
      final ref = _db.collection(_vendorsCol).doc();
      batch.set(ref, vendor.toMap());
    }
    await batch.commit();
    return seedVendors.length;
  }
}
