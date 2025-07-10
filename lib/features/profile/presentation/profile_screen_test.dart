import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/profile/presentation/profile_screen.dart';

class FakeAuthController extends AuthController {
  final UserModel mockUser;
  FakeAuthController(this.mockUser);

  @override
  Future<UserModel?> build() async => mockUser;
}

void main() {
  late UserModel mockUser;

  setUp(() {
    mockUser = UserModel(
      uid: 'nurse001',
      firstName: 'Sam',
      lastName: 'Rivera',
      email: 'sam@nurseos.com',
      xp: 1200,
      level: 5,
      role: UserRole.nurse,
      photoUrl: 'https://example.com/avatar.png',
      activeAgencyId: 'test_agency',
      agencyRoles: {}, // ✅ Fixed: was agencyRoleMap, now agencyRoles
    );
  });

  Future<void> pumpProfileScreen(WidgetTester tester,
      {double textScale = 1.0}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider
              .overrideWith(() => FakeAuthController(mockUser)),
        ],
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
              child: child!,
            );
          },
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders user name, email and avatar', (tester) async {
    await pumpProfileScreen(tester);

    expect(find.text('Sam Rivera'), findsOneWidget);
    expect(find.text('sam@nurseos.com'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsWidgets);
  });

  testWidgets('supports dynamic text scaling', (tester) async {
    await pumpProfileScreen(tester, textScale: 1.3);

    expect(find.text('Sam Rivera'), findsOneWidget);
    expect(find.text('sam@nurseos.com'), findsOneWidget);
  });
}
