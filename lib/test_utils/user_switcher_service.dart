// 📁 lib/test_utils/user_switcher_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';

/// Service for switching between test users in admin mode
/// ⚠️ FOR TESTING ONLY - Should not be available in production
class UserSwitcherService {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  UserSwitcherService(this._firestore, this._ref);

  /// Fetch all users from Firestore for admin switching
  Future<List<UserModel>> getAllTestUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .withConverter<UserModel>(
            fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
            toFirestore: (user, _) => user.toJson(),
          )
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Switch to a different user by directly updating auth state
  /// ⚠️ Bypasses normal authentication - for testing only
  Future<void> switchToUser(UserModel targetUser) async {
    try {
      // Invalidate current auth state and set new user
      _ref.invalidate(authControllerProvider);

      // Wait for the provider to rebuild, then manually set the new user
      await Future.delayed(const Duration(milliseconds: 100));

      // Set the new user state directly (testing only)
      _ref.read(authControllerProvider.notifier).state =
          AsyncValue.data(targetUser);
    } catch (e) {
      throw Exception('Failed to switch user: $e');
    }
  }

  /// Get current user from auth state
  UserModel? getCurrentUser() {
    return _ref.read(authControllerProvider).value;
  }
}

/// Provider for user switcher service
final userSwitcherServiceProvider = Provider<UserSwitcherService>((ref) {
  return UserSwitcherService(FirebaseFirestore.instance, ref);
});
