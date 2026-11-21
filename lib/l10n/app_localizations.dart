import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navGarages.
  ///
  /// In en, this message translates to:
  /// **'Garages'**
  String get navGarages;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan a warning light'**
  String get navScan;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get homeGreetingEvening;

  /// No description provided for @homeNameFallback.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get homeNameFallback;

  /// No description provided for @homeProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeProfile;

  /// No description provided for @homeAddCarTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first car'**
  String get homeAddCarTitle;

  /// No description provided for @homeAddCarBody.
  ///
  /// In en, this message translates to:
  /// **'So results, reminders and the AI match your car.'**
  String get homeAddCarBody;

  /// No description provided for @homeAddCarButton.
  ///
  /// In en, this message translates to:
  /// **'Add a car'**
  String get homeAddCarButton;

  /// No description provided for @homeChangeCar.
  ///
  /// In en, this message translates to:
  /// **'Change car'**
  String get homeChangeCar;

  /// No description provided for @homeOdometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get homeOdometer;

  /// No description provided for @homeNoMileage.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get homeNoMileage;

  /// No description provided for @homeNextService.
  ///
  /// In en, this message translates to:
  /// **'Next service'**
  String get homeNextService;

  /// No description provided for @homeLicence.
  ///
  /// In en, this message translates to:
  /// **'Licence'**
  String get homeLicence;

  /// No description provided for @homeInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get homeInsurance;

  /// No description provided for @homeNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get homeNotSet;

  /// No description provided for @dueOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get dueOverdue;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dueTomorrow;

  /// No description provided for @dueInDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String dueInDays(int count);

  /// No description provided for @agoToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get agoToday;

  /// No description provided for @agoYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get agoYesterday;

  /// No description provided for @agoDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String agoDays(int count);

  /// No description provided for @homeWarningScanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned {when}'**
  String homeWarningScanned(String when);

  /// No description provided for @homeView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get homeView;

  /// No description provided for @homeFeelsWrong.
  ///
  /// In en, this message translates to:
  /// **'Something feels wrong?'**
  String get homeFeelsWrong;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActions;

  /// No description provided for @homeIconLibrary.
  ///
  /// In en, this message translates to:
  /// **'Icon library'**
  String get homeIconLibrary;

  /// No description provided for @homeReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get homeReminders;

  /// No description provided for @homeSos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get homeSos;

  /// No description provided for @homeComingUp.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get homeComingUp;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeNoReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get homeNoReminders;

  /// No description provided for @homeAddReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get homeAddReminder;

  /// No description provided for @homeRecentScans.
  ///
  /// In en, this message translates to:
  /// **'Recent scans'**
  String get homeRecentScans;

  /// No description provided for @homeNoScans.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get homeNoScans;

  /// No description provided for @homeNoScansBody.
  ///
  /// In en, this message translates to:
  /// **'Scanned lights show up here.'**
  String get homeNoScansBody;

  /// No description provided for @homeMoreLights.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String homeMoreLights(int count);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyAllVehicles.
  ///
  /// In en, this message translates to:
  /// **'All vehicles'**
  String get historyAllVehicles;

  /// No description provided for @historySearch.
  ///
  /// In en, this message translates to:
  /// **'Search warnings'**
  String get historySearch;

  /// No description provided for @historyAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyAll;

  /// No description provided for @groupToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get groupToday;

  /// No description provided for @groupYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get groupYesterday;

  /// No description provided for @groupThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get groupThisWeek;

  /// No description provided for @groupOlder.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get groupOlder;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Scan a warning light and it shows up here.'**
  String get historyEmptyBody;

  /// No description provided for @historyNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No scans match'**
  String get historyNoMatch;

  /// No description provided for @historyNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try another search or filter.'**
  String get historyNoMatchBody;

  /// No description provided for @historyClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get historyClearFilters;

  /// No description provided for @historyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Scan deleted'**
  String get historyDeleted;

  /// No description provided for @historyUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get historyUndo;

  /// No description provided for @historyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get historyDelete;

  /// No description provided for @historyNoCar.
  ///
  /// In en, this message translates to:
  /// **'No car'**
  String get historyNoCar;

  /// No description provided for @scanDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan details'**
  String get scanDetailTitle;

  /// No description provided for @scanDetailGone.
  ///
  /// In en, this message translates to:
  /// **'This scan was deleted.'**
  String get scanDetailGone;

  /// No description provided for @scanDetailLights.
  ///
  /// In en, this message translates to:
  /// **'Lights found'**
  String get scanDetailLights;

  /// No description provided for @scanDetailSure.
  ///
  /// In en, this message translates to:
  /// **'{percent}% sure'**
  String scanDetailSure(int percent);

  /// No description provided for @scanDetailAdvice.
  ///
  /// In en, this message translates to:
  /// **'See advice'**
  String get scanDetailAdvice;

  /// No description provided for @scanDetailAskAi.
  ///
  /// In en, this message translates to:
  /// **'Ask AI about this'**
  String get scanDetailAskAi;

  /// No description provided for @scanDetailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this scan?'**
  String get scanDetailDeleteTitle;

  /// No description provided for @scanDetailDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get scanDetailDeleteBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @sourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get sourceCamera;

  /// No description provided for @sourceGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get sourceGallery;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @settingsAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent colour'**
  String get settingsAccent;

  /// No description provided for @accentGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get accentGreen;

  /// No description provided for @accentBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get accentBlue;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get languageSystem;

  /// No description provided for @settingsUnits.
  ///
  /// In en, this message translates to:
  /// **'Distance units'**
  String get settingsUnits;

  /// No description provided for @unitsKm.
  ///
  /// In en, this message translates to:
  /// **'Kilometres (km)'**
  String get unitsKm;

  /// No description provided for @unitsMiles.
  ///
  /// In en, this message translates to:
  /// **'Miles (mi)'**
  String get unitsMiles;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsReminderAlerts.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsReminderAlerts;

  /// No description provided for @settingsReminderAlertsSub.
  ///
  /// In en, this message translates to:
  /// **'Licence, insurance, service'**
  String get settingsReminderAlertsSub;

  /// No description provided for @settingsAiButton.
  ///
  /// In en, this message translates to:
  /// **'AI chat button'**
  String get settingsAiButton;

  /// No description provided for @settingsAiButtonSub.
  ///
  /// In en, this message translates to:
  /// **'Quick button to ask the AI'**
  String get settingsAiButtonSub;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account and tools'**
  String get settingsAccount;

  /// No description provided for @settingsMyVehicles.
  ///
  /// In en, this message translates to:
  /// **'My vehicles'**
  String get settingsMyVehicles;

  /// No description provided for @settingsEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts'**
  String get settingsEmergency;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About SnapMyAuto'**
  String get settingsAbout;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutTitle;

  /// No description provided for @logoutBody.
  ///
  /// In en, this message translates to:
  /// **'You can log back in any time.'**
  String get logoutBody;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'No internet right now'**
  String get offlineTitle;

  /// No description provided for @offlineBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry, the important parts still work. We\'ll sync when you\'re back online.'**
  String get offlineBody;

  /// No description provided for @offlineStillWorks.
  ///
  /// In en, this message translates to:
  /// **'Still works'**
  String get offlineStillWorks;

  /// No description provided for @offlineScanSub.
  ///
  /// In en, this message translates to:
  /// **'DashLight runs on your phone'**
  String get offlineScanSub;

  /// No description provided for @offlineSos.
  ///
  /// In en, this message translates to:
  /// **'SOS call & SMS'**
  String get offlineSos;

  /// No description provided for @offlineSosSub.
  ///
  /// In en, this message translates to:
  /// **'Uses your mobile network'**
  String get offlineSosSub;

  /// No description provided for @offlineNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'Needs internet'**
  String get offlineNeedsInternet;

  /// No description provided for @offlineAiChat.
  ///
  /// In en, this message translates to:
  /// **'AI chat'**
  String get offlineAiChat;

  /// No description provided for @offlineGarageMap.
  ///
  /// In en, this message translates to:
  /// **'Garage map'**
  String get offlineGarageMap;

  /// No description provided for @settingsReadAloud.
  ///
  /// In en, this message translates to:
  /// **'Read results aloud'**
  String get settingsReadAloud;

  /// No description provided for @settingsReadAloudSub.
  ///
  /// In en, this message translates to:
  /// **'Speaks the result as soon as it opens'**
  String get settingsReadAloudSub;

  /// No description provided for @homeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get homeGetStarted;

  /// No description provided for @homeStepsDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String homeStepsDone(int done, int total);

  /// No description provided for @homeStepAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get homeStepAccount;

  /// No description provided for @homeStepCar.
  ///
  /// In en, this message translates to:
  /// **'Add your car'**
  String get homeStepCar;

  /// No description provided for @homeStepSos.
  ///
  /// In en, this message translates to:
  /// **'Set up SOS contacts'**
  String get homeStepSos;

  /// No description provided for @homeStepScan.
  ///
  /// In en, this message translates to:
  /// **'Do your first scan'**
  String get homeStepScan;

  /// No description provided for @homeHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get homeHealth;

  /// No description provided for @homeHealthGood.
  ///
  /// In en, this message translates to:
  /// **'All good'**
  String get homeHealthGood;

  /// No description provided for @homeHealthOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count} overdue'**
  String homeHealthOverdue(int count);

  /// No description provided for @homeHealthSoon.
  ///
  /// In en, this message translates to:
  /// **'{count} due soon'**
  String homeHealthSoon(int count);

  /// No description provided for @homeHealthLight.
  ///
  /// In en, this message translates to:
  /// **'Warning light'**
  String get homeHealthLight;
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
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
