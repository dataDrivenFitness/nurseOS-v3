// 📁 lib/features/auth/state/auth_controller.dart
//
// Controls authentication state (sign-in / sign-out) and exposes the
// current UserModel for the rest of the app.
//
// Key design points
// ─────────────────
// • build()  : fast, single fetch of the user profile (Firestore)
// • signIn() : writes AsyncValue.loading → AsyncValue<UserModel>
// • signOut(): emits null + invalidates user-scoped providers
//
// NOTE: userProfileStreamProvider now DEPENDS on this controller, so
//       we must **not** invalidate that stream inside signOut()
//       (doing so created the CircularDependencyError).

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nurseos_v3/core/theme/theme_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';
import '../../profile/state/user_profile_controller.dart'; // one-shot + stream
import '../../preferences/controllers/font_scale_controller.dart'; // font scale
import '../../preferences/controllers/locale_controller.dart'; // locale

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
/*───────────────────────────────────────────────────────────────
  build()  –  called once per ProviderScope refresh
───────────────────────────────────────────────────────────────*/
  @override
  Future<UserModel?> build() async {
    final current = FirebaseAuth.instance.currentUser;
    if (current == null) return null; // guest session

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(current.uid)
          .withConverter<UserModel>(
            fromFirestore: (s, _) => UserModel.fromJson(s.data()!),
            toFirestore: (m, _) => m.toJson(),
          )
          .get();

      return snap.data(); // may be null if doc missing
    } on FirebaseException catch (e, st) {
      // Permission-denied can surface for a split-second during logout;
      // swallow it and return null so dependents reset gracefully.
      if (e.code == 'permission-denied') return null;
      debugPrint('❌ AuthController.build: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

/*───────────────────────────────────────────────────────────────
  signIn(email, password)
───────────────────────────────────────────────────────────────*/
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading(); // notify UI

    final result = await AsyncValue.guard(() async {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .withConverter<UserModel>(
            fromFirestore: (s, _) => UserModel.fromJson(s.data()!),
            toFirestore: (m, _) => m.toJson(),
          )
          .get();

      return snap.data();
    });

    state = result; // → data / error
    ref.invalidate(userProfileProvider); // refresh one-shot cache
    // DO NOT invalidate userProfileStreamProvider – it depends on us and
    // will rebuild automatically when `state` changes.
  }

/*───────────────────────────────────────────────────────────────
  signOut() – teardown order is important
───────────────────────────────────────────────────────────────*/
  /*───────────────────────────────────────────────────────────
  signOut() – emit null, sign out, refresh self
───────────────────────────────────────────────────────────*/
  Future<void> signOut() async {
    // 1️⃣  Notify listeners that auth is gone (UI navigates to /login)
    state = const AsyncValue.data(null);

    // 2️⃣  Revoke Firebase credentials
    await FirebaseAuth.instance.signOut();

    // 3️⃣  Clear any cached value / error in this controller
    ref.invalidateSelf();
  }
}
