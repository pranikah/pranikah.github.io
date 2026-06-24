import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/wedding_provider.dart';
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

  @override
  Widget build(BuildContext context) {
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
                child: Text('Persiapan Nikah',
                  style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('Isi data untuk memulai persiapan',
                  style: TextStyle(color: AppTheme.textLight)),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _groomCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Calon Suami',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _brideCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Calon Istri',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              _buildDatePicker('Tanggal Pernikahan', _weddingDate, (d) => setState(() => _weddingDate = d)),
              const SizedBox(height: 16),
              _buildDatePicker('Mulai Persiapan', _startDate, (d) => setState(() => _startDate = d)),
              const SizedBox(height: 16),
              TextField(
                controller: _budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Budget (Rp)',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
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
                      Text('Durasi persiapan: ${_weddingDate!.difference(_startDate!).inDays} hari',
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
                      : const Text('Mulai Persiapan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? value, ValueChanged<DateTime> onPicked) {
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
          value != null ? DateFormat('d MMMM yyyy', 'id').format(value) : 'Pilih tanggal',
          style: TextStyle(color: value != null ? AppTheme.textDark : AppTheme.textLight),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_weddingDate == null || _startDate == null || _budgetCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await context.read<WeddingProvider>().createPlan(
        groomName: _groomCtrl.text.trim(),
        brideName: _brideCtrl.text.trim(),
        weddingDate: _weddingDate!,
        startDate: _startDate!,
        totalBudget: double.tryParse(_budgetCtrl.text.replaceAll('.', '')) ?? 0,
      );
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
