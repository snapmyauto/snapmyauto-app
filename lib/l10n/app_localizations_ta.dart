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

  @override
  String get scanDetailTitle => 'ஸ்கேன் விவரங்கள்';

  @override
  String get scanDetailGone => 'இந்த ஸ்கேன் நீக்கப்பட்டது.';

  @override
  String get scanDetailLights => 'கண்டறிந்த விளக்குகள்';

  @override
  String scanDetailSure(int percent) {
    return '$percent% உறுதி';
  }

  @override
  String get scanDetailAdvice => 'ஆலோசனையைப் பார்';

  @override
  String get scanDetailAskAi => 'இதைப் பற்றி AI இடம் கேள்';

  @override
  String get scanDetailDeleteTitle => 'இந்த ஸ்கேனை நீக்கவா?';

  @override
  String get scanDetailDeleteBody => 'இதைச் செயல்தவிர்க்க முடியாது.';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get sourceCamera => 'கேமரா';

  @override
  String get sourceGallery => 'புகைப்படம்';

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String get settingsAppearance => 'தோற்றம்';

  @override
  String get settingsTheme => 'தீம்';

  @override
  String get themeLight => 'ஒளி';

  @override
  String get themeDark => 'இருள்';

  @override
  String get themeSystem => 'கணினி';

  @override
  String get settingsAccent => 'முதன்மை நிறம்';

  @override
  String get accentGreen => 'பச்சை';

  @override
  String get accentBlue => 'நீலம்';

  @override
  String get settingsGeneral => 'பொது';

  @override
  String get settingsLanguage => 'மொழி';

  @override
  String get languageSystem => 'தொலைபேசி மொழி';

  @override
  String get settingsUnits => 'தூர அலகுகள்';

  @override
  String get unitsKm => 'கிலோமீட்டர் (km)';

  @override
  String get unitsMiles => 'மைல்கள் (mi)';

  @override
  String get settingsNotifications => 'அறிவிப்புகள்';

  @override
  String get settingsReminderAlerts => 'நினைவூட்டல்கள்';

  @override
  String get settingsReminderAlertsSub => 'உரிமம், காப்பீடு, சர்வீஸ்';

  @override
  String get settingsAiButton => 'AI அரட்டை பொத்தான்';

  @override
  String get settingsAiButtonSub => 'AI இடம் கேட்க விரைவுப் பொத்தானைக் காட்டு';

  @override
  String get settingsAccount => 'கணக்கு மற்றும் கருவிகள்';

  @override
  String get settingsMyVehicles => 'எனது வாகனங்கள்';

  @override
  String get settingsEmergency => 'அவசரத் தொடர்புகள்';

  @override
  String get settingsAbout => 'SnapMyAuto பற்றி';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get logoutTitle => 'வெளியேறவா?';

  @override
  String get logoutBody => 'எப்போது வேண்டுமானாலும் மீண்டும் உள்நுழையலாம்.';

  @override
  String get offlineTitle => 'இப்போது இணையம் இல்லை';

  @override
  String get offlineBody =>
      'கவலை வேண்டாம், முக்கியமான பகுதிகள் இன்னும் வேலை செய்யும். மீண்டும் இணைந்ததும் தரவை ஒத்திசைப்போம்.';

  @override
  String get offlineStillWorks => 'இன்னும் வேலை செய்யும்';

  @override
  String get offlineScanSub => 'DashLight உங்கள் போனிலேயே இயங்கும்';

  @override
  String get offlineSos => 'SOS அழைப்பு & SMS';

  @override
  String get offlineSosSub => 'உங்கள் மொபைல் நெட்வொர்க்கைப் பயன்படுத்தும்';

  @override
  String get offlineNeedsInternet => 'இணையம் தேவை';

  @override
  String get offlineAiChat => 'AI உரையாடல்';

  @override
  String get offlineGarageMap => 'கேரேஜ் வரைபடம்';
}
