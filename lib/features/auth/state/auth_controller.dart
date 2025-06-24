import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/auth/services/auth_service_provider.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
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

    ref.invalidateSelf();
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await ref.read(authServiceProvider).signOut();
    state = const AsyncValue.data(null);

    ref.invalidateSelf();
  }
}
