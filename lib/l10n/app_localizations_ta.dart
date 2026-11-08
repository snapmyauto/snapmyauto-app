// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navHistory => 'வரலாறு';

  @override
  String get navGarages => 'கேரேஜ்கள்';

  @override
  String get navMore => 'மேலும்';

  @override
  String get navScan => 'எச்சரிக்கை விளக்கை ஸ்கேன் செய்';

  @override
  String get homeGreetingMorning => 'காலை வணக்கம்,';

  @override
  String get homeGreetingAfternoon => 'மதிய வணக்கம்,';

  @override
  String get homeGreetingEvening => 'மாலை வணக்கம்,';

  @override
  String get homeNameFallback => 'ஓட்டுநர்';

  @override
  String get homeProfile => 'சுயவிவரம்';

  @override
  String get homeAddCarTitle => 'உங்கள் முதல் வாகனத்தைச் சேர்க்கவும்';

  @override
  String get homeAddCarBody =>
      'முடிவுகள், நினைவூட்டல்கள் மற்றும் AI உங்கள் வாகனத்துக்குப் பொருந்தும்படி.';

  @override
  String get homeAddCarButton => 'வாகனத்தைச் சேர்';

  @override
  String get homeChangeCar => 'வாகனத்தை மாற்று';

  @override
  String get homeOdometer => 'ஓடோமீட்டர்';

  @override
  String get homeNoMileage => 'சேர்க்கப்படவில்லை';

  @override
  String get homeNextService => 'அடுத்த சர்வீஸ்';

  @override
  String get homeLicence => 'உரிமம்';

  @override
  String get homeInsurance => 'காப்பீடு';

  @override
  String get homeNotSet => 'அமைக்கவில்லை';

  @override
  String get dueOverdue => 'தாமதம்';

  @override
  String get dueToday => 'இன்று';

  @override
  String get dueTomorrow => 'நாளை';

  @override
  String dueInDays(int count) {
    return '$count நாட்கள்';
  }

  @override
  String get agoToday => 'இன்று';

  @override
  String get agoYesterday => 'நேற்று';

  @override
  String agoDays(int count) {
    return '$count நாட்களுக்கு முன்';
  }

  @override
  String homeWarningScanned(String when) {
    return 'ஸ்கேன் செய்தது $when';
  }

  @override
  String get homeView => 'பார்';

  @override
  String get homeFeelsWrong => 'ஏதாவது சரியில்லை போலத் தோன்றுகிறதா?';

  @override
  String get homeQuickActions => 'விரைவுச் செயல்கள்';

  @override
  String get homeIconLibrary => 'சின்ன நூலகம்';

  @override
  String get homeReminders => 'நினைவூட்டல்கள்';

  @override
  String get homeSos => 'SOS';

  @override
  String get homeComingUp => 'வரவிருப்பவை';

  @override
  String get homeSeeAll => 'அனைத்தையும் பார்';

  @override
  String get homeNoReminders => 'இன்னும் நினைவூட்டல்கள் இல்லை';

  @override
  String get homeAddReminder => 'நினைவூட்டலைச் சேர்';

  @override
  String get homeRecentScans => 'சமீபத்திய ஸ்கேன்கள்';

  @override
  String get homeNoScans => 'இன்னும் ஸ்கேன்கள் இல்லை';

  @override
  String get homeNoScansBody => 'ஸ்கேன் செய்த விளக்குகள் இங்கே தோன்றும்.';

  @override
  String homeMoreLights(int count) {
    return '+$count மேலும்';
  }

  @override
  String get historyTitle => 'வரலாறு';

  @override
  String get historyAllVehicles => 'அனைத்து வாகனங்கள்';

  @override
  String get historySearch => 'எச்சரிக்கைகளைத் தேடு';

  @override
  String get historyAll => 'அனைத்தும்';

  @override
  String get groupToday => 'இன்று';

  @override
  String get groupYesterday => 'நேற்று';

  @override
  String get groupThisWeek => 'இந்த வாரம்';

  @override
  String get groupOlder => 'முன்பு';

  @override
  String get historyEmptyTitle => 'இன்னும் ஸ்கேன்கள் இல்லை';

  @override
  String get historyEmptyBody =>
      'எச்சரிக்கை விளக்கை ஸ்கேன் செய்தால் அது இங்கே தோன்றும்.';

  @override
  String get historyNoMatch => 'பொருந்தும் ஸ்கேன்கள் இல்லை';

  @override
  String get historyNoMatchBody =>
      'வேறு தேடல் அல்லது வடிகட்டியை முயற்சிக்கவும்.';

  @override
  String get historyClearFilters => 'வடிகட்டிகளை அழி';

  @override
  String get historyDeleted => 'ஸ்கேன் நீக்கப்பட்டது';

  @override
  String get historyUndo => 'செயல்தவிர்';

  @override
  String get historyDelete => 'நீக்கு';

  @override
  String get historyNoCar => 'வாகனம் இல்லை';
}
