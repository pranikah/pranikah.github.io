import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/admin_screen.dart';
import '../services/auth_service.dart';
import '../services/currency_helper.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final ValueChanged<Locale>? onLocaleChanged;
  final VoidCallback? onCurrencyChanged;
  const ProfileScreen({super.key, this.onLocaleChanged, this.onCurrencyChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
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
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user != null && adminEmails.contains(user.email);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // User Info Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null ? const Icon(Icons.person, size: 28) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? l.notLoggedIn,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      if (user?.email != null)
                        Text(user!.email!, style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
                    ],
                  ),
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
        const SizedBox(height: 20),

        // Admin Panel (hanya untuk admin)
        if (isAdmin) ...[
          Card(
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: AppTheme.primary),
              title: Text(l.adminPanel),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => AdminScreen())),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Login/Logout
        if (user == null)
          ElevatedButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _authService.signInWithGoogle();
                setState(() {});
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(l.loginFailed(e.toString()))),
                  );
                }
              }
            },
            icon: const Icon(Icons.login),
            label: Text(l.loginWithGoogle),
          )
        else
          OutlinedButton.icon(
            onPressed: () async {
              await _authService.signOut();
              setState(() {});
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: Text(l.logout, style: const TextStyle(color: Colors.red)),
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
