import 'package:flutter/material.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget_item.dart';
import '../providers/wedding_provider.dart';
import '../services/currency_helper.dart';
import '../theme/app_theme.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  NumberFormat _f = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(kCurrencyKey) ?? 'IDR';
    setState(() => _f = getCurrencyFormatSync(code));
  }

  @override
  Widget build(BuildContext context) {
    final f = _f;

    return Consumer<WeddingProvider>(
      builder: (context, provider, _) {
        final items = provider.budgetItems;
        final plan = provider.plan;
        if (plan == null) return const Center(child: CircularProgressIndicator());

        final totalPlanned = items.fold<double>(0, (s, i) => s + i.plannedCost);
        final totalSpent = items.fold<double>(0, (s, i) => s + i.actualCost);
        final remaining = plan.totalBudget - totalSpent;

        return Column(
          children: [
            _buildSummaryHeader(context, f, plan.totalBudget, totalPlanned, totalSpent, remaining, provider),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💰', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          const Text('Belum ada item budget',
                            style: TextStyle(color: AppTheme.textLight)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _buildBudgetCard(context, items[i], f, provider),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryHeader(BuildContext context, NumberFormat f, double total, double planned, double spent, double remaining, WeddingProvider provider) {
    final l = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l.totalBudget, style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showEditTotalBudget(context, total, provider),
                child: const Icon(Icons.edit, size: 14, color: Colors.white70),
              ),
            ],
          ),
          Text(f.format(total),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryCol(l.allocated, f.format(planned), Colors.white70),
              _summaryCol(l.spent, f.format(spent), AppTheme.accent),
              _summaryCol(l.remaining, f.format(remaining),
                remaining >= 0 ? AppTheme.success : Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildBudgetCard(BuildContext context, BudgetItem item, NumberFormat f, WeddingProvider provider) {
    final percent = (item.progressPercent / 100).clamp(0.0, 1.0);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(item.category.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.category.label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _showEditDialog(context, item, provider),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: AppTheme.secondary,
                valueColor: AlwaysStoppedAnimation(percent > 0.9 ? AppTheme.accent : AppTheme.success),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${f.format(item.actualCost)} / ${f.format(item.plannedCost)}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                Text('Sisa: ${f.format(item.remaining)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                    color: item.remaining >= 0 ? AppTheme.success : Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTotalBudget(BuildContext context, double current, WeddingProvider provider) {
    final l = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: current.toInt().toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.editTotalBudget),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.totalBudgetLabel),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.replaceAll('.', ''));
              if (val != null) provider.updateTotalBudget(val);
              Navigator.pop(context);
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, BudgetItem item, WeddingProvider provider) {
    final l = AppLocalizations.of(context)!;
    final plannedCtrl = TextEditingController(text: item.plannedCost.toInt().toString());
    final actualCtrl = TextEditingController(text: item.actualCost.toInt().toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${item.category.icon} ${item.category.label}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: plannedCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.budgetAllocated),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: actualCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.actualCost),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ElevatedButton(
            onPressed: () {
              provider.updateBudgetItem(item.copyWith(
                plannedCost: double.tryParse(plannedCtrl.text) ?? item.plannedCost,
                actualCost: double.tryParse(actualCtrl.text) ?? item.actualCost,
              ));
              Navigator.pop(context);
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
  }
}
