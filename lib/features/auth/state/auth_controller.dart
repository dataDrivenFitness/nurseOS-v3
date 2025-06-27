import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';

part 'auth_controller.g.dart';

/// ✅ This controller now only manages login/logout and auth status.
/// All profile logic (names, photos) has moved to `user_profile_controller.dart`.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<UserModel?> build() async {
    final result = await AsyncValue.guard(() async {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .withConverter<UserModel>(
            fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
            toFirestore: (user, _) => user.toJson(),
          )
          .get();

      return userDoc.data();
    });

    return result.value;
  }

  /// 🔐 Email/password login — updates state and triggers downstream routing
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(() async {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .withConverter<UserModel>(
            fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
            toFirestore: (user, _) => user.toJson(),
          )
          .get();

      return userDoc.data();
    });

    debugPrint('[AuthController.signIn] user=${result.value?.email}');
    state = result;
  }

  /// 🔓 Sign-out and reset session state
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await FirebaseAuth.instance.signOut();
    state = const AsyncValue.data(null);
    ref.invalidateSelf(); // refresh all dependent auth state
  }
}
