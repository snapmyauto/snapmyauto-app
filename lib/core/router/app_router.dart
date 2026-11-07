import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snapmyauto/features/auth/presentation/forgot_password_screen.dart';
import 'package:snapmyauto/features/auth/presentation/login_screen.dart';
import 'package:snapmyauto/features/auth/presentation/register_screen.dart';

import '../../features/icon_library/presentation/icon_library_screen.dart';
import '../../features/icon_library/presentation/light_detail_screen.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/scan/presentation/scan_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/vehicles/presentation/vehicle_detail_screen.dart';
import '../../features/vehicles/presentation/vehicle_form_screen.dart';
import '../../features/vehicles/presentation/vehicles_screen.dart';
import '../widgets/app_shell.dart';
import '../widgets/placeholder_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // router re-checks redirect whenever this value changes
  final user = ValueNotifier<User?>(
    ref.read(authRepositoryProvider).currentUser,
  );
  ref.listen(authStateProvider, (_, next) => user.value = next.value);
  ref.onDispose(user.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    refreshListenable: user,
    redirect: (context, state) {
      final loggedIn = user.value != null;
      final onAuthPage = state.matchedLocation.startsWith('/auth');
      if (!loggedIn && !onAuthPage) return '/auth/login';
      if (loggedIn && onAuthPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/library',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const IconLibraryScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                LightDetailScreen(lightId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/vehicles',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const VehiclesScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const VehicleFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                VehicleDetailScreen(vehicleId: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    VehicleFormScreen(vehicleId: state.pathParameters['id']),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Home'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'History'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/garages',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Garages'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/scan',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ScanScreen(),
      ),
    ],
  );
});
