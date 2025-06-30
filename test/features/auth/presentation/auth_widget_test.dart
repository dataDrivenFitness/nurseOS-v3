// test/features/auth/presentation/auth_widget_test.dart
//
// Ensures a pre-authenticated user bypasses BootSplash and never sees Login.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nurseos_v3/app.dart';
import 'package:nurseos_v3/core/theme/theme_controller.dart';
import 'package:nurseos_v3/features/preferences/controllers/font_scale_controller.dart';
import 'package:nurseos_v3/features/preferences/controllers/locale_controller.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/shared/screens/splash_screen.dart';
import 'package:nurseos_v3/features/auth/presentation/login_screen.dart';

import '../../../utils/test_fakes.dart';

void main() {
  testWidgets(
    '🧪 AuthWidget skips splash & login when user is already authenticated',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Boot providers resolve instantly
            fontScaleStreamProvider
                .overrideWith((_) => Stream<double>.value(1.0)),
            themeModeStreamProvider
                .overrideWith((_) => Stream<ThemeMode>.value(ThemeMode.light)),
            localeControllerProvider.overrideWith(FakeLocaleController.new),

            // Fake user is logged in
            authControllerProvider
                .overrideWith(() => FakeAuthController(fakeUser)),
          ],
          child: const NurseOSApp(),
        ),
      );

      // 1️⃣ First frame = BootSplash
      await tester.pump();

      // 2️⃣ Let router & streams finish
      await tester.pumpAndSettle();

      // 3️⃣ Sanity: BootSplash unmounted & LoginScreen never shown
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
    },
  );
}
