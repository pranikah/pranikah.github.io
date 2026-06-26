import 'package:flutter/material.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/wedding_provider.dart';
import '../services/currency_helper.dart';
import '../theme/app_theme.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _groomCtrl = TextEditingController();
  final _brideCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  DateTime? _weddingDate;
  DateTime? _startDate;
  bool _loading = false;
  String _selectedCurrency = 'IDR';

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _selectedCurrency = prefs.getString(kCurrencyKey) ?? 'IDR');
  }

  String get _currencySymbol =>
    currencies.firstWhere((c) => c['code'] == _selectedCurrency, orElse: () => currencies[0])['symbol']!;

  void _formatBudget() {
    final text = _budgetCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) return;
    final formatted = NumberFormat('#,###').format(int.parse(text));
    _budgetCtrl.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(child: Text('💍', style: const TextStyle(fontSize: 48))),
              const SizedBox(height: 16),
              Center(
                child: Text(l.appTitle,
                  style: const TextStyle(fontFamily: 'Georgia', fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(l.completeAllData,
                  style: TextStyle(color: AppTheme.textLight)),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _groomCtrl,
                decoration: InputDecoration(
                  labelText: l.groomName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _brideCtrl,
                decoration: InputDecoration(
                  labelText: l.brideName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(l.weddingDate, _weddingDate, (d) => setState(() => _weddingDate = d)),
              const SizedBox(height: 16),
              _buildDatePicker(l.startDate, _startDate, (d) => setState(() => _startDate = d)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                items: currencies.map((c) => DropdownMenuItem(
                  value: c['code'], child: Text(c['label']!),
                )).toList(),
                onChanged: (v) => setState(() => _selectedCurrency = v!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l.totalBudgetLabel,
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  prefixText: '$_currencySymbol ',
                ),
                onChanged: (_) => _formatBudget(),
              ),
              if (_weddingDate != null && _startDate != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppTheme.primaryDark),
                      const SizedBox(width: 8),
                      Text(l.preparationDuration(_weddingDate!.difference(_startDate!).inDays.toString()),
                        style: const TextStyle(color: AppTheme.primaryDark)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _onSubmit,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l.startPreparation),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? value, ValueChanged<DateTime> onPicked) {
    final l = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now().add(const Duration(days: 180)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 730)),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          value != null ? DateFormat('d MMMM yyyy').format(value) : l.selectDate,
          style: TextStyle(color: value != null ? AppTheme.textDark : AppTheme.textLight),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    final l = AppLocalizations.of(context)!;
    if (_weddingDate == null || _startDate == null || _budgetCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.completeAllData)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kCurrencyKey, _selectedCurrency);
      if (!mounted) return;
      await context.read<WeddingProvider>().createPlan(
        groomName: _groomCtrl.text.trim(),
        brideName: _brideCtrl.text.trim(),
        weddingDate: _weddingDate!,
        startDate: _startDate!,
        totalBudget: double.tryParse(_budgetCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }
}
