import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/features/auth/services/auth_service_provider.dart';
import 'package:nurseos_v3/features/auth/services/mock_auth_service.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';

void main() {
  group('AuthController', () {
    test('returns nurse for non-admin email', () async {
      final container = ProviderContainer(overrides: [
        authServiceProvider.overrideWithValue(MockAuthService()),
      ]);

      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn('nurse@demo.com', 'pw');

      final result = container.read(authControllerProvider);
      expect(result.value!.role, UserRole.nurse);
    });

    test('returns admin for admin email', () async {
      final container = ProviderContainer(overrides: [
        authServiceProvider.overrideWithValue(MockAuthService()),
      ]);

      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn('admin@demo.com', 'pw');

      final result = container.read(authControllerProvider);
      expect(result.value!.role, UserRole.admin);
    });

    test('signOut resets user', () async {
      final container = ProviderContainer(overrides: [
        authServiceProvider.overrideWithValue(MockAuthService()),
      ]);

      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn('nurse@demo.com', 'pw');
      await controller.signOut();

      expect(
          container.read(authControllerProvider), const AsyncValue.data(null));
    });
  });
}
