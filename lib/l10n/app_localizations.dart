import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Wedding Preparation'**
  String get appTitle;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Plan your dream wedding from start to finish. Manage timeline, budget, vendors, and checklist — all in one app.'**
  String get appDescription;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get vendor;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @daysToGo.
  ///
  /// In en, this message translates to:
  /// **'Days To Go'**
  String get daysToGo;

  /// No description provided for @preparationProgress.
  ///
  /// In en, this message translates to:
  /// **'Preparation Progress'**
  String get preparationProgress;

  /// No description provided for @tasksCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} tasks completed'**
  String tasksCompleted(Object completed, Object total);

  /// No description provided for @budgetSummary.
  ///
  /// In en, this message translates to:
  /// **'Budget Summary'**
  String get budgetSummary;

  /// No description provided for @totalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total Budget'**
  String get totalBudget;

  /// No description provided for @allocated.
  ///
  /// In en, this message translates to:
  /// **'Allocated'**
  String get allocated;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @upcomingTasks.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Tasks'**
  String get upcomingTasks;

  /// No description provided for @allTasksDone.
  ///
  /// In en, this message translates to:
  /// **'All tasks done! 🎉'**
  String get allTasksDone;

  /// No description provided for @statusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get statusNotStarted;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @phase12Months.
  ///
  /// In en, this message translates to:
  /// **'12 Months Before'**
  String get phase12Months;

  /// No description provided for @phase6Months.
  ///
  /// In en, this message translates to:
  /// **'6 Months Before'**
  String get phase6Months;

  /// No description provided for @phase3Months.
  ///
  /// In en, this message translates to:
  /// **'3 Months Before'**
  String get phase3Months;

  /// No description provided for @phase1Month.
  ///
  /// In en, this message translates to:
  /// **'1 Month Before'**
  String get phase1Month;

  /// No description provided for @phase1Week.
  ///
  /// In en, this message translates to:
  /// **'1 Week Before'**
  String get phase1Week;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @taskName.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get taskName;

  /// No description provided for @phase.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get phase;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasks;

  /// No description provided for @tasksAppearAfterSetup.
  ///
  /// In en, this message translates to:
  /// **'Tasks will appear after setup is complete'**
  String get tasksAppearAfterSetup;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @groomName.
  ///
  /// In en, this message translates to:
  /// **'Groom Name'**
  String get groomName;

  /// No description provided for @brideName.
  ///
  /// In en, this message translates to:
  /// **'Bride Name'**
  String get brideName;

  /// No description provided for @weddingDate.
  ///
  /// In en, this message translates to:
  /// **'Wedding Date'**
  String get weddingDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Preparation'**
  String get startDate;

  /// No description provided for @totalBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Budget'**
  String get totalBudgetLabel;

  /// No description provided for @preparationDuration.
  ///
  /// In en, this message translates to:
  /// **'Preparation duration: {days} days'**
  String preparationDuration(Object days);

  /// No description provided for @startPreparation.
  ///
  /// In en, this message translates to:
  /// **'Start Preparation'**
  String get startPreparation;

  /// No description provided for @completeAllData.
  ///
  /// In en, this message translates to:
  /// **'Please complete all data'**
  String get completeAllData;

  /// No description provided for @editTotalBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Total Budget'**
  String get editTotalBudget;

  /// No description provided for @budgetAllocated.
  ///
  /// In en, this message translates to:
  /// **'Budget Allocated'**
  String get budgetAllocated;

  /// No description provided for @actualCost.
  ///
  /// In en, this message translates to:
  /// **'Actual Cost'**
  String get actualCost;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// No description provided for @premiumDescription.
  ///
  /// In en, this message translates to:
  /// **'This feature is available for premium users.\nContact admin for activation after donation.'**
  String get premiumDescription;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogle;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(Object error);

  /// No description provided for @noVendors.
  ///
  /// In en, this message translates to:
  /// **'No vendors yet.'**
  String get noVendors;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Wedding Preparation'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Plan your dream wedding easily. Everything you need in one app.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Timeline & Checklist'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Track every preparation stage from 12 months to D-1. Nothing gets missed.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Manage Budget'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Manage your wedding budget in detail. Know exactly how much has been spent.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get onboardingTitle4;

  /// No description provided for @onboardingDesc4.
  ///
  /// In en, this message translates to:
  /// **'Access advanced features like budget analytics, vendor recommendations, and invitation templates.'**
  String get onboardingDesc4;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @donationTitle.
  ///
  /// In en, this message translates to:
  /// **'Donate & Activate Premium'**
  String get donationTitle;

  /// No description provided for @donationDescription.
  ///
  /// In en, this message translates to:
  /// **'Transfer to the account below, then tap \'Request Premium\' to activate.'**
  String get donationDescription;

  /// No description provided for @bankInfo.
  ///
  /// In en, this message translates to:
  /// **'Bank Information'**
  String get bankInfo;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @donationAmount.
  ///
  /// In en, this message translates to:
  /// **'Rp 50,000 (or any amount)'**
  String get donationAmount;

  /// No description provided for @yourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your Account'**
  String get yourAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @requestPremium.
  ///
  /// In en, this message translates to:
  /// **'Request Premium'**
  String get requestPremium;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Premium request sent! Admin will review and activate your account.'**
  String get requestSent;

  /// No description provided for @requestNote.
  ///
  /// In en, this message translates to:
  /// **'* After transfer, tap the button above. Admin will receive a notification and activate your premium account.'**
  String get requestNote;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get accountInfo;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @errorLoadData.
  ///
  /// In en, this message translates to:
  /// **'Cannot load data. Check your internet connection.'**
  String get errorLoadData;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(Object error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
