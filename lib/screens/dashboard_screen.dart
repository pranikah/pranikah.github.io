import 'package:flutter/material.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/wedding_plan.dart';
import '../models/wedding_task.dart';
import '../providers/wedding_provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingProvider>(
      builder: (context, provider, _) {
        final plan = provider.plan;
        if (plan == null) return const Center(child: CircularProgressIndicator());

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCountdownCard(context, plan, provider),
              const SizedBox(height: 20),
              _buildProgressCard(context, provider),
              const SizedBox(height: 20),
              _buildBudgetSummaryCard(context, provider),
              const SizedBox(height: 20),
              _buildPendingTasksCard(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountdownCard(BuildContext context, WeddingPlan plan, WeddingProvider provider) {
    final days = plan.daysRemaining;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0, right: 0,
            child: GestureDetector(
              onTap: () => _showEditProfileDialog(context, plan, provider),
              child: const Icon(Icons.edit, size: 18, color: Colors.white54),
            ),
          ),
          Column(
            children: [
              Text('💍', style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                '$days',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.daysToGo,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('d MMMM yyyy').format(plan.weddingDate),
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WeddingPlan plan, WeddingProvider provider) {
    final l = AppLocalizations.of(context)!;
    final groomCtrl = TextEditingController(text: plan.groomName);
    final brideCtrl = TextEditingController(text: plan.brideName);
    DateTime selectedDate = plan.weddingDate;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l.editProfile),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: groomCtrl,
                decoration: InputDecoration(labelText: l.groomName),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: brideCtrl,
                decoration: InputDecoration(labelText: l.brideName),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.weddingDate, style: const TextStyle(fontSize: 12)),
                subtitle: Text(DateFormat('d MMMM yyyy').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
            ElevatedButton(
              onPressed: () {
                provider.updateProfile(
                  groomName: groomCtrl.text.trim(),
                  brideName: brideCtrl.text.trim(),
                  weddingDate: selectedDate,
                );
                Navigator.pop(context);
              },
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, WeddingProvider provider) {
    final l = AppLocalizations.of(context)!;
    final tasks = provider.tasks;
    final completed = tasks.where((t) => t.status == TaskStatus.selesai).length;
    final percent = tasks.isEmpty ? 0.0 : completed / tasks.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 40,
              lineWidth: 8,
              percent: percent,
              center: Text('${(percent * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              progressColor: AppTheme.success,
              backgroundColor: AppTheme.secondary,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.preparationProgress,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(l.tasksCompleted(completed.toString(), tasks.length.toString()),
                    style: const TextStyle(color: AppTheme.textLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSummaryCard(BuildContext context, WeddingProvider provider) {
    final l = AppLocalizations.of(context)!;
    final plan = provider.plan!;
    final items = provider.budgetItems;
    final totalSpent = items.fold<double>(0, (sum, i) => sum + i.actualCost);
    final remaining = plan.totalBudget - totalSpent;
    final f = NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).toString(), decimalDigits: 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💰 ${l.budgetSummary}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 16),
            _budgetRow(l.totalBudget, f.format(plan.totalBudget), AppTheme.textDark),
            _budgetRow(l.spent, f.format(totalSpent), AppTheme.accent),
            _budgetRow(l.remaining, f.format(remaining),
              remaining >= 0 ? AppTheme.success : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _budgetRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textLight)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildPendingTasksCard(BuildContext context, WeddingProvider provider) {
    final l = AppLocalizations.of(context)!;
    final pending = provider.tasks
        .where((t) => t.status != TaskStatus.selesai)
        .take(5)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📋 ${l.upcomingTasks}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            if (pending.isEmpty)
              Text(l.allTasksDone,
                style: const TextStyle(color: AppTheme.textLight))
            else
              ...pending.map((task) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      task.status == TaskStatus.sedangProses
                          ? Icons.timelapse : Icons.circle_outlined,
                      size: 18,
                      color: task.status == TaskStatus.sedangProses
                          ? AppTheme.warning : AppTheme.textLight,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(task.title, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }
}
