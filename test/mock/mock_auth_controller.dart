import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';

class FakeAuthController extends AuthController {
  final UserModel mockUser;

  FakeAuthController(this.mockUser);

  @override
  Future<UserModel?> build() async {
    return mockUser;
  }
}
