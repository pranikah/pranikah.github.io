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

  List<_PageData> _pages(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [
      _PageData(icon: Icons.favorite_outline, title: l.onboardingTitle1,
        description: l.onboardingDesc1, color: const Color(0xFFE91E63)),
      _PageData(icon: Icons.timeline, title: l.onboardingTitle2,
        description: l.onboardingDesc2, color: const Color(0xFF9C27B0)),
      _PageData(icon: Icons.account_balance_wallet, title: l.onboardingTitle3,
        description: l.onboardingDesc3, color: const Color(0xFF3F51B5)),
    ];
  }

  void _next() {
    final totalPages = _pages(context).length + 1; // +1 for settings page
    if (_currentPage < totalPages - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await prefs.setString(kLocaleKey, _selectedLocale);
    await prefs.setString(kCurrencyKey, _selectedCurrency);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pages = _pages(context);
    final totalPages = pages.length + 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [const Spacer(), TextButton(onPressed: _finish, child: Text(l.skip))],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  ...pages.map(_buildPage),
                  _buildSettingsPage(context),
                ],
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalPages, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i ? const Color(0xFFE91E63) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_currentPage == totalPages - 1 ? l.getStarted : l.next),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPage(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings_outlined, size: 80, color: Color(0xFFFF9800)),
          ),
          const SizedBox(height: 32),
          Text(l.language, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'en', label: Text('English')),
              ButtonSegment(value: 'id', label: Text('Indonesia')),
            ],
            selected: {_selectedLocale},
            onSelectionChanged: (v) {
              setState(() => _selectedLocale = v.first);
              widget.onLocaleChanged?.call(Locale(v.first));
            },
          ),
          const SizedBox(height: 24),
          Text(l.currency, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedCurrency,
            isExpanded: true,
            items: currencies.map((c) => DropdownMenuItem(
              value: c['code'], child: Text(c['label']!),
            )).toList(),
            onChanged: (v) => setState(() => _selectedCurrency = v!),
          ),
        ],
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
