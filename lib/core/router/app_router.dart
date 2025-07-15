// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/core/providers/feature_flag_provider.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/records_screen.dart';
import 'package:nurseos_v3/features/preferences/presentation/accessibility_settings_screen.dart';
import 'package:nurseos_v3/features/schedule/presentation/schedule_screen.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/my_shift_screen.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/available_shifts_screen.dart';
// TODO: Import RecordsScreen when created
// import 'package:nurseos_v3/features/navigation_v3/presentation/records_screen.dart';

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

// Temporary placeholder for Records screen until it's created
class _PlaceholderRecordsScreen extends StatelessWidget {
  const _PlaceholderRecordsScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Records Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Work history and analytics coming soon...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  final auth = ref.watch(authControllerProvider);
  final refreshNotifier = ref.watch(authRefreshNotifierProvider);
  final suppressRedirect = ref.watch(suppressRedirectProvider);

  // Check if new navigation is enabled to set appropriate initial location
  final useNewNavigation = ref.watch(featureFlagProvider('navigation_v3'));
  final initialLocation = useNewNavigation ? '/shifts' : '/tasks';

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
          // ═══════════════════════════════════════════════════════════════
          // Legacy Navigation Routes (navigation_v3 = false)
          // ═══════════════════════════════════════════════════════════════
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

          // ═══════════════════════════════════════════════════════════════
          // Context-First Navigation V3 Routes (navigation_v3 = true)
          // ═══════════════════════════════════════════════════════════════

          // Shifts Tab - All shift management (browse, request, schedule, history)
          GoRoute(
            path: '/shifts',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: AvailableShiftsScreen()),
          ),

          // Current Tab - Active work session (patient care focus)
          GoRoute(
            path: '/current',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: MyShiftScreen()),
          ),

          // Records Tab - Work history, analytics, hours tracking
          GoRoute(
            path: '/records',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: RecordsScreen()),
            // TODO: Replace with actual RecordsScreen when created
            // const NoTransitionPage(child: RecordsScreen()),
          ),

          // ═══════════════════════════════════════════════════════════════
          // Legacy V3 Routes (for backward compatibility)
          // ═══════════════════════════════════════════════════════════════
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
