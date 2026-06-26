import 'package:flutter/material.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/wedding_provider.dart';
import '../services/currency_helper.dart';
import '../services/email_connect_service.dart';

class ProfileScreen extends StatefulWidget {
  final ValueChanged<Locale>? onLocaleChanged;
  final VoidCallback? onCurrencyChanged;
  const ProfileScreen({super.key, this.onLocaleChanged, this.onCurrencyChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailService = EmailConnectService();
  String _selectedLocale = 'en';
  String _selectedCurrency = 'IDR';
  String? _connectedEmail;
  String? _connectedName;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final info = await _emailService.getConnectedInfo();
    setState(() {
      _selectedLocale = prefs.getString(kLocaleKey) ?? 'en';
      _selectedCurrency = prefs.getString(kCurrencyKey) ?? 'IDR';
      _connectedEmail = info['email'];
      _connectedName = info['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Connect Email Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _connectedEmail != null
                ? Row(
                    children: [
                      const CircleAvatar(radius: 24, child: Icon(Icons.person, size: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_connectedName ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(_connectedEmail!,
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.link_off, size: 20),
                        tooltip: 'Disconnect',
                        onPressed: _disconnect,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const CircleAvatar(radius: 24, child: Icon(Icons.email_outlined, size: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Connect Email',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('Untuk fitur request & feedback nanti',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: _connectEmail,
                        child: const Text('Connect'),
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

  Future<void> _connectEmail() async {
    try {
      final email = await _emailService.connectEmail();
      if (email != null) {
        final info = await _emailService.getConnectedInfo();
        setState(() {
          _connectedEmail = info['email'];
          _connectedName = info['name'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal connect: $e')),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    await _emailService.disconnectEmail();
    setState(() {
      _connectedEmail = null;
      _connectedName = null;
    });
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
