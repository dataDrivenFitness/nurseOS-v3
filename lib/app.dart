// 📁 lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_controller.dart';
import 'features/preferences/controllers/font_scale_controller.dart';
import 'features/preferences/controllers/locale_controller.dart';
import 'l10n/generated/app_localizations.dart';

/// NurseOSApp is the root widget for the entire app.
/// It applies reactive font scaling, theming, and localization
/// using Riverpod's state management.
class NurseOSApp extends ConsumerWidget {
  const NurseOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ──────────────────────────────────────────────────────────────
    // STEP 1: Observe all core settings reactively
    // ──────────────────────────────────────────────────────────────
    final router = ref.watch(appRouterProvider);
    final fontScaleAsync = ref.watch(fontScaleControllerProvider);
    final themeAsync = ref.watch(themeControllerProvider);
    final localeAsync = ref.watch(localeControllerProvider);

    // ──────────────────────────────────────────────────────────────
    // STEP 2: Await font scale first — required for MediaQuery setup
    // ──────────────────────────────────────────────────────────────
    return fontScaleAsync.when(
      loading: () => const SplashScreen(),
      error: (err, _) => _errorApp('Font scale load failed: $err'),
      data: (fontScale) {
        // ──────────────────────────────────────────────────────────
        // STEP 3: Await theme setup before rendering the full app
        // ──────────────────────────────────────────────────────────
        return themeAsync.when(
          loading: () => const SplashScreen(),
          error: (err, _) => _errorApp('Theme load failed: $err'),
          data: (themeMode) {
            // ──────────────────────────────────────────────────────
            // STEP 4: Wait for locale (reactive) and build app shell
            // ──────────────────────────────────────────────────────
            final resolvedLocale =
                localeAsync.valueOrNull ?? const Locale('en');

            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(fontScale),
              ),
              child: MaterialApp.router(
                title: 'NurseOS v3',
                locale: resolvedLocale,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: themeMode,
                routerConfig: router,

                // ──────────────── Localization Setup ────────────────
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
              ),
            );
          },
        );
      },
    );
  }

  /// Fallback widget when initialization fails
  MaterialApp _errorApp(String message) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text(message))),
    );
  }
}

/// Simple loading screen during font/theme/locale setup
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
