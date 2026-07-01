import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App icon
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text('💍', style: TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 16),
            // App name
            const Text(
              'pranikah',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Aplikasi Persiapan Nikah',
              style: TextStyle(fontSize: 14, color: AppTheme.textLight),
            ),
            const SizedBox(height: 8),
            // Version badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'v$_version (build $_buildNumber)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Info cards
            _buildInfoCard(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              description: 'pranikah membantu pasangan merencanakan pernikahan. '
                  'Kelola timeline, budget, vendor, dan buat undangan digital — semua dalam satu aplikasi.',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.code,
              title: 'Open Source',
              description: 'Kode sumber terbuka di GitHub. Kontribusi dan feedback sangat diterima!',
              actionText: 'Buka GitHub',
              onAction: () => _openUrl('https://github.com/pranikah/pranikah.github.io'),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.privacy_tip_outlined,
              title: 'Privasi',
              description: 'Data kamu tersimpan lokal di perangkat. Tidak ada data yang dikirim ke server.',
              actionText: 'Privacy Policy',
              onAction: () => _openUrl('https://pranikah.github.io/privacy-policy.html'),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.email_outlined,
              title: 'Kontak',
              description: 'Ada saran atau bug? Hubungi kami.',
              actionText: 'Kirim Email',
              onAction: () => _openUrl('mailto:pranikah.app@gmail.com?subject=Feedback pranikah v$_version'),
            ),
            const SizedBox(height: 32),
            // Tech stack
            const Text(
              'Dibuat dengan',
              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildTechChip('Flutter'),
                _buildTechChip('Dart'),
                _buildTechChip('Provider'),
                _buildTechChip('Material 3'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '© 2026 pranikah. Dibuat dengan ❤️',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primary),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
          ),
          if (actionText != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTechChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    );
  }
}
