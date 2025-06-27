import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_theme.dart';
import 'package:nurseos_v3/core/router/app_router.dart';
import 'package:nurseos_v3/core/theme/theme_controller.dart';
import 'package:nurseos_v3/features/preferences/controllers/font_scale_controller.dart';

/// Root widget for NurseOS — sets up theming, routing, and platform behavior.
class NurseOSApp extends ConsumerWidget {
  const NurseOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final fontScale = ref.watch(fontScaleControllerProvider);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(fontScale),
      ),
      child: MaterialApp.router(
        title: 'NurseOS v3',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}
