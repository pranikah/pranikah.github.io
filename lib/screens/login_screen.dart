import 'package:flutter/material.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💍', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 24),
                Text(l.appTitle,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(l.appDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _login,
                    icon: _loading
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.login),
                    label: Text(l.loginWithGoogle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) widget.onLoginSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.loginFailed(e.toString()))),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }
}
