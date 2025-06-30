// test/features/auth/presentation/login_screen_test.dart
//
// Ensures the form calls signIn() with the typed credentials.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nurseos_v3/core/theme/theme_controller.dart';
import 'package:nurseos_v3/core/theme/app_theme.dart'; // ⬅️ theme with AppColors
import 'package:nurseos_v3/features/preferences/controllers/font_scale_controller.dart';
import 'package:nurseos_v3/features/preferences/controllers/locale_controller.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/auth/presentation/login_screen.dart';
import 'package:nurseos_v3/l10n/generated/app_localizations.dart';

import '../../../utils/test_fakes.dart';

void main() {
  testWidgets('LoginScreen allows sign in with email and password',
      (tester) async {
    final capturing = CapturingAuthController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fontScaleStreamProvider
              .overrideWith((_) => Stream<double>.value(1.0)),
          themeModeStreamProvider
              .overrideWith((_) => Stream<ThemeMode>.value(ThemeMode.light)),
          localeControllerProvider.overrideWith(FakeLocaleController.new),
          authControllerProvider.overrideWith(() => capturing),
        ],
        child: MaterialApp(
          // 👉 supply localisation + custom theme so null-bangs don't fire
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(), // contains AppColors extension
          home: const LoginScreen(),
        ),
      ),
    );

    // wait for the first frame (localisation load) to finish
    await tester.pumpAndSettle();

    final emailField = find.byKey(const Key('emailField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.byKey(const Key('loginButton'));

    await tester.enterText(emailField, 'nurse@example.com');
    await tester.enterText(passwordField, 'testpassword');
    await tester.pump();
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(capturing.emailCaptured, 'nurse@example.com');
    expect(capturing.passwordCaptured, 'testpassword');
  });
}
