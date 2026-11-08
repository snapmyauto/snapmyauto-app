// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get navHome => 'මුල් පිටුව';

  @override
  String get navHistory => 'ඉතිහාසය';

  @override
  String get navGarages => 'ගරාජ';

  @override
  String get navMore => 'තවත්';

  @override
  String get navScan => 'අනතුරු ඇඟවීමේ ලාම්පුවක් ස්කෑන් කරන්න';

  @override
  String get homeGreetingMorning => 'සුබ උදෑසනක්,';

  @override
  String get homeGreetingAfternoon => 'සුබ දහවලක්,';

  @override
  String get homeGreetingEvening => 'සුබ සන්ධ්‍යාවක්,';

  @override
  String get homeNameFallback => 'රියදුරු';

  @override
  String get homeProfile => 'පැතිකඩ';

  @override
  String get homeAddCarTitle => 'ඔබේ පළමු වාහනය එක් කරන්න';

  @override
  String get homeAddCarBody =>
      'ප්‍රතිඵල, සිහිකැඳවීම් සහ AI ඔබේ වාහනයට ගැළපෙන ලෙස.';

  @override
  String get homeAddCarButton => 'වාහනයක් එක් කරන්න';

  @override
  String get homeChangeCar => 'වාහනය මාරු කරන්න';

  @override
  String get homeOdometer => 'ධාවන දුර';

  @override
  String get homeNoMileage => 'එක් කර නැත';

  @override
  String get homeNextService => 'ඊළඟ සේවාව';

  @override
  String get homeLicence => 'බලපත්‍රය';

  @override
  String get homeInsurance => 'රක්ෂණය';

  @override
  String get homeNotSet => 'සකසා නැත';

  @override
  String get dueOverdue => 'කල් ඉකුත්';

  @override
  String get dueToday => 'අද';

  @override
  String get dueTomorrow => 'හෙට';

  @override
  String dueInDays(int count) {
    return 'දින $count';
  }

  @override
  String get agoToday => 'අද';

  @override
  String get agoYesterday => 'ඊයේ';

  @override
  String agoDays(int count) {
    return 'දින $countකට පෙර';
  }

  @override
  String homeWarningScanned(String when) {
    return 'ස්කෑන් කළේ $when';
  }

  @override
  String get homeView => 'බලන්න';

  @override
  String get homeFeelsWrong => 'යමක් වැරදි බව දැනෙනවාද?';

  @override
  String get homeQuickActions => 'ඉක්මන් ක්‍රියා';

  @override
  String get homeIconLibrary => 'සංකේත පුස්තකාලය';

  @override
  String get homeReminders => 'සිහිකැඳවීම්';

  @override
  String get homeSos => 'SOS';

  @override
  String get homeComingUp => 'ඉදිරියට ඇති';

  @override
  String get homeSeeAll => 'සියල්ල බලන්න';

  @override
  String get homeNoReminders => 'තවම සිහිකැඳවීම් නැත';

  @override
  String get homeAddReminder => 'සිහිකැඳවීමක් එක් කරන්න';

  @override
  String get homeRecentScans => 'මෑත ස්කෑන්';

  @override
  String get homeNoScans => 'තවම ස්කෑන් නැත';

  @override
  String get homeNoScansBody => 'ස්කෑන් කළ ලාම්පු මෙහි පෙන්වයි.';

  @override
  String homeMoreLights(int count) {
    return '+$count තවත්';
  }
}
