import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/profile/presentation/profile_screen.dart';

/// A mock AuthController returning a predefined user
class MockAuthController extends AuthController {
  final UserModel mockUser;

  MockAuthController(this.mockUser);

  @override
  Future<UserModel?> build() async => mockUser;
}

void main() {
  final mockUser = UserModel(
    uid: 'nurse001',
    firstName: 'Sam',
    lastName: 'Rivera',
    email: 'sam@nurseos.com',
    xp: 1200,
    level: 5,
    role: UserRole.nurse,
    photoUrl: 'https://example.com/avatar.png',
  );

  testGoldens('🖼️ ProfileScreen golden - light/dark with scaling',
      (tester) async {
    final builder = DeviceBuilder()
      ..addScenario(
        name: 'Light mode, normal text scale',
        widget: ProviderScope(
          overrides: [
            authControllerProvider
                .overrideWith(() => MockAuthController(mockUser)),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      )
      ..addScenario(
        name: 'Dark mode, scaled text',
        widget: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.2)),
          child: ProviderScope(
            overrides: [
              authControllerProvider
                  .overrideWith(() => MockAuthController(mockUser)),
            ],
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const ProfileScreen(),
            ),
          ),
        ),
      );

    await tester.pumpDeviceBuilder(builder);
    await screenMatchesGolden(tester, 'profile_screen');
  });
}
