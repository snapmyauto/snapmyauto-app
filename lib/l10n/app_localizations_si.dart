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

  @override
  String get historyTitle => 'ඉතිහාසය';

  @override
  String get historyAllVehicles => 'සියලු වාහන';

  @override
  String get historySearch => 'අනතුරු ඇඟවීම් සොයන්න';

  @override
  String get historyAll => 'සියල්ල';

  @override
  String get groupToday => 'අද';

  @override
  String get groupYesterday => 'ඊයේ';

  @override
  String get groupThisWeek => 'මේ සතිය';

  @override
  String get groupOlder => 'ඊට පෙර';

  @override
  String get historyEmptyTitle => 'තවම ස්කෑන් නැත';

  @override
  String get historyEmptyBody =>
      'අනතුරු ඇඟවීමේ ලාම්පුවක් ස්කෑන් කළ විට එය මෙහි පෙන්වයි.';

  @override
  String get historyNoMatch => 'ගැළපෙන ස්කෑන් නැත';

  @override
  String get historyNoMatchBody => 'වෙනත් සෙවුමක් හෝ පෙරහනක් උත්සාහ කරන්න.';

  @override
  String get historyClearFilters => 'පෙරහන් ඉවත් කරන්න';

  @override
  String get historyDeleted => 'ස්කෑන් එක මකා දැමුණි';

  @override
  String get historyUndo => 'ආපසු';

  @override
  String get historyDelete => 'මකන්න';

  @override
  String get historyNoCar => 'වාහනයක් නැත';

  @override
  String get scanDetailTitle => 'ස්කෑන් විස්තර';

  @override
  String get scanDetailGone => 'මෙම ස්කෑන් එක මකා දමා ඇත.';

  @override
  String get scanDetailLights => 'හමු වූ ලාම්පු';

  @override
  String scanDetailSure(int percent) {
    return '$percent% විශ්වාසයි';
  }

  @override
  String get scanDetailAdvice => 'උපදෙස් බලන්න';

  @override
  String get scanDetailAskAi => 'මේ ගැන AI ගෙන් අහන්න';

  @override
  String get scanDetailDeleteTitle => 'මෙම ස්කෑන් එක මකන්නද?';

  @override
  String get scanDetailDeleteBody => 'මෙය ආපසු හැරවිය නොහැක.';

  @override
  String get cancel => 'අවලංගු කරන්න';

  @override
  String get sourceCamera => 'කැමරාව';

  @override
  String get sourceGallery => 'ඡායාරූපය';

  @override
  String get settingsTitle => 'සැකසුම්';

  @override
  String get settingsAppearance => 'පෙනුම';

  @override
  String get settingsTheme => 'තේමාව';

  @override
  String get themeLight => 'ආලෝක';

  @override
  String get themeDark => 'අඳුරු';

  @override
  String get themeSystem => 'පද්ධතිය';

  @override
  String get settingsAccent => 'ප්‍රධාන වර්ණය';

  @override
  String get accentGreen => 'කොළ';

  @override
  String get accentBlue => 'නිල්';

  @override
  String get settingsGeneral => 'සාමාන්‍ය';

  @override
  String get settingsLanguage => 'භාෂාව';

  @override
  String get languageSystem => 'දුරකථන භාෂාව';

  @override
  String get settingsUnits => 'දුර ඒකක';

  @override
  String get unitsKm => 'කිලෝමීටර් (km)';

  @override
  String get unitsMiles => 'සැතපුම් (mi)';

  @override
  String get settingsNotifications => 'දැනුම්දීම්';

  @override
  String get settingsReminderAlerts => 'සිහිකැඳවීම්';

  @override
  String get settingsReminderAlertsSub => 'බලපත්‍රය, රක්ෂණය, සේවාව';

  @override
  String get settingsAiButton => 'AI කතාබස් බොත්තම';

  @override
  String get settingsAiButtonSub => 'AI ගෙන් ඇසීමට ඉක්මන් බොත්තමක් පෙන්වන්න';

  @override
  String get settingsAccount => 'ගිණුම සහ මෙවලම්';

  @override
  String get settingsMyVehicles => 'මගේ වාහන';

  @override
  String get settingsEmergency => 'හදිසි සම්බන්ධතා';

  @override
  String get settingsAbout => 'SnapMyAuto ගැන';

  @override
  String get logout => 'ඉවත් වන්න';

  @override
  String get logoutTitle => 'ඉවත් වෙනවාද?';

  @override
  String get logoutBody => 'ඔබට ඕනෑම වේලාවක නැවත ඇතුළු විය හැක.';

  @override
  String get offlineTitle => 'දැන් අන්තර්ජාලය නැත';

  @override
  String get offlineBody =>
      'කනගාටු නොවන්න, වැදගත් කොටස් තවමත් ක්‍රියා කරයි. ඔබ නැවත සම්බන්ධ වූ විට අපි දත්ත යාවත්කාලීන කරන්නෙමු.';

  @override
  String get offlineStillWorks => 'තවමත් ක්‍රියා කරයි';

  @override
  String get offlineScanSub => 'DashLight ඔබේ දුරකථනයේම ක්‍රියා කරයි';

  @override
  String get offlineSos => 'SOS ඇමතුම සහ SMS';

  @override
  String get offlineSosSub => 'ඔබේ ජංගම ජාලය භාවිත කරයි';

  @override
  String get offlineNeedsInternet => 'අන්තර්ජාලය අවශ්‍යයි';

  @override
  String get offlineAiChat => 'AI කතාබහ';

  @override
  String get offlineGarageMap => 'ගරාජ සිතියම';

  @override
  String get settingsReadAloud => 'ප්‍රතිඵල හඬින් කියවන්න';

  @override
  String get settingsReadAloudSub => 'ප්‍රතිඵලය විවෘත වූ විගස කියවයි';

  @override
  String get homeGetStarted => 'ආරම්භ කරන්න';

  @override
  String homeStepsDone(int done, int total) {
    return '$done/$total සම්පූර්ණයි';
  }

  @override
  String get homeStepAccount => 'ගිණුමක් සාදන්න';

  @override
  String get homeStepCar => 'ඔබේ වාහනය එක් කරන්න';

  @override
  String get homeStepSos => 'SOS සම්බන්ධතා සකසන්න';

  @override
  String get homeStepScan => 'පළමු ස්කෑන් එක කරන්න';
}
