enum OnboardingPicture { scan, severity, help }

class OnboardingPage {
  final String title;
  final String body;
  final OnboardingPicture picture;

  const OnboardingPage({
    required this.title,
    required this.body,
    required this.picture,
  });
}

const List<OnboardingPage> onboardingPages = [
  OnboardingPage(
    title: 'Snap a warning light,\nknow what it means',
    body: 'Point your camera at the dashboard. DashLight finds each light, even offline.',
    picture: OnboardingPicture.scan,
  ),
  OnboardingPage(
    title: 'Know if it is safe\nto keep driving',
    body: 'Every result tells you how serious it is and what to do right now.',
    picture: OnboardingPicture.severity,
  ),
  OnboardingPage(
    title: 'Help when you\nneed it',
    body: 'Find a garage nearby, call your emergency contacts or ask the AI.',
    picture: OnboardingPicture.help,
  ),
];
