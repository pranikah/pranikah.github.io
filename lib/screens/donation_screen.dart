import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Icon(Icons.volunteer_activism, size: 64, color: AppTheme.primary)),
          const SizedBox(height: 16),
          Center(child: Text(l.donationTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          Center(child: Text(l.donationDescription,
            textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textLight))),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Bank_Mandiri_logo_2016.svg/200px-Bank_Mandiri_logo_2016.svg.png',
                        height: 24,
                        errorBuilder: (_, __, ___) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003580),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('mandiri',
                            style: TextStyle(color: Color(0xFFFFCC00), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(l.bankInfo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoRow(l.accountNumber, '1300 0166 5999 0'),
                  _infoRow(l.accountName, 'MOHAMAD SOLEH'),
                  _infoRow(l.amount, l.donationAmount),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // International payment
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        'https://www.paypalobjects.com/webstatic/icon/pp258.png',
                        width: 28, height: 28,
                        errorBuilder: (_, __, ___) => const Icon(Icons.payment, color: Color(0xFF003087)),
                      ),
                      const SizedBox(width: 8),
                      const Text('PayPal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse('https://ko-fi.com/mohamadsoleh'), mode: LaunchMode.externalApplication),
                      icon: const Text('☕', style: TextStyle(fontSize: 18)),
                      label: const Text('Tips via Ko-fi (PayPal/Card)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('👤 ${l.yourAccount}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 12),
                  _infoRow(l.email, widget.user.email ?? '-'),
                  _infoRow(l.name, widget.user.displayName ?? '-'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_submitted)
            Card(
              color: const Color(0xFFE8F5E9),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.requestSent, style: const TextStyle(color: Colors.green))),
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
                label: Text(l.requestPremium),
              ),
            ),
          const SizedBox(height: 12),
          Text(l.requestNote, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
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
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppTheme.textLight))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Future<void> _submitRequest() async {
    setState(() => _loading = true);
    try {
      await _premiumService.requestPremium(
        widget.user.uid, widget.user.email ?? '', widget.user.displayName ?? '');
      await _premiumService.notifyAdmin(widget.user.email ?? '', widget.user.displayName ?? '');
      setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString()))),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }
}
