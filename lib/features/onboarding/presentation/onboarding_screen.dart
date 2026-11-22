import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../data/onboarding_seen.dart';
import '../domain/onboarding_page.dart';
import 'widgets/onboarding_picture_view.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _onLastPage() {
    return _currentPage == onboardingPages.length - 1;
  }

  Future<void> _done() async {
    await ref.read(onboardingSeenProvider.notifier).finish();
    if (!mounted) return;
    // guests get sent to login by the router
    context.go('/home');
  }

  void _onNextPressed() {
    if (_onLastPage()) {
      _done();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
          child: Column(
            children: [
              _buildSkip(),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: onboardingPages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(onboardingPages[index]);
                  },
                ),
              ),
              _buildDots(),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _onLastPage() ? 'Get started' : 'Next',
                  onPressed: _onNextPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkip() {
    // keeps its space on the last page so nothing jumps
    return Align(
      alignment: Alignment.centerRight,
      child: Opacity(
        opacity: _onLastPage() ? 0 : 1,
        child: TextButton(
          onPressed: _onLastPage() ? null : _done,
          child: const Text(
            'Skip',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            OnboardingPictureView(picture: page.picture),
            const SizedBox(height: 28),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              page.body,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.5, color: muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    final colors = Theme.of(context).colorScheme;
    final dots = <Widget>[];

    for (int i = 0; i < onboardingPages.length; i++) {
      final active = i == _currentPage;
      dots.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? colors.primary : colors.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: dots);
  }
}
