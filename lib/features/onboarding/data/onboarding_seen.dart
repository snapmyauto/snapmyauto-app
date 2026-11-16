import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/shared_prefs.dart';

const String kOnboardingSeenKey = 'onboarding_seen';

// true once the user finished or skipped the intro
class OnboardingSeen extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.read(sharedPrefsProvider);
    return prefs.getBool(kOnboardingSeenKey) ?? false;
  }

  Future<void> finish() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool(kOnboardingSeenKey, true);
    state = true;
  }
}

final onboardingSeenProvider = NotifierProvider<OnboardingSeen, bool>(
  OnboardingSeen.new,
);
