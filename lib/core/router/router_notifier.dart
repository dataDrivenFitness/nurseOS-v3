import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';

part 'router_notifier.g.dart';

@Riverpod(keepAlive: true)
class RouterNotifier extends AsyncNotifier<List<RouteBase>> {
  @override
  Future<List<RouteBase>> build() async {
    // use ref.watch() safely here
    final user = await ref.watch(authControllerProvider.future);

    return [
      GoRoute(
        path: '/login',
        builder: (_, __) => const Placeholder(key: Key('login-screen')),
      ),
      ShellRoute(
        builder: (_, __, child) =>
            Scaffold(key: const ValueKey('app-shell'), body: child),
        routes: [
          GoRoute(
            path: '/patients',
            builder: (_, __) =>
                const Placeholder(key: Key('assignedPatientsTitle')),
          ),
        ],
      ),
    ];
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final user = ref.read(authControllerProvider).valueOrNull;
    final loggingIn = state.uri.path == '/login';
    if (user == null) return loggingIn ? null : '/login';
    return loggingIn ? '/patients' : null;
  }
}
