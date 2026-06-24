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

  StreamSubscription? _planSub;
  StreamSubscription? _tasksSub;
  StreamSubscription? _budgetSub;

  WeddingPlan? get plan => _plan;
  List<WeddingTask> get tasks => _tasks;
  List<BudgetItem> get budgetItems => _budgetItems;
  bool get hasPlan => _plan != null;

  void loadPlan(String planId) {
    _planId = planId;
    _planSub?.cancel();
    _tasksSub?.cancel();
    _budgetSub?.cancel();

    _planSub = _service.getPlan(planId).listen((p) {
      _plan = p;
      notifyListeners();
    }, onError: (_) {});

    _tasksSub = _service.getTasks(planId).listen((t) {
      _tasks = t;
      notifyListeners();
    }, onError: (_) {});

    _budgetSub = _service.getBudgetItems(planId).listen((b) {
      _budgetItems = b;
      notifyListeners();
    }, onError: (_) {});
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

  Future<void> updateBudgetItem(BudgetItem item) async {
    if (_planId == null) return;
    await _service.updateBudgetItem(_planId!, item);
  }

  @override
  void dispose() {
    _planSub?.cancel();
    _tasksSub?.cancel();
    _budgetSub?.cancel();
    super.dispose();
  }
}
