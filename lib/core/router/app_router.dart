import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/features/preferences/presentation/accessibility_settings_screen.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/auth/state/auth_refresh_notifier.dart';
import '../../features/patient/presentation/patient_list_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/tasks/presentation/task_list_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/screens/splash_screen.dart';
import '../../shared/state/suppress_redirect_provider.dart';
import '../../features/patient/presentation/screens/add_patient_screen.dart';
import '../../features/work_history/presentation/work_history_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  final auth = ref.watch(authControllerProvider);
  final refreshNotifier = ref.watch(authRefreshNotifierProvider);
  final suppressRedirect = ref.watch(suppressRedirectProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: refreshNotifier,
    initialLocation: '/tasks',
    redirect: (context, state) {
      final uri = state.uri;
      final path = uri.path;

      final isSplashing = path == '/splash';
      final isLoggingIn = path == '/login';

      final isAuthed = auth is AsyncData && auth.value != null;
      final isUnauthed = auth is AsyncData && auth.value == null;

      // 1. Respect explicit suppressRedirect flag
      if (suppressRedirect) return null;

      // 2. If auth is loading, show splash unless already on it
      if (auth.isLoading) {
        return isSplashing ? null : '/splash';
      }

      // 3. Unauthenticated users redirected to login (except splash)
      if (isUnauthed && !isLoggingIn && !isSplashing) {
        return '/login';
      }

      // 4. Post-auth redirection logic
      if (isAuthed) {
        if (isLoggingIn) {
          // Support return via `?from=...`
          return uri.queryParameters['from'] ?? '/tasks';
        }
        if (isSplashing) {
          return null; // allow splash to naturally forward
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        pageBuilder: (context, state) {
          final replace = state.uri.queryParameters['replace'] == 'true';

          return replace
              ? const NoTransitionPage(child: EditProfileScreen())
              : const MaterialPage(child: EditProfileScreen());
        },
      ),
      GoRoute(
        path: '/accessibility',
        builder: (_, __) => const AccessibilitySettingsScreen(),
      ),
      GoRoute(
        path: '/patients/add',
        builder: (_, __) => const AddPatientScreen(),
      ),
      GoRoute(
        path: '/work-history',
        builder: (_, __) => const WorkHistoryScreen(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/tasks',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: TaskListScreen()),
          ),
          GoRoute(
            path: '/patients',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: PatientListScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});
