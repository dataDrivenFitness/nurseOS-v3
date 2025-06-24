import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/auth/services/auth_service_provider.dart';

/// AuthController manages authentication state for [UserModel?].
/// It uses Riverpod's [AsyncNotifier] to manage async flows safely.
class AuthController extends AsyncNotifier<UserModel?> {
  /// Initializes the controller by attempting to load the current user
  @override
  Future<UserModel?> build() async {
    final authService = ref.read(authServiceProvider);
    final user = await authService.getCurrentUser();
    debugPrint('[AuthController.build] user=$user');
    return user;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();

    final userValue = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      return await authService.signIn(email, password);
    });

    debugPrint('[AuthController.signIn] userValue=${userValue.value}');
    state = userValue;

    // Also print after state assignment!
    debugPrint('[AuthController.signIn] state set, now: $state');

    ref.invalidateSelf();
  }

  /// Signs out the user and sets state to null
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await ref.read(authServiceProvider).signOut();
    state = const AsyncValue.data(null);

    // ✅ Force rebuild after sign out too
    ref.invalidateSelf();
  }
}

/// Provider for AuthController
final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserModel?>(() => AuthController());
