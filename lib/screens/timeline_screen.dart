import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:js_interop' if (dart.library.io) 'dart:js_interop';
import '../models/wedding_task.dart';
import '../providers/wedding_provider.dart';
import '../theme/app_theme.dart';

@JS('showInterstitialAd')
external void _showInterstitialAd();

int _taskUpdateCount = 0;

void _maybeShowAd() {
  _taskUpdateCount++;
  if (_taskUpdateCount % 3 == 0 && kIsWeb) {
    _showInterstitialAd();
  }
}

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingProvider>(
      builder: (context, provider, _) {
        final tasks = provider.tasks;

        if (tasks.isEmpty) {
          final l = AppLocalizations.of(context)!;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timeline_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(l.noTasks, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(l.tasksAppearAfterSetup, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        final grouped = <TaskPhase, List<WeddingTask>>{};
        for (final t in tasks) {
          grouped.putIfAbsent(t.phase, () => []).add(t);
        }

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(20),
              children: TaskPhase.values.where((p) => grouped.containsKey(p)).map((phase) {
                final phaseTasks = grouped[phase]!;
                final completed = phaseTasks.where((t) => t.status == TaskStatus.selesai).length;
                return _buildPhaseSection(context, phase, phaseTasks, completed, provider);
              }).toList(),
            ),
            Positioned(
              bottom: 16, right: 16,
              child: FloatingActionButton(
                onPressed: () => _showAddTaskDialog(context, provider),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context, WeddingProvider provider) {
    final l = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController();
    TaskPhase selectedPhase = TaskPhase.month3;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l.addTask),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: l.taskName),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskPhase>(
                initialValue: selectedPhase,
                decoration: InputDecoration(labelText: l.phase),
                items: TaskPhase.values.map((p) => DropdownMenuItem(
                  value: p, child: Text(phaseLabel(context, p)),
                )).toList(),
                onChanged: (v) => setState(() => selectedPhase = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final plan = provider.plan!;
                final dueDate = selectedPhase == TaskPhase.week1
                    ? plan.weddingDate.subtract(const Duration(days: 7))
                    : DateTime(plan.weddingDate.year,
                        plan.weddingDate.month - selectedPhase.monthsBefore,
                        plan.weddingDate.day);
                provider.addTask(WeddingTask(
                  id: '',
                  title: titleCtrl.text.trim(),
                  dueDate: dueDate,
                  phase: selectedPhase,
                ));
                Navigator.pop(context);
              },
              child: Text(l.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseSection(BuildContext context, TaskPhase phase,
      List<WeddingTask> tasks, int completed, WeddingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month, size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(phaseLabel(context, phase),
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryDark)),
              const SizedBox(width: 8),
              Text('($completed/${tasks.length})',
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...tasks.map((task) => _buildTaskTile(context, task, provider)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTaskTile(BuildContext context, WeddingTask task, WeddingProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statusIcon(task.status),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(task.title, style: TextStyle(
                    fontSize: 14,
                    decoration: task.status == TaskStatus.selesai ? TextDecoration.lineThrough : null,
                    color: task.status == TaskStatus.selesai ? AppTheme.textLight : AppTheme.textDark,
                  )),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (val) {
                    if (val == 'delete') {
                      provider.deleteTask(task.id);
                    }
                  },
                  itemBuilder: (_) => [
                    ...TaskStatus.values.map((s) => PopupMenuItem(
                      onTap: () {
                        provider.updateTaskStatus(task.id, s);
                        _maybeShowAd();
                      },
                      child: Row(children: [
                        Icon(_statusIconData(s), size: 16, color: _statusColor(s)),
                        const SizedBox(width: 8),
                        Text(statusLabel(context, s)),
                      ]),
                    )),
                    const PopupMenuDivider(),
                    ...TaskPriority.values.map((p) => PopupMenuItem(
                      onTap: () => provider.updateTaskPriority(task, p),
                      child: Row(children: [
                        Icon(Icons.flag, size: 16, color: _priorityColor(p)),
                        const SizedBox(width: 8),
                        Text(priorityLabel(context, p)),
                      ]),
                    )),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: 'delete', child: Row(children: [
                      Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ])),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 34, top: 4),
              child: Row(
                children: [
                  Text(DateFormat('d MMM yyyy').format(task.dueDate),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _priorityColor(task.priority).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.flag, size: 10, color: _priorityColor(task.priority)),
                      const SizedBox(width: 2),
                      Text(priorityLabel(context, task.priority),
                        style: TextStyle(fontSize: 9, color: _priorityColor(task.priority), fontWeight: FontWeight.w500)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _statusColor(task.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(statusLabel(context, task.status),
                      style: TextStyle(fontSize: 9, color: _statusColor(task.status), fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIconData(TaskStatus status) {
    switch (status) {
      case TaskStatus.selesai: return Icons.check_circle;
      case TaskStatus.sedangProses: return Icons.timelapse;
      case TaskStatus.belumMulai: return Icons.circle_outlined;
    }
  }

  Widget _statusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.selesai:
        return const Icon(Icons.check_circle, color: AppTheme.success, size: 24);
      case TaskStatus.sedangProses:
        return const Icon(Icons.timelapse, color: AppTheme.warning, size: 24);
      case TaskStatus.belumMulai:
        return const Icon(Icons.circle_outlined, color: AppTheme.textLight, size: 24);
    }
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.selesai: return AppTheme.success;
      case TaskStatus.sedangProses: return AppTheme.warning;
      case TaskStatus.belumMulai: return AppTheme.textLight;
    }
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return Colors.red;
      case TaskPriority.medium: return Colors.orange;
      case TaskPriority.low: return Colors.blue;
    }
  }

  String phaseLabel(BuildContext context, TaskPhase phase) {
    final l = AppLocalizations.of(context)!;
    switch (phase) {
      case TaskPhase.month12: return l.phase12Months;
      case TaskPhase.month6: return l.phase6Months;
      case TaskPhase.month3: return l.phase3Months;
      case TaskPhase.month1: return l.phase1Month;
      case TaskPhase.week1: return l.phase1Week;
    }
  }

  String statusLabel(BuildContext context, TaskStatus status) {
    final l = AppLocalizations.of(context)!;
    switch (status) {
      case TaskStatus.belumMulai: return l.statusNotStarted;
      case TaskStatus.sedangProses: return l.statusInProgress;
      case TaskStatus.selesai: return l.statusDone;
    }
  }

  String priorityLabel(BuildContext context, TaskPriority priority) {
    final l = AppLocalizations.of(context)!;
    switch (priority) {
      case TaskPriority.high: return l.priorityHigh;
      case TaskPriority.medium: return l.priorityMedium;
      case TaskPriority.low: return l.priorityLow;
    }
  }
}
