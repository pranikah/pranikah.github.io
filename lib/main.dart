import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/wedding_provider.dart';
import 'services/local_storage_service.dart';
import 'services/interstitial_ad_service.dart';
import 'services/app_open_ad_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/invitation_design_screen.dart';
import 'screens/vendor_list_screen.dart';
import 'screens/about_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/banner_ad_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }
  await initializeDateFormatting('id', null);
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  runApp(PranikahApp(showOnboarding: !onboardingDone));
}

class PranikahApp extends StatefulWidget {
  final bool showOnboarding;
  const PranikahApp({super.key, required this.showOnboarding});

  @override
  State<PranikahApp> createState() => _PranikahAppState();
}

class _PranikahAppState extends State<PranikahApp> with WidgetsBindingObserver {
  late bool _showOnboarding;
  Locale? _locale;
  final AppOpenAdService _appOpenAdService = AppOpenAdService();

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.showOnboarding;
    _loadLocale();
    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb) {
      _appOpenAdService.loadAd();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appOpenAdService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;
    if (state == AppLifecycleState.paused) {
      _appOpenAdService.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      _appOpenAdService.onAppResumed();
    }
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
        title: 'pranikah',
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

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  static const _localUserId = 'local_user';
  final InterstitialAdService _interstitialAdService = InterstitialAdService();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _interstitialAdService.loadAd();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeddingProvider>().loadPlan(_localUserId);
    });
  }

  @override
  void dispose() {
    _interstitialAdService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final titles = [l.dashboard, l.timeline, l.budget, l.profile];

    final screens = [
      const DashboardScreen(),
      const TimelineScreen(),
      const BudgetScreen(),
      ProfileScreen(
        onLocaleChanged: widget.onLocaleChanged,
        onCurrencyChanged: () => setState(() {}),
      ),
    ];

    return Consumer<WeddingProvider>(
      builder: (context, provider, _) {
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Menu',
                onSelected: (value) {
                  if (value == 'design_undangan') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InvitationDesignScreen(),
                      ),
                    );
                  } else if (value == 'vendor') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VendorListScreen(),
                      ),
                    );
                  } else if (value == 'about') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AboutScreen(),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'design_undangan',
                    child: ListTile(
                      leading: Icon(Icons.mail_outline),
                      title: Text('Design Undangan'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'vendor',
                    child: ListTile(
                      leading: Icon(Icons.store_outlined),
                      title: Text('Vendor'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'about',
                    child: ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('About'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.pinkAccent),
                tooltip: 'Support Us',
                onPressed: () => _showTipsPopup(context),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(child: screens[_currentIndex]),
              const BannerAdWidget(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) {
              if (i != _currentIndex) {
                _interstitialAdService.onTabSwitch();
              }
              setState(() => _currentIndex = i);
            },
            destinations: [
              NavigationDestination(icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard), label: l.dashboard),
              NavigationDestination(icon: const Icon(Icons.timeline_outlined),
                selectedIcon: const Icon(Icons.timeline), label: l.timeline),
              NavigationDestination(icon: const Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: const Icon(Icons.account_balance_wallet), label: l.budget),
              NavigationDestination(icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person), label: l.profile),
            ],
          ),
        );
      },
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
            const Text('Support pranikah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Aplikasi ini gratis sepenuhnya.\nJika bermanfaat, belikan kami kopi ☕',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
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
