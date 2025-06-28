// 📁 lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_controller.dart'; // ✅ still used
import 'features/preferences/controllers/font_scale_controller.dart';
import 'features/preferences/controllers/locale_controller.dart';
import 'l10n/generated/app_localizations.dart';

class NurseOSApp extends ConsumerWidget {
  const NurseOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final fontScaleAsync = ref.watch(fontScaleStreamProvider);
    final themeStreamAsync = ref.watch(themeModeStreamProvider); // ✅ replaced
    final localeAsync = ref.watch(localeStreamProvider);

    return fontScaleAsync.when(
      loading: () => const _SplashScreen(),
      error: (err, _) => _errorApp('Font scale load failed: $err'),
      data: (fontScale) {
        return themeStreamAsync.when(
          loading: () => const _SplashScreen(),
          error: (err, _) => _errorApp('Theme load failed: $err'),
          data: (themeMode) {
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

  MaterialApp _errorApp(String message) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text(message))),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
