import 'package:flutter/material.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/wedding_plan.dart';
import '../models/wedding_task.dart';
import '../providers/wedding_provider.dart';
import '../screens/setup_screen.dart';
import '../services/currency_helper.dart';
import '../services/update_checker_service.dart';
import '../screens/update_screen.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  NumberFormat _f = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadCurrency();
    // Check for app updates after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdate();
    });
  }

  Future<void> _checkUpdate() async {
    final releaseInfo = await UpdateCheckerService.checkForUpdate();
    if (releaseInfo != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UpdateScreen(releaseInfo: releaseInfo),
        ),
      );
    }
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(kCurrencyKey) ?? 'IDR';
    setState(() => _f = getCurrencyFormatSync(code));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingProvider>(
      builder: (context, provider, _) {
        final plan = provider.plan;
        if (plan == null) return _buildEmptyState(context);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKofiBanner(),
              const SizedBox(height: 16),
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

  Widget _buildKofiBanner() {
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse('https://ko-fi.com/mohamadsoleh'),
        mode: LaunchMode.externalApplication,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.orange.shade50],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Text('☕', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Gratis selamanya! Traktir kami kopi untuk support 💕',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: Colors.pink.shade300),
          ],
        ),
      ),
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
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.daysToGo,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('d MMMM yyyy').format(plan.weddingDate),
                style: const TextStyle(fontSize: 14, color: Colors.white60),
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
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.secondary,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.success),
                    strokeCap: StrokeCap.round,
                  ),
                  Text('${(percent * 100).toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
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
    final f = _f;

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

  Widget _buildEmptyState(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💍', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(l.appTitle,
              style: const TextStyle(fontFamily: 'Georgia', fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(l.onboardingDesc1,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SetupScreen())),
              icon: const Icon(Icons.add),
              label: Text(l.startPreparation),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
