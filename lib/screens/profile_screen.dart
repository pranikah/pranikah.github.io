import 'package:flutter/material.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/wedding_provider.dart';
import '../services/currency_helper.dart';

class ProfileScreen extends StatefulWidget {
  final ValueChanged<Locale>? onLocaleChanged;
  final VoidCallback? onCurrencyChanged;
  const ProfileScreen({super.key, this.onLocaleChanged, this.onCurrencyChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedLocale = 'en';
  String _selectedCurrency = 'IDR';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLocale = prefs.getString(kLocaleKey) ?? 'en';
      _selectedCurrency = prefs.getString(kCurrencyKey) ?? 'IDR';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Settings Section
        Text(l.settings, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l.language),
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'en', label: Text('EN')),
                    ButtonSegment(value: 'id', label: Text('ID')),
                  ],
                  selected: {_selectedLocale},
                  onSelectionChanged: (v) => _setLocale(v.first),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.monetization_on_outlined),
                title: Text(l.currency),
                trailing: DropdownButton<String>(
                  value: _selectedCurrency,
                  underline: const SizedBox(),
                  items: currencies.map((c) => DropdownMenuItem(
                    value: c['code'], child: Text(c['code']!),
                  )).toList(),
                  onChanged: (v) => _setCurrency(v!),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Reset persiapan
        Card(
          color: Colors.red.shade50,
          child: ListTile(
            leading: Icon(Icons.restart_alt, color: Colors.red.shade700),
            title: Text('Reset Persiapan',
              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600)),
            subtitle: const Text('Hapus semua data dan mulai dari awal', style: TextStyle(fontSize: 12)),
            onTap: () => _confirmReset(context),
          ),
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Persiapan?'),
        content: const Text('Semua data persiapan nikah akan dihapus dan tidak bisa dikembalikan. Yakin ingin reset?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<WeddingProvider>().resetPlan();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _setLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLocaleKey, locale);
    setState(() => _selectedLocale = locale);
    widget.onLocaleChanged?.call(Locale(locale));
  }

  Future<void> _setCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kCurrencyKey, code);
    setState(() => _selectedCurrency = code);
    widget.onCurrencyChanged?.call();
  }
}
