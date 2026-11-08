import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_providers.dart';
import '../../../../core/utils/l10n.dart';
import '../../../profile/data/user_repository.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.l10n.homeGreetingMorning;
    if (hour < 17) return context.l10n.homeGreetingAfternoon;
    return context.l10n.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final accent = ref.watch(accentProvider);
    final profile = ref.watch(userProfileProvider).value;
    final name = profile?.name.trim() ?? '';
    final firstName = name.isEmpty
        ? context.l10n.homeNameFallback
        : name.split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/images/logo-${accent.name}.svg',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'SnapMyAuto',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            Tooltip(
              message: context.l10n.homeProfile,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.push('/profile'),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  foregroundImage: profile?.photoUrl != null
                      ? NetworkImage(profile!.photoUrl!)
                      : null,
                  child: Text(
                    profile?.initials ?? '?',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          _greeting(context),
          style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
        ),
        Text(
          firstName,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
