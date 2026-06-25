import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'providers/wedding_provider.dart';
import 'services/firebase_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/login_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/vendor_list_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      create: (_) => WeddingProvider(FirebaseService())..loadPlan('default_plan'),
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
    // Step 1: Onboarding
    if (_showOnboarding) {
      return OnboardingScreen(
        onComplete: () => setState(() => _showOnboarding = false),
        onLocaleChanged: (locale) => setState(() => _locale = locale),
      );
    }

    // Step 2: Check login — jika belum login, tampilkan LoginScreen
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == null) {
          return LoginScreen(onLoginSuccess: () => setState(() {}));
        }
        // Step 3: Sudah login → AppShell (setup atau app)
        return AppShell(onLocaleChanged: (locale) => setState(() => _locale = locale));
      },
    );
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
        if (!provider.hasPlan) return const SetupScreen();

        return Scaffold(
          appBar: AppBar(title: Text(titles[_currentIndex])),
          body: screens[_currentIndex],
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
}
