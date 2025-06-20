//import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_shell.dart';
import '../../features/patient/screens/patient_list_screen.dart';
import '../../features/tasks/screens/task_list_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

final appRoutes = [
  ShellRoute(
    builder: (context, state, child) => AppShell(child: child),
    routes: [
      _redirectRootToPatients(),
      _patientsRoute(),
      _tasksRoute(),
      _profileRoute(),
    ],
  ),
];

GoRoute _redirectRootToPatients() => GoRoute(
      path: '/',
      redirect: (_, __) => '/patients',
    );

GoRoute _patientsRoute() => GoRoute(
      path: '/patients',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: PatientListScreen(),
      ),
    );

GoRoute _tasksRoute() => GoRoute(
      path: '/tasks',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: TaskListScreen(),
      ),
    );

GoRoute _profileRoute() => GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ProfileScreen(),
      ),
    );
