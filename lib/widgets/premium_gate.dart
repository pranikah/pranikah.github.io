import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/premium_service.dart';
import '../services/auth_service.dart';

/// Wrap fitur premium dengan widget ini.
/// Jika user bukan premium, tampilkan [lockedChild] atau default lock screen.
class PremiumGate extends StatelessWidget {
  final Widget child;
  final Widget? lockedChild;
  final PremiumService _premiumService = PremiumService();
  final AuthService _authService = AuthService();

  PremiumGate({super.key, required this.child, this.lockedChild});

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    // Belum login → tampilkan lock
    if (user == null) {
      return lockedChild ?? _buildDefaultLock(context, loggedIn: false);
    }

    return StreamBuilder<bool>(
      stream: _premiumService
          .getPremiumStatus(user.uid)
          .map((p) => p?.isActive ?? false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final isPremium = snapshot.data ?? false;
        if (isPremium) return child;
        return lockedChild ?? _buildDefaultLock(context, loggedIn: true);
      },
    );
  }

  Widget _buildDefaultLock(BuildContext context, {required bool loggedIn}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Fitur Premium',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fitur ini tersedia untuk pengguna premium.\n'
              'Hubungi admin untuk aktivasi setelah donasi.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!loggedIn)
              ElevatedButton.icon(
                onPressed: () => _authService.signInWithGoogle(),
                icon: const Icon(Icons.login),
                label: const Text('Login dengan Google'),
              ),
          ],
        ),
      ),
    );
  }
}
