import 'package:flutter_test/flutter_test.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/auth/services/mock_auth_service.dart';

void main() {
  group('MockAuthService', () {
    final service = MockAuthService();

    test('returns nurse role by default', () async {
      final user = await service.signIn('nurse@example.com', 'password123');

      expect(user, isA<UserModel>());
      expect(user.email, 'nurse@example.com');
      expect(user.role, UserRole.nurse);
    });

    test('returns admin role if email contains "admin"', () async {
      final user = await service.signIn('admin@example.com', 'adminpass');

      expect(user.role, UserRole.admin);
      expect(user.firstName, 'Admin');
    });

    test('emits auth state changes correctly', () async {
      final states = <UserModel?>[];
      final sub = service.onAuthStateChanged.listen(states.add);

      await service.signIn('nurse@example.com', 'password');
      await service.signOut();

      await Future.delayed(const Duration(milliseconds: 100));
      await sub.cancel();

      expect(states.first, isA<UserModel>());
      expect(states.last, isNull);
    });
  });
}
