// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navGarages => 'Garages';

  @override
  String get navMore => 'More';

  @override
  String get navScan => 'Scan a warning light';

  @override
  String get homeGreetingMorning => 'Good morning,';

  @override
  String get homeGreetingAfternoon => 'Good afternoon,';

  @override
  String get homeGreetingEvening => 'Good evening,';

  @override
  String get homeNameFallback => 'Driver';

  @override
  String get homeProfile => 'Profile';

  @override
  String get homeAddCarTitle => 'Add your first car';

  @override
  String get homeAddCarBody =>
      'So results, reminders and the AI match your car.';

  @override
  String get homeAddCarButton => 'Add a car';

  @override
  String get homeChangeCar => 'Change car';

  @override
  String get homeOdometer => 'Odometer';

  @override
  String get homeNoMileage => 'Not added';

  @override
  String get homeNextService => 'Next service';

  @override
  String get homeLicence => 'Licence';

  @override
  String get homeInsurance => 'Insurance';

  @override
  String get homeNotSet => 'Not set';

  @override
  String get dueOverdue => 'Overdue';

  @override
  String get dueToday => 'Today';

  @override
  String get dueTomorrow => 'Tomorrow';

  @override
  String dueInDays(int count) {
    return '$count days';
  }

  @override
  String get agoToday => 'today';

  @override
  String get agoYesterday => 'yesterday';

  @override
  String agoDays(int count) {
    return '$count days ago';
  }

  @override
  String homeWarningScanned(String when) {
    return 'Scanned $when';
  }

  @override
  String get homeView => 'View';

  @override
  String get homeFeelsWrong => 'Something feels wrong?';

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get homeIconLibrary => 'Icon library';

  @override
  String get homeReminders => 'Reminders';

  @override
  String get homeSos => 'SOS';

  @override
  String get homeComingUp => 'Coming up';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeNoReminders => 'No reminders yet';

  @override
  String get homeAddReminder => 'Add reminder';

  @override
  String get homeRecentScans => 'Recent scans';

  @override
  String get homeNoScans => 'No scans yet';

  @override
  String get homeNoScansBody => 'Scanned lights show up here.';

  @override
  String homeMoreLights(int count) {
    return '+$count more';
  }

  @override
  String get historyTitle => 'History';

  @override
  String get historyAllVehicles => 'All vehicles';

  @override
  String get historySearch => 'Search warnings';

  @override
  String get historyAll => 'All';

  @override
  String get groupToday => 'Today';

  @override
  String get groupYesterday => 'Yesterday';

  @override
  String get groupThisWeek => 'This week';

  @override
  String get groupOlder => 'Earlier';

  @override
  String get historyEmptyTitle => 'No scans yet';

  @override
  String get historyEmptyBody => 'Scan a warning light and it shows up here.';

  @override
  String get historyNoMatch => 'No scans match';

  @override
  String get historyNoMatchBody => 'Try another search or filter.';

  @override
  String get historyClearFilters => 'Clear filters';

  @override
  String get historyDeleted => 'Scan deleted';

  @override
  String get historyUndo => 'Undo';

  @override
  String get historyDelete => 'Delete';

  @override
  String get historyNoCar => 'No car';

  @override
  String get scanDetailTitle => 'Scan details';

  @override
  String get scanDetailGone => 'This scan was deleted.';

  @override
  String get scanDetailLights => 'Lights found';

  @override
  String scanDetailSure(int percent) {
    return '$percent% sure';
  }

  @override
  String get scanDetailAdvice => 'See advice';

  @override
  String get scanDetailAskAi => 'Ask AI about this';

  @override
  String get scanDetailDeleteTitle => 'Delete this scan?';

  @override
  String get scanDetailDeleteBody => 'This can\'t be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get sourceCamera => 'Camera';

  @override
  String get sourceGallery => 'Photo';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get settingsAccent => 'Accent colour';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentBlue => 'Blue';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get settingsUnits => 'Distance units';

  @override
  String get unitsKm => 'Kilometres (km)';

  @override
  String get unitsMiles => 'Miles (mi)';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsReminderAlerts => 'Reminders';

  @override
  String get settingsReminderAlertsSub => 'Licence, insurance, service';

  @override
  String get settingsAiButton => 'AI chat button';

  @override
  String get settingsAiButtonSub => 'Quick button to ask the AI';

  @override
  String get settingsAccount => 'Account and tools';

  @override
  String get settingsMyVehicles => 'My vehicles';

  @override
  String get settingsEmergency => 'Emergency contacts';

  @override
  String get settingsAbout => 'About SnapMyAuto';

  @override
  String get logout => 'Log out';

  @override
  String get logoutTitle => 'Log out?';

  @override
  String get logoutBody => 'You can log back in any time.';

  @override
  String get offlineTitle => 'No internet right now';

  @override
  String get offlineBody =>
      'Don\'t worry, the important parts still work. We\'ll sync when you\'re back online.';

  @override
  String get offlineStillWorks => 'Still works';

  @override
  String get offlineScanSub => 'DashLight runs on your phone';

  @override
  String get offlineSos => 'SOS call & SMS';

  @override
  String get offlineSosSub => 'Uses your mobile network';

  @override
  String get offlineNeedsInternet => 'Needs internet';

  @override
  String get offlineAiChat => 'AI chat';

  @override
  String get offlineGarageMap => 'Garage map';
}
