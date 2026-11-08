import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snapmyauto/core/router/app_router.dart';
import 'package:snapmyauto/core/utils/shared_prefs.dart';
import 'package:snapmyauto/main.dart';

void main() {
  testWidgets('app opens', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // firebase is not set up in tests, so use a router without the auth check
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Text('home')),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          routerProvider.overrideWithValue(router),
        ],
        child: const SnapMyAutoApp(),
      ),
    );

    expect(find.text('home'), findsOneWidget);
  });
}
