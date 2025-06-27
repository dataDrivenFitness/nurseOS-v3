// 📁 lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nurseos_v3/core/theme/app_theme.dart';
import 'package:nurseos_v3/core/router/app_router.dart';
import 'package:nurseos_v3/core/theme/theme_controller.dart';
import 'package:nurseos_v3/features/preferences/controllers/font_scale_controller.dart';
import 'package:nurseos_v3/l10n/generated/app_localizations.dart';

/// Root widget for NurseOS — sets up theming, routing, and platform behavior.
class NurseOSApp extends ConsumerWidget {
  const NurseOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final fontScaleAsync = ref.watch(fontScaleControllerProvider);
    final themeAsync = ref.watch(themeControllerProvider);

    return fontScaleAsync.when(
      loading: () => const SplashScreen(),
      error: (err, _) => _errorApp('Font scale load failed: $err'),
      data: (fontScale) {
        return themeAsync.when(
          loading: () => const SplashScreen(),
          error: (err, _) => _errorApp('Theme load failed: $err'),
          data: (themeMode) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(fontScale),
            ),
            child: MaterialApp.router(
              title: 'NurseOS v3',
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        );
      },
    );
  }

  /// Simple MaterialApp for errors
  MaterialApp _errorApp(String message) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text(message))),
    );
  }
}

/// Temporary splash shown while bootstrapping app preferences.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
