// 📁 lib/app.dart
//
//  V2 refactor highlights
//  • Uses custom SplashScreen instead of BootSplash for dark mode sensitivity
//  • SplashScreen now respects app theme settings, not just system settings
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/preferences/controllers/font_scale_controller.dart';
import 'features/preferences/controllers/locale_controller.dart';
import 'features/auth/state/auth_controller.dart';
import 'l10n/generated/app_localizations.dart';
import 'shared/screens/splash_screen.dart'; // 🆕 Use your custom splash screen
import 'core/theme/theme_controller.dart';

class NurseOSApp extends ConsumerWidget {
  const NurseOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /* ─── Core async values ─────────────────────────────── */
    final router = ref.watch(appRouterProvider);
    final fontScaleAsync = ref.watch(fontScaleStreamProvider);
    final themeAsync = ref.watch(themeModeStreamProvider);
    final authAsync = ref.watch(authControllerProvider);

    /* ─── Locale: cache if guest, stream if authed ──────── */
    final localeAsync = authAsync.maybeWhen(
      data: (user) => user == null
          ? ref.watch(localeControllerProvider)
          : ref.watch(localeStreamProvider),
      orElse: () => ref.watch(localeControllerProvider),
    );

    /* ─── Layered Async loading chain ───────────────────── */
    return fontScaleAsync.when(
      loading: () => const SplashScreen(), // 🆕 dark-aware custom splash
      error: (e, _) => _errorApp('Font scale load failed: $e'),
      data: (fontScale) {
        return themeAsync.when(
          loading: () => const SplashScreen(), // 🆕
          error: (e, _) => _errorApp('Theme load failed: $e'),
          data: (themeMode) {
            return localeAsync.when(
              loading: () => const SplashScreen(), // 🆕
              error: (e, _) => _errorApp('Locale load failed: $e'),
              data: (resolvedLocale) {
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
      },
    );
  }

  /// Fallback mini-app shown when an async chain fails hard.
  MaterialApp _errorApp(String msg) =>
      MaterialApp(home: Scaffold(body: Center(child: Text(msg))));
}
