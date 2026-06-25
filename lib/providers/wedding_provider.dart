import 'dart:async';
import 'package:flutter/material.dart';
import '../models/wedding_plan.dart';
import '../models/wedding_task.dart';
import '../models/budget_item.dart';
import '../services/data_service.dart';

class WeddingProvider extends ChangeNotifier {
  final DataService _service;

  WeddingProvider(this._service);

  WeddingPlan? _plan;
  List<WeddingTask> _tasks = [];
  List<BudgetItem> _budgetItems = [];
  String? _planId;
  bool _isLoading = true;
  bool _tasksChecked = false;
  String? _error;

  StreamSubscription? _planSub;
  StreamSubscription? _tasksSub;
  StreamSubscription? _budgetSub;

  WeddingPlan? get plan => _plan;
  List<WeddingTask> get tasks => _tasks;
  List<BudgetItem> get budgetItems => _budgetItems;
  bool get hasPlan => _plan != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadPlan(String planId) {
    _planId = planId;
    _isLoading = true;
    _tasksChecked = false;
    _error = null;
    _planSub?.cancel();
    _tasksSub?.cancel();
    _budgetSub?.cancel();

    _planSub = _service.getPlan(planId).listen((p) {
      _plan = p;
      _isLoading = false;
      notifyListeners();
      if (p != null && !_tasksChecked) {
        _tasksChecked = true;
        _service.ensureTasksExist(planId, p.weddingDate);
      }
    }, onError: (e) {
      _error = 'Gagal memuat data: $e';
      _isLoading = false;
      notifyListeners();
    });

    _tasksSub = _service.getTasks(planId).listen((t) {
      _tasks = t;
      notifyListeners();
    }, onError: (e) {
      _error = 'Gagal memuat tugas: $e';
      notifyListeners();
    });

    _budgetSub = _service.getBudgetItems(planId).listen((b) {
      _budgetItems = b;
      notifyListeners();
    }, onError: (e) {
      _error = 'Gagal memuat budget: $e';
      notifyListeners();
    });
  }

  Future<void> createPlan({
    required String groomName,
    required String brideName,
    required DateTime weddingDate,
    required DateTime startDate,
    required double totalBudget,
  }) async {
    const planId = 'default_plan';
    final plan = WeddingPlan(
      id: planId,
      weddingDate: weddingDate,
      startDate: startDate,
      totalBudget: totalBudget,
      groomName: groomName,
      brideName: brideName,
    );

    await _service.savePlan(plan);
    await _service.generateDefaultTasks(planId, weddingDate);

    // Generate default budget items
    final defaultBudget = {
      BudgetCategory.venue: totalBudget * 0.25,
      BudgetCategory.catering: totalBudget * 0.30,
      BudgetCategory.dekorasi: totalBudget * 0.15,
      BudgetCategory.dokumentasi: totalBudget * 0.10,
      BudgetCategory.busana: totalBudget * 0.08,
      BudgetCategory.undangan: totalBudget * 0.05,
      BudgetCategory.lainnya: totalBudget * 0.07,
    };

    for (final entry in defaultBudget.entries) {
      await _service.addBudgetItem(planId, BudgetItem(
        id: '',
        category: entry.key,
        plannedCost: entry.value,
      ));
    }

    loadPlan(planId);
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    if (_planId == null) return;
    await _service.updateTaskStatus(_planId!, taskId, status);
  }

  Future<void> updateTaskPriority(WeddingTask task, TaskPriority priority) async {
    if (_planId == null || _plan == null) return;
    // Hitung due date baru berdasar priority
    final baseDueDate = task.phase == TaskPhase.week1
        ? _plan!.weddingDate.subtract(const Duration(days: 7))
        : DateTime(_plan!.weddingDate.year,
            _plan!.weddingDate.month - task.phase.monthsBefore,
            _plan!.weddingDate.day);
    final newDueDate = baseDueDate.add(Duration(days: priority.dayOffset));
    await _service.updateTaskPriority(_planId!, task.id, priority, newDueDate);
  }

  Future<void> addTask(WeddingTask task) async {
    if (_planId == null) return;
    await _service.addTask(_planId!, task);
  }

  Future<void> deleteTask(String taskId) async {
    if (_planId == null) return;
    await _service.deleteTask(_planId!, taskId);
  }

  Future<void> updateBudgetItem(BudgetItem item) async {
    if (_planId == null) return;
    await _service.updateBudgetItem(_planId!, item);
  }

  Future<void> updateTotalBudget(double newBudget) async {
    if (_planId == null) return;
    await _service.updatePlan(_planId!, {'totalBudget': newBudget});
  }

  Future<void> updateProfile({String? groomName, String? brideName, DateTime? weddingDate}) async {
    if (_planId == null) return;
    final data = <String, dynamic>{};
    if (groomName != null) data['groomName'] = groomName;
    if (brideName != null) data['brideName'] = brideName;
    if (weddingDate != null) {
      data['weddingDate'] = weddingDate;
    }
    await _service.updatePlan(_planId!, data);
  }

  @override
  void dispose() {
    _planSub?.cancel();
    _tasksSub?.cancel();
    _budgetSub?.cancel();
    super.dispose();
  }
}
