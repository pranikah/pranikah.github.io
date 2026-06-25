import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/premium_service.dart';
import '../theme/app_theme.dart';

class DonationScreen extends StatefulWidget {
  final User user;
  const DonationScreen({super.key, required this.user});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _premiumService = PremiumService();
  bool _submitted = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Icon(Icons.volunteer_activism, size: 64, color: AppTheme.primary)),
          const SizedBox(height: 16),
          const Center(child: Text('Donasi & Aktivasi Premium',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          const Center(child: Text(
            'Transfer ke rekening di bawah, lalu klik "Request Premium" untuk aktivasi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textLight),
          )),
          const SizedBox(height: 24),

          // Info Rekening
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💳 Informasi Rekening',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 12),
                  _infoRow('Bank', 'BCA'),
                  _infoRow('No. Rekening', '8310774334'),
                  _infoRow('Atas Nama', 'Mohamad Hadi'),
                  _infoRow('Nominal', 'Rp 50.000 (seikhlasnya)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info User
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('👤 Akun Kamu',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 12),
                  _infoRow('Email', widget.user.email ?? '-'),
                  _infoRow('Nama', widget.user.displayName ?? '-'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          if (_submitted)
            const Card(
              color: Color(0xFFE8F5E9),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(child: Text(
                      'Request premium terkirim! Admin akan mereview dan mengaktifkan akunmu.',
                      style: TextStyle(color: Colors.green),
                    )),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submitRequest,
                icon: _loading
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: const Text('Request Premium'),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            '* Setelah transfer, klik tombol di atas. Admin akan menerima notifikasi email dan mengaktifkan akun premium kamu.',
            style: TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label,
            style: const TextStyle(color: AppTheme.textLight))),
          Expanded(child: Text(value,
            style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Future<void> _submitRequest() async {
    setState(() => _loading = true);
    try {
      await _premiumService.requestPremium(
        widget.user.uid,
        widget.user.email ?? '',
        widget.user.displayName ?? '',
      );
      // Send notification email to admin via Firestore trigger
      await _premiumService.notifyAdmin(
        widget.user.email ?? '',
        widget.user.displayName ?? '',
      );
      setState(() => _submitted = true);
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
