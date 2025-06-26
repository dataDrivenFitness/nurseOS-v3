import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/auth/state/auth_refresh_notifier.dart';
import '../../features/patient/presentation/patient_list_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/tasks/presentation/task_list_screen.dart';
import '../../shared/screens/splash_screen.dart';
import '../../shared/widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  final auth = ref.watch(authControllerProvider);
  final refreshNotifier = ref.watch(authRefreshNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: refreshNotifier,
    initialLocation: '/tasks',
    redirect: (context, state) {
      final path = state.uri.path;

      final isSplashing = path == '/splash';
      final isLoggingIn = path == '/login';

      final isAuthed = auth is AsyncData && auth.value != null;
      final isUnauthed = auth is AsyncData && auth.value == null;

      // 1. Show splash if auth is loading
      if (auth.isLoading) {
        return isSplashing ? null : '/splash';
      }

      // 2. Unauthenticated users must login
      if (isUnauthed && !isLoggingIn && !isSplashing) {
        return '/login';
      }

      // 3. No automatic redirection after login or splash
      if (isAuthed && (isLoggingIn || isSplashing)) {
        return null; // ✅ Explicit navigation only
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
        builder: (_, __) => const EditProfileScreen(),
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
