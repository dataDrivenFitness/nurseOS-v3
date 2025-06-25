// lib/bootstrap.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_theme.dart';
import 'package:nurseos_v3/core/theme/theme_controller.dart';
import 'package:nurseos_v3/core/router/app_router.dart'; // ← use this

class NurseOSApp extends ConsumerWidget {
  const NurseOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider); // ← now using app_router
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
