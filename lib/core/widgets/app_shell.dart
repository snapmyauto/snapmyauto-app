import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'glass_nav_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // lets screen content scroll behind the glass bar
      extendBody: true,
      body: shell,
      bottomNavigationBar: GlassNavBar(
        currentIndex: shell.currentIndex,
        onTap: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        onScan: () => context.push('/scan'),
      ),
    );
  }
}
