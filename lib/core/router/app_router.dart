import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/auth/state/auth_refresh_notifier.dart';
import '../../features/patient/presentation/patient_list_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/tasks/presentation/task_list_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../../features/profile/presentation/profile_screen.dart' as profile;
import '../../features/patient/presentation/patient_list_screen.dart'
    as patient;

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(); // ✅ moved inside
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  final auth = ref.watch(authControllerProvider);
  final refreshNotifier = ref.watch(authRefreshNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: refreshNotifier,
    initialLocation: '/tasks',
    redirect: (context, state) {
      final path = state.uri.path;
      final isLoggingIn = path == '/login';
      final isAuthenticated = auth is AsyncData && auth.value != null;

      if (!isAuthenticated && !isLoggingIn) return '/login';
      if (isAuthenticated && isLoggingIn) return '/tasks';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
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
