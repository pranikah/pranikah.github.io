import 'package:flutter/material.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        // User Info Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 28)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(l.profile,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

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
      ],
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
