import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/utils/l10n.dart';
import '../../../core/widgets/app_button.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../data/home_providers.dart';
import 'widgets/coming_up.dart';
import 'widgets/home_header.dart';
import 'widgets/offline_help.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_scans.dart';
import 'widgets/vehicle_hero.dart';
import 'widgets/warning_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final vehiclesLoading = ref.watch(vehiclesProvider).isLoading;
    final vehicle = ref.watch(homeVehicleProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          // room at the bottom for the glass bar and the ai button
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 170),
          children: [
            const HomeHeader(),
            const SizedBox(height: 18),
            const OfflineHelp(),
            if (vehiclesLoading)
              const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (vehicle == null)
              const AddCarCard()
            else
              VehicleHero(vehicle: vehicle),
            const WarningBanner(),
            const SizedBox(height: 18),
            PrimaryButton(
              label: l10n.navScan,
              icon: LucideIcons.scanLine,
              onPressed: () => context.push('/scan'),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: l10n.homeFeelsWrong,
              icon: LucideIcons.stethoscope,
              onPressed: () => context.push('/symptoms'),
            ),
            const SizedBox(height: 22),
            const QuickActions(),
            const SizedBox(height: 22),
            const ComingUp(),
            const SizedBox(height: 12),
            const RecentScans(),
          ],
        ),
      ),
    );
  }
}
