// 📁 test/utils/test_fakes.dart
//
// Lightweight fakes for Riverpod-based tests. They mirror the *public*
// controller classes used in production so that `overrideWith()` compiles
// without casting gymnastics.

import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/preferences/controllers/locale_controller.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/core/models/user_role.dart';

/// ─────────────────────────────────────────────────────────────
/// 0. Shared dummy data
/// ─────────────────────────────────────────────────────────────

const fakeUser = UserModel(
  uid: 'test-123',
  firstName: 'Jane',
  lastName: 'Doe',
  email: 'foo@bar.com',
  role: UserRole.nurse, // adjust if your enum differs
  level: 1,
  // add any other `required` fields here with placeholder values
);

/// ─────────────────────────────────────────────────────────────
/// 1. Fake AUTH controller
/// ─────────────────────────────────────────────────────────────

class FakeAuthController extends AuthController {
  FakeAuthController([this._initial]);

  final UserModel? _initial;

  /// Matches `Future<UserModel?> build()` in the real controller.
  @override
  Future<UserModel?> build() async => _initial;

  // Minimal API so widgets can call these without hitting Firebase.
  @override
  Future<void> signIn(String email, String password) async =>
      state = AsyncValue.data(_initial);

  @override
  Future<void> signOut() async => state = const AsyncValue.data(null);
}

/// ─────────────────────────────────────────────────────────────
/// 2. Fake LOCALE controller
/// ─────────────────────────────────────────────────────────────

class FakeLocaleController extends LocaleController {
  // Not const: super-constructor isn’t const.
  FakeLocaleController();

  @override
  Future<Locale> build() async => const Locale('en');
  bool get isLoading => state.isLoading;
}
/* ─── Capturing AUTH controller ──────────────────────────────
   Records the last credentials passed to signIn() so tests can
   assert the values without touching Firebase. */

class CapturingAuthController extends AuthController {
  String? emailCaptured;
  String? passwordCaptured;

  @override
  Future<UserModel?> build() async => null; // start unauthenticated

  @override
  Future<void> signIn(String email, String password) async {
    emailCaptured = email;
    passwordCaptured = password;
  }

  @override
  Future<void> signOut() async {}
}
