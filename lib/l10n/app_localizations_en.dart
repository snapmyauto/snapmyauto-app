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
}
