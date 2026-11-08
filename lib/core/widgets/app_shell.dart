import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/connectivity.dart';
import 'glass_nav_bar.dart';
import 'offline_banner.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(isOfflineProvider).value ?? false;

    return Scaffold(
      // lets screen content scroll behind the glass bar
      extendBody: true,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            // the banner already covers the status bar, so screens skip it
            child: MediaQuery.removePadding(
              context: context,
              removeTop: offline,
              child: shell,
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: shell.currentIndex,
        onTap: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        onScan: () => context.push('/scan'),
      ),
    );
  }
}
