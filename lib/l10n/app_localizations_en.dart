// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wedding Preparation';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get timeline => 'Timeline';

  @override
  String get budget => 'Budget';

  @override
  String get vendor => 'Vendor';

  @override
  String get profile => 'Profile';

  @override
  String get daysToGo => 'Days To Go';

  @override
  String get preparationProgress => 'Preparation Progress';

  @override
  String tasksCompleted(Object completed, Object total) {
    return '$completed of $total tasks completed';
  }

  @override
  String get budgetSummary => 'Budget Summary';

  @override
  String get totalBudget => 'Total Budget';

  @override
  String get allocated => 'Allocated';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String get upcomingTasks => 'Upcoming Tasks';

  @override
  String get allTasksDone => 'All tasks done! 🎉';

  @override
  String get statusNotStarted => 'Not Started';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusDone => 'Done';

  @override
  String get phase12Months => '12 Months Before';

  @override
  String get phase6Months => '6 Months Before';

  @override
  String get phase3Months => '3 Months Before';

  @override
  String get phase1Month => '1 Month Before';

  @override
  String get phase1Week => '1 Week Before';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get addTask => 'Add Task';

  @override
  String get taskName => 'Task name';

  @override
  String get phase => 'Phase';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get noTasks => 'No tasks yet';

  @override
  String get tasksAppearAfterSetup =>
      'Tasks will appear after setup is complete';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get groomName => 'Groom Name';

  @override
  String get brideName => 'Bride Name';

  @override
  String get weddingDate => 'Wedding Date';

  @override
  String get selectDate => 'Select date';

  @override
  String get startDate => 'Start Preparation';

  @override
  String get totalBudgetLabel => 'Total Budget';

  @override
  String preparationDuration(Object days) {
    return 'Preparation duration: $days days';
  }

  @override
  String get startPreparation => 'Start Preparation';

  @override
  String get completeAllData => 'Please complete all data';

  @override
  String get editTotalBudget => 'Edit Total Budget';

  @override
  String get budgetAllocated => 'Budget Allocated';

  @override
  String get actualCost => 'Actual Cost';

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get premiumDescription =>
      'This feature is available for premium users.\nContact admin for activation after donation.';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String loginFailed(Object error) {
    return 'Login failed: $error';
  }

  @override
  String get noVendors => 'No vendors yet.';

  @override
  String get all => 'All';

  @override
  String get onboardingTitle1 => 'Wedding Preparation';

  @override
  String get onboardingDesc1 =>
      'Plan your dream wedding easily. Everything you need in one app.';

  @override
  String get onboardingTitle2 => 'Timeline & Checklist';

  @override
  String get onboardingDesc2 =>
      'Track every preparation stage from 12 months to D-1. Nothing gets missed.';

  @override
  String get onboardingTitle3 => 'Manage Budget';

  @override
  String get onboardingDesc3 =>
      'Manage your wedding budget in detail. Know exactly how much has been spent.';

  @override
  String get onboardingTitle4 => 'Premium Features';

  @override
  String get onboardingDesc4 =>
      'Access advanced features like budget analytics, vendor recommendations, and invitation templates.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get donationTitle => 'Donate & Activate Premium';

  @override
  String get donationDescription =>
      'Transfer to the account below, then tap \'Request Premium\' to activate.';

  @override
  String get bankInfo => 'Bank Information';

  @override
  String get bank => 'Bank';

  @override
  String get accountNumber => 'Account Number';

  @override
  String get accountName => 'Account Name';

  @override
  String get amount => 'Amount';

  @override
  String get donationAmount => 'Rp 50,000 (or any amount)';

  @override
  String get yourAccount => 'Your Account';

  @override
  String get email => 'Email';

  @override
  String get name => 'Name';

  @override
  String get requestPremium => 'Request Premium';

  @override
  String get requestSent =>
      'Premium request sent! Admin will review and activate your account.';

  @override
  String get requestNote =>
      '* After transfer, tap the button above. Admin will receive a notification and activate your premium account.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get accountInfo => 'Account Info';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get logout => 'Logout';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get settings => 'Settings';

  @override
  String get errorLoadData =>
      'Cannot load data. Check your internet connection.';

  @override
  String errorGeneric(Object error) {
    return 'Error: $error';
  }
}
