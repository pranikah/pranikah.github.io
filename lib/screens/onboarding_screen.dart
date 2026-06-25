import 'package:flutter/material.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/currency_helper.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final ValueChanged<Locale>? onLocaleChanged;
  const OnboardingScreen({super.key, required this.onComplete, this.onLocaleChanged});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  String _selectedLocale = 'en';

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _selectedLocale = prefs.getString(kLocaleKey) ?? 'en');
  }

  List<_PageData> _pages(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [
      _PageData(icon: Icons.favorite_outline, title: l.onboardingTitle1,
        description: l.onboardingDesc1, color: const Color(0xFFE91E63)),
      _PageData(icon: Icons.timeline, title: l.onboardingTitle2,
        description: l.onboardingDesc2, color: const Color(0xFF9C27B0)),
      _PageData(icon: Icons.account_balance_wallet, title: l.onboardingTitle3,
        description: l.onboardingDesc3, color: const Color(0xFF3F51B5)),
      _PageData(icon: Icons.star_outline, title: l.onboardingTitle4,
        description: l.onboardingDesc4, color: const Color(0xFFFF9800)),
    ];
  }

  void _next() {
    if (_currentPage < 3) {
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
    final l = AppLocalizations.of(context)!;
    final pages = _pages(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Language + Skip row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  ToggleButtons(
                    isSelected: [_selectedLocale == 'en', _selectedLocale == 'id'],
                    borderRadius: BorderRadius.circular(8),
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 32),
                    textStyle: const TextStyle(fontSize: 12),
                    onPressed: (i) async {
                      final locale = i == 0 ? 'en' : 'id';
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(kLocaleKey, locale);
                      setState(() => _selectedLocale = locale);
                      widget.onLocaleChanged?.call(Locale(locale));
                    },
                    children: const [Text('EN'), Text('ID')],
                  ),
                  const Spacer(),
                  TextButton(onPressed: _finish, child: Text(l.skip)),
                ],
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _buildPage(pages[i]),
              ),
            ),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i ? pages[i].color : Colors.grey.shade300,
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
                  child: Text(_currentPage == pages.length - 1 ? l.getStarted : l.next),
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
