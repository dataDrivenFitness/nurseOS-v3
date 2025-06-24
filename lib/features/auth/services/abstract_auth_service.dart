import 'package:nurseos_v3/features/auth/models/user_model.dart';

abstract class AbstractAuthService {
  /// Attempts sign-in with email/password (or mocks)
  Future<UserModel> signIn(String email, String password);

  /// Signs the user out (clears auth state)
  Future<void> signOut();

  /// Stream of auth state changes, resolved to [UserModel]
  Stream<UserModel?> get onAuthStateChanged;

  /// Loads the current user session if available
  Future<UserModel?> getCurrentUser(); // ✅ Newly added method
}
