import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _PageData(
      icon: Icons.favorite_outline,
      title: 'Persiapan Nikah',
      description: 'Rencanakan pernikahan impianmu dengan mudah. '
          'Semua yang kamu butuhkan dalam satu aplikasi.',
      color: Color(0xFFE91E63),
    ),
    _PageData(
      icon: Icons.timeline,
      title: 'Timeline & Checklist',
      description: 'Pantau setiap tahapan persiapan dari 12 bulan '
          'hingga H-1. Tidak ada yang terlewat.',
      color: Color(0xFF9C27B0),
    ),
    _PageData(
      icon: Icons.account_balance_wallet,
      title: 'Kelola Budget',
      description: 'Atur anggaran pernikahan dengan detail. '
          'Tahu persis berapa yang sudah dan belum dikeluarkan.',
      color: Color(0xFF3F51B5),
    ),
    _PageData(
      icon: Icons.star_outline,
      title: 'Fitur Premium',
      description: 'Akses fitur lanjutan seperti analitik budget, '
          'rekomendasi vendor, dan template undangan.',
      color: Color(0xFFFF9800),
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: _finish, child: const Text('Lewati')),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _buildPage(_pages[i]),
              ),
            ),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i ? _pages[i].color : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),
            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_currentPage == _pages.length - 1 ? 'Mulai' : 'Lanjut'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_PageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 80, color: page.color),
          ),
          const SizedBox(height: 40),
          Text(page.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(page.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  const _PageData({required this.icon, required this.title, required this.description, required this.color});
}
