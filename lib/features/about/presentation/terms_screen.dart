import 'package:flutter/material.dart';

const _terms = [
  (
    'Use of the app',
    'You can use SnapMyAuto for free to learn what a dashboard warning '
        'light means and what to do next.',
  ),
  (
    'Not a mechanic',
    'Results come from an AI model and general advice. They can be wrong. '
        'Always check with a qualified mechanic, and stop safely if a red '
        'light comes on.',
  ),
  (
    'Emergency features',
    'SOS and crash detection open your phone and SMS apps. They do not '
        'contact emergency services for you, and crash detection only works '
        'while the app is open.',
  ),
  (
    'Your account',
    'Keep your password safe. You can delete your data at any time by '
        'removing your vehicles, scans, reminders and contacts.',
  ),
];

const _privacy = [
  (
    'Photos',
    'Dashboard photos are checked on your phone by the DashLight model and '
        'are never uploaded.',
  ),
  (
    'What we save',
    'Your name, email, vehicles, scan results, reminders and emergency '
        'contacts are saved in your own account in Firebase. Only you can '
        'read them.',
  ),
  (
    'Location',
    'Your location is used only to find nearby garages and to add a map '
        'link to an SOS message. It is not saved.',
  ),
  (
    'AI chat',
    'Questions you ask the AI are sent to Google Gemini to get an answer.',
  ),
];

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms and privacy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const _Heading('Terms of use'),
          for (final (title, text) in _terms) _Section(title, text),
          const SizedBox(height: 16),
          const _Heading('Privacy policy'),
          for (final (title, text) in _privacy) _Section(title, text),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.text);

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
