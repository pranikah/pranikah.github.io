import 'package:flutter/material.dart';
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
              _buildCountdownCard(plan),
              const SizedBox(height: 20),
              _buildProgressCard(provider),
              const SizedBox(height: 20),
              _buildBudgetSummaryCard(provider),
              const SizedBox(height: 20),
              _buildPendingTasksCard(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountdownCard(WeddingPlan plan) {
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
      child: Column(
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
            'Hari Menuju Hari H',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('d MMMM yyyy', 'id').format(plan.weddingDate),
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(WeddingProvider provider) {
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
                  const Text('Progress Persiapan',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('$completed dari ${tasks.length} tugas selesai',
                    style: const TextStyle(color: AppTheme.textLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSummaryCard(WeddingProvider provider) {
    final plan = provider.plan!;
    final items = provider.budgetItems;
    final totalSpent = items.fold<double>(0, (sum, i) => sum + i.actualCost);
    final remaining = plan.totalBudget - totalSpent;
    final f = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💰 Ringkasan Budget',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 16),
            _budgetRow('Total Budget', f.format(plan.totalBudget), AppTheme.textDark),
            _budgetRow('Terpakai', f.format(totalSpent), AppTheme.accent),
            _budgetRow('Sisa', f.format(remaining),
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

  Widget _buildPendingTasksCard(WeddingProvider provider) {
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
            const Text('📋 Tugas Mendatang',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            if (pending.isEmpty)
              const Text('Semua tugas selesai! 🎉',
                style: TextStyle(color: AppTheme.textLight))
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
