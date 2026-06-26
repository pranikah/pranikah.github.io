import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wedding_plan.dart';
import '../models/wedding_task.dart';
import '../models/budget_item.dart';
import '../models/vendor.dart';
import '../data/vendor_seeds.dart';
import 'data_service.dart';

/// Full offline DataService implementation using SharedPreferences (JSON).
class LocalStorageService implements DataService {
  static const _planKey = 'local_plan_';
  static const _tasksKey = 'local_tasks_';
  static const _budgetKey = 'local_budget_';
  static const _vendorsKey = 'local_vendors';

  // Stream controllers for reactive updates
  final _planControllers = <String, StreamController<WeddingPlan?>>{};
  final _tasksControllers = <String, StreamController<List<WeddingTask>>>{};
  final _budgetControllers = <String, StreamController<List<BudgetItem>>>{};
  StreamController<List<Vendor>>? _vendorController;

  int _nextId = DateTime.now().millisecondsSinceEpoch;
  String _genId() => (_nextId++).toString();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // --- Wedding Plan ---

  @override
  Future<void> savePlan(WeddingPlan plan) async {
    final prefs = await _prefs;
    await prefs.setString(_planKey + plan.id, jsonEncode(_planToJson(plan)));
    _emitPlan(plan.id);
  }

  @override
  Future<void> updatePlan(String planId, Map<String, dynamic> data) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_planKey + planId);
    if (raw == null) return;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    if (data.containsKey('groomName')) map['groomName'] = data['groomName'];
    if (data.containsKey('brideName')) map['brideName'] = data['brideName'];
    if (data.containsKey('totalBudget')) map['totalBudget'] = data['totalBudget'];
    if (data.containsKey('weddingDate')) {
      final d = data['weddingDate'] as DateTime;
      map['weddingDate'] = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
    }
    await prefs.setString(_planKey + planId, jsonEncode(map));
    _emitPlan(planId);
  }

  @override
  Stream<WeddingPlan?> getPlan(String planId) {
    _planControllers[planId] ??= StreamController<WeddingPlan?>.broadcast();
    Future.microtask(() => _emitPlan(planId));
    return _planControllers[planId]!.stream;
  }

  @override
  Future<void> deletePlan(String planId) async {
    final prefs = await _prefs;
    await prefs.remove(_planKey + planId);
    await prefs.remove(_tasksKey + planId);
    await prefs.remove(_budgetKey + planId);
    _planControllers[planId]?.add(null);
    _tasksControllers[planId]?.add([]);
    _budgetControllers[planId]?.add([]);
  }

  Future<void> _emitPlan(String planId) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_planKey + planId);
    final plan = raw != null ? _planFromJson(jsonDecode(raw)) : null;
    _planControllers[planId]?.add(plan);
  }

  // --- Tasks ---

  @override
  Future<void> addTask(String planId, WeddingTask task) async {
    final tasks = await _loadTasks(planId);
    final id = _genId();
    tasks.add(_taskWithId(task, id));
    await _saveTasks(planId, tasks);
    _emitTasks(planId);
  }

  @override
  Future<void> updateTaskStatus(String planId, String taskId, TaskStatus status) async {
    final tasks = await _loadTasks(planId);
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    tasks[idx] = tasks[idx].copyWith(status: status);
    await _saveTasks(planId, tasks);
    _emitTasks(planId);
  }

  @override
  Future<void> updateTaskPriority(String planId, String taskId, TaskPriority priority, DateTime newDueDate) async {
    final tasks = await _loadTasks(planId);
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    tasks[idx] = tasks[idx].copyWith(priority: priority, dueDate: newDueDate);
    await _saveTasks(planId, tasks);
    _emitTasks(planId);
  }

  @override
  Future<void> deleteTask(String planId, String taskId) async {
    final tasks = await _loadTasks(planId);
    tasks.removeWhere((t) => t.id == taskId);
    await _saveTasks(planId, tasks);
    _emitTasks(planId);
  }

  @override
  Stream<List<WeddingTask>> getTasks(String planId) {
    _tasksControllers[planId] ??= StreamController<List<WeddingTask>>.broadcast();
    Future.microtask(() => _emitTasks(planId));
    return _tasksControllers[planId]!.stream;
  }

  @override
  Future<void> generateDefaultTasks(String planId, DateTime weddingDate, {DateTime? startDate}) async {
    final cutoff = startDate ?? DateTime.now();
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

    final tasks = <WeddingTask>[];
    for (final task in defaultTasks) {
      final phase = task['phase'] as TaskPhase;
      final dueDate = phase == TaskPhase.week1
          ? weddingDate.subtract(const Duration(days: 7))
          : DateTime(weddingDate.year, weddingDate.month - phase.monthsBefore, weddingDate.day);
      if (dueDate.isBefore(cutoff)) continue;
      tasks.add(WeddingTask(
        id: _genId(),
        title: task['title'] as String,
        dueDate: dueDate,
        phase: phase,
      ));
    }
    await _saveTasks(planId, tasks);
    _emitTasks(planId);
  }

  @override
  Future<void> ensureTasksExist(String planId, DateTime weddingDate, {DateTime? startDate}) async {
    final tasks = await _loadTasks(planId);
    if (tasks.isEmpty) {
      await generateDefaultTasks(planId, weddingDate, startDate: startDate);
    }
  }

  Future<List<WeddingTask>> _loadTasks(String planId) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_tasksKey + planId);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => _taskFromJson(e)).toList();
  }

  Future<void> _saveTasks(String planId, List<WeddingTask> tasks) async {
    final prefs = await _prefs;
    await prefs.setString(_tasksKey + planId, jsonEncode(tasks.map(_taskToJson).toList()));
  }

  void _emitTasks(String planId) async {
    final tasks = await _loadTasks(planId);
    tasks.sort((a, b) {
      final phaseComp = a.phase.index.compareTo(b.phase.index);
      if (phaseComp != 0) return phaseComp;
      return a.priority.sortOrder.compareTo(b.priority.sortOrder);
    });
    _tasksControllers[planId]?.add(tasks);
  }

  // --- Budget ---

  @override
  Future<void> addBudgetItem(String planId, BudgetItem item) async {
    final items = await _loadBudget(planId);
    items.add(BudgetItem(id: _genId(), category: item.category, plannedCost: item.plannedCost, actualCost: item.actualCost));
    await _saveBudget(planId, items);
    _emitBudget(planId);
  }

  @override
  Future<void> updateBudgetItem(String planId, BudgetItem item) async {
    final items = await _loadBudget(planId);
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx == -1) return;
    items[idx] = item;
    await _saveBudget(planId, items);
    _emitBudget(planId);
  }

  @override
  Stream<List<BudgetItem>> getBudgetItems(String planId) {
    _budgetControllers[planId] ??= StreamController<List<BudgetItem>>.broadcast();
    Future.microtask(() => _emitBudget(planId));
    return _budgetControllers[planId]!.stream;
  }

  @override
  Future<void> deleteBudgetItem(String planId, String itemId) async {
    final items = await _loadBudget(planId);
    items.removeWhere((i) => i.id == itemId);
    await _saveBudget(planId, items);
    _emitBudget(planId);
  }

  Future<List<BudgetItem>> _loadBudget(String planId) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_budgetKey + planId);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => _budgetFromJson(e)).toList();
  }

  Future<void> _saveBudget(String planId, List<BudgetItem> items) async {
    final prefs = await _prefs;
    await prefs.setString(_budgetKey + planId, jsonEncode(items.map(_budgetToJson).toList()));
  }

  void _emitBudget(String planId) async {
    final items = await _loadBudget(planId);
    _budgetControllers[planId]?.add(items);
  }

  // --- Vendors ---

  @override
  Stream<List<Vendor>> getVendors({VendorCategory? category, String? city}) {
    _vendorController ??= StreamController<List<Vendor>>.broadcast();
    Future.microtask(() => _emitVendors(category: category, city: city));
    return _vendorController!.stream;
  }

  @override
  Future<void> addVendor(Vendor vendor) async {
    final vendors = await _loadVendors();
    vendors.add(Vendor(id: _genId(), name: vendor.name, category: vendor.category, city: vendor.city, priceRange: vendor.priceRange, instagram: vendor.instagram));
    await _saveVendors(vendors);
    _emitVendors();
  }

  @override
  Future<void> deleteVendor(String id) async {
    final vendors = await _loadVendors();
    vendors.removeWhere((v) => v.id == id);
    await _saveVendors(vendors);
    _emitVendors();
  }

  @override
  Future<int> seedVendorData() async {
    final existing = await _loadVendors();
    if (existing.isNotEmpty) return 0;
    final vendors = seedVendors.map((v) => Vendor(id: _genId(), name: v.name, category: v.category, city: v.city, priceRange: v.priceRange, instagram: v.instagram)).toList();
    await _saveVendors(vendors);
    _emitVendors();
    return vendors.length;
  }

  Future<List<Vendor>> _loadVendors() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_vendorsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => _vendorFromJson(e)).toList();
  }

  Future<void> _saveVendors(List<Vendor> vendors) async {
    final prefs = await _prefs;
    await prefs.setString(_vendorsKey, jsonEncode(vendors.map(_vendorToJson).toList()));
  }

  void _emitVendors({VendorCategory? category, String? city}) async {
    var vendors = await _loadVendors();
    if (category != null) vendors = vendors.where((v) => v.category == category).toList();
    if (city != null) vendors = vendors.where((v) => v.city == city).toList();
    _vendorController?.add(vendors);
  }

  // --- JSON Helpers ---

  Map<String, dynamic> _planToJson(WeddingPlan p) => {
    'id': p.id,
    'weddingDate': '${p.weddingDate.year}-${p.weddingDate.month.toString().padLeft(2,'0')}-${p.weddingDate.day.toString().padLeft(2,'0')}',
    'startDate': '${p.startDate.year}-${p.startDate.month.toString().padLeft(2,'0')}-${p.startDate.day.toString().padLeft(2,'0')}',
    'totalBudget': p.totalBudget,
    'groomName': p.groomName,
    'brideName': p.brideName,
  };

  WeddingPlan _planFromJson(Map<String, dynamic> m) => WeddingPlan(
    id: m['id'],
    weddingDate: _parseDate(m['weddingDate']),
    startDate: _parseDate(m['startDate']),
    totalBudget: (m['totalBudget'] as num).toDouble(),
    groomName: m['groomName'] ?? '',
    brideName: m['brideName'] ?? '',
  );

  Map<String, dynamic> _taskToJson(WeddingTask t) => {
    'id': t.id,
    'title': t.title,
    'dueDate': '${t.dueDate.year}-${t.dueDate.month.toString().padLeft(2,'0')}-${t.dueDate.day.toString().padLeft(2,'0')}',
    'status': t.status.index,
    'phase': t.phase.index,
    'priority': t.priority.index,
  };

  WeddingTask _taskFromJson(Map<String, dynamic> m) => WeddingTask(
    id: m['id'],
    title: m['title'],
    dueDate: _parseDate(m['dueDate']),
    status: TaskStatus.values[m['status'] ?? 0],
    phase: TaskPhase.values[m['phase'] ?? 0],
    priority: TaskPriority.values[m['priority'] ?? 1],
  );

  WeddingTask _taskWithId(WeddingTask t, String id) => WeddingTask(
    id: id, title: t.title, dueDate: t.dueDate, status: t.status, phase: t.phase, priority: t.priority,
  );

  Map<String, dynamic> _budgetToJson(BudgetItem b) => {
    'id': b.id,
    'category': b.category.index,
    'plannedCost': b.plannedCost,
    'actualCost': b.actualCost,
  };

  BudgetItem _budgetFromJson(Map<String, dynamic> m) => BudgetItem(
    id: m['id'],
    category: BudgetCategory.values[m['category'] ?? 6],
    plannedCost: (m['plannedCost'] as num).toDouble(),
    actualCost: (m['actualCost'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> _vendorToJson(Vendor v) => {
    'id': v.id,
    'name': v.name,
    'category': v.category.index,
    'city': v.city,
    'priceRange': v.priceRange,
    'instagram': v.instagram,
  };

  Vendor _vendorFromJson(Map<String, dynamic> m) => Vendor(
    id: m['id'] ?? '',
    name: m['name'] ?? '',
    category: VendorCategory.values[m['category'] ?? 0],
    city: m['city'] ?? '',
    priceRange: m['priceRange'] ?? '',
    instagram: m['instagram'],
  );

  /// Parse date string as local DateTime (avoids UTC issue with DateTime.parse on date-only strings)
  DateTime _parseDate(String s) {
    final parts = s.split('T')[0].split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}
