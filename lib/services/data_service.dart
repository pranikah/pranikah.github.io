import '../models/wedding_plan.dart';
import '../models/wedding_task.dart';
import '../models/budget_item.dart';
import '../models/vendor.dart';

/// Abstract interface untuk data layer.
/// Sekarang: FirebaseDataService (Firestore)
/// Nanti: ApiDataService (REST API + MySQL/PostgreSQL)
abstract class DataService {
  // Wedding Plan
  Future<void> savePlan(WeddingPlan plan);
  Future<void> updatePlan(String planId, Map<String, dynamic> data);
  Stream<WeddingPlan?> getPlan(String planId);

  // Tasks
  Future<void> addTask(String planId, WeddingTask task);
  Future<void> updateTaskStatus(String planId, String taskId, TaskStatus status);
  Future<void> updateTaskPriority(String planId, String taskId, TaskPriority priority, DateTime newDueDate);
  Future<void> deleteTask(String planId, String taskId);
  Stream<List<WeddingTask>> getTasks(String planId);
  Future<void> generateDefaultTasks(String planId, DateTime weddingDate);
  Future<void> ensureTasksExist(String planId, DateTime weddingDate);

  // Budget
  Future<void> addBudgetItem(String planId, BudgetItem item);
  Future<void> updateBudgetItem(String planId, BudgetItem item);
  Stream<List<BudgetItem>> getBudgetItems(String planId);
  Future<void> deleteBudgetItem(String planId, String itemId);

  // Vendors
  Stream<List<Vendor>> getVendors({VendorCategory? category, String? city});
  Future<void> addVendor(Vendor vendor);
  Future<void> deleteVendor(String id);
  Future<int> seedVendorData();
}
