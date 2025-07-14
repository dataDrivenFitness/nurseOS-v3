// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/core/providers/feature_flag_provider.dart';
import 'package:nurseos_v3/features/preferences/presentation/accessibility_settings_screen.dart';
import 'package:nurseos_v3/features/schedule/presentation/schedule_screen.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/my_shift_screen.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/available_shifts_screen.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/auth/state/auth_refresh_notifier.dart';
import '../../features/patient/presentation/patient_list_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/tasks/presentation/task_list_screen.dart';
import '../../features/admin/presentation/admin_portal_screen.dart';
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

  // Check if new navigation is enabled to set appropriate initial location
  final useNewNavigation = ref.watch(featureFlagProvider('navigation_v3'));
  final initialLocation = useNewNavigation ? '/available-shifts' : '/tasks';

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: refreshNotifier,
    initialLocation: initialLocation,
    redirect: (context, state) {
      final uri = state.uri;
      final path = uri.path;

      final isSplashing = path == '/splash';
      final isLoggingIn = path == '/login';

      final isAuthed = auth is AsyncData && auth.value != null;
      final isUnauthed = auth is AsyncData && auth.value == null;

      if (suppressRedirect) return null;

      if (auth.isLoading) {
        return isSplashing ? null : '/splash';
      }

      if (isUnauthed && !isLoggingIn && !isSplashing) {
        return '/login';
      }

      if (isAuthed) {
        if (isLoggingIn) {
          return uri.queryParameters['from'] ?? initialLocation;
        }
        if (isSplashing) return null;
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
            path: '/schedule',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: ScheduleScreen()),
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
          GoRoute(
            path: '/admin',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: AdminPortalScreen()),
          ),
          // 🆕 New Navigation V3 Routes
          GoRoute(
            path: '/my-shift',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: MyShiftScreen()),
          ),
          GoRoute(
            path: '/available-shifts',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: AvailableShiftsScreen()),
          ),
        ],
      ),
    ],
  );
});
