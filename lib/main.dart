import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/wedding_provider.dart';
import 'services/local_storage_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/vendor_list_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  runApp(PraNikahApp(showOnboarding: !onboardingDone));
}

class PraNikahApp extends StatefulWidget {
  final bool showOnboarding;
  const PraNikahApp({super.key, required this.showOnboarding});

  @override
  State<PraNikahApp> createState() => _PraNikahAppState();
}

class _PraNikahAppState extends State<PraNikahApp> {
  late bool _showOnboarding;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.showOnboarding;
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('user_locale');
    if (code != null) setState(() => _locale = Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeddingProvider(LocalStorageService()),
      child: MaterialApp(
        title: 'PraNikah',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('id'),
        ],
        home: _buildHome(),
      ),
    );
  }

  Widget _buildHome() {
    if (_showOnboarding) {
      return OnboardingScreen(
        onComplete: () => setState(() => _showOnboarding = false),
        onLocaleChanged: (locale) => setState(() => _locale = locale),
      );
    }
    return AppShell(onLocaleChanged: (locale) => setState(() => _locale = locale));
  }
}

class AppShell extends StatefulWidget {
  final ValueChanged<Locale>? onLocaleChanged;
  const AppShell({super.key, this.onLocaleChanged});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  static const _localUserId = 'local_user';
  late final AnimationController _bannerAnim;

  @override
  void initState() {
    super.initState();
    _bannerAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeddingProvider>().loadPlan(_localUserId);
    });
  }

  @override
  void dispose() {
    _bannerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final titles = [l.dashboard, l.timeline, l.budget, l.vendor, l.profile];

    final screens = [
      const DashboardScreen(),
      const TimelineScreen(),
      const BudgetScreen(),
      const VendorListScreen(),
      ProfileScreen(
        onLocaleChanged: widget.onLocaleChanged,
        onCurrencyChanged: () => setState(() {}),
      ),
    ];

    return Consumer<WeddingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (provider.error != null) {
          final errorMsg = provider.error == 'error_load_data'
              ? l.errorLoadData
              : provider.error!;
          return Scaffold(body: Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(errorMsg, textAlign: TextAlign.center),
            ],
          )));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(titles[_currentIndex]),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.pinkAccent),
                tooltip: 'Support Us',
                onPressed: () => _showTipsPopup(context),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildTopBanner(context),
              Expanded(child: screens[_currentIndex]),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            destinations: [
              NavigationDestination(icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard), label: l.dashboard),
              NavigationDestination(icon: const Icon(Icons.timeline_outlined),
                selectedIcon: const Icon(Icons.timeline), label: l.timeline),
              NavigationDestination(icon: const Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: const Icon(Icons.account_balance_wallet), label: l.budget),
              NavigationDestination(icon: const Icon(Icons.store_outlined),
                selectedIcon: const Icon(Icons.store), label: l.vendor),
              NavigationDestination(icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person), label: l.profile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse('https://ko-fi.com/mohamadsoleh'),
        mode: LaunchMode.externalApplication,
      ),
      child: AnimatedBuilder(
        animation: _bannerAnim,
        builder: (context, child) {
          final glow = 0.3 + (_bannerAnim.value * 0.7);
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pink.shade50,
                  Color.lerp(Colors.orange.shade50, Colors.amber.shade100, _bannerAnim.value)!,
                ],
              ),
            ),
            child: Row(
              children: [
                Opacity(
                  opacity: glow,
                  child: const Text('☕', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Gratis selamanya! Traktir kami kopi untuk support 💕',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.pink.shade300),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTipsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('☕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('Support PraNikah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Aplikasi ini gratis sepenuhnya.\nJika bermanfaat, belikan kami kopi ☕',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            // Bank Mandiri
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text('Bank Mandiri', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  SizedBox(height: 4),
                  Text('1300 0166 5999 0', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Text('a.n. MOHAMAD SOLEH', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse('https://ko-fi.com/mohamadsoleh'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Text('☕', style: TextStyle(fontSize: 16)),
                label: const Text('Ko-fi (PayPal/Card)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
