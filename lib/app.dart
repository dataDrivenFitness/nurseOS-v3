// 📁 lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_controller.dart';
import 'features/preferences/controllers/font_scale_controller.dart';
import 'features/preferences/controllers/locale_controller.dart';
import 'features/auth/state/auth_controller.dart';
import 'l10n/generated/app_localizations.dart';

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
      loading: () => const _SplashScreen(),
      error: (e, _) => _errorApp('Font scale load failed: $e'),
      data: (fontScale) {
        return themeAsync.when(
          loading: () => const _SplashScreen(),
          error: (e, _) => _errorApp('Theme load failed: $e'),
          data: (themeMode) {
            return localeAsync.when(
              loading: () => const _SplashScreen(),
              error: (e, _) => _errorApp('Locale load failed: $e'),
              data: (resolvedLocale) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(fontScale),
                  ),
                  child: MaterialApp.router(
                    title: 'NurseOS v3',
                    locale: resolvedLocale, // ✅ now updates pre-login
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

  MaterialApp _errorApp(String msg) =>
      MaterialApp(home: Scaffold(body: Center(child: Text(msg))));
}

/* ─── Top-level splash (fixed) ───────────────────────────── */
class _SplashScreen extends StatelessWidget {
  const _SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
}
