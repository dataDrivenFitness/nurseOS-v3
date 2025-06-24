import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurseos_v3/app.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';

import '../../../mock/mock_auth_controller.dart';

void main() {
  testWidgets('🧪 AuthWidget shows AppShell when user is logged in',
      (tester) async {
    const testUser = UserModel(
      uid: 'mock123',
      firstName: 'Test',
      lastName: 'Nurse',
      email: 'nurse@demo.com',
      role: UserRole.nurse,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider
              .overrideWith(() => FakeAuthController(testUser)),
        ],
        child: const NurseOSApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Patients'), findsOneWidget); // Adjust as needed
  });
}
