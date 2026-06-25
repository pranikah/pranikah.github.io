import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'providers/wedding_provider.dart';
import 'services/firebase_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/onboarding_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.showOnboarding;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeddingProvider(FirebaseService())..loadPlan('default_plan'),
      child: MaterialApp(
        title: 'Persiapan Nikah',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: _showOnboarding
            ? OnboardingScreen(onComplete: () => setState(() => _showOnboarding = false))
            : const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    TimelineScreen(),
    BudgetScreen(),
    VendorListScreen(),
  ];

  final _titles = const ['Dashboard', 'Timeline', 'Budget', 'Vendor'];

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (provider.error != null) {
          return Scaffold(body: Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(provider.error!, textAlign: TextAlign.center),
            ],
          )));
        }
        if (!provider.hasPlan) return const SetupScreen();

        return Scaffold(
          appBar: AppBar(title: Text(_titles[_currentIndex])),
          body: _screens[_currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.timeline_outlined),
                selectedIcon: Icon(Icons.timeline), label: 'Timeline'),
              NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet), label: 'Budget'),
              NavigationDestination(icon: Icon(Icons.store_outlined),
                selectedIcon: Icon(Icons.store), label: 'Vendor'),
            ],
          ),
        );
      },
    );
  }
}
