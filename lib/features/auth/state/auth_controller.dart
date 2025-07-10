import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';
import '../../profile/state/user_profile_controller.dart';
import '../../agency/state/session_agency_provider.dart'; // 👈 NEW

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<UserModel?> build() async {
    final current = FirebaseAuth.instance.currentUser;
    if (current == null) return null;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(current.uid)
          .withConverter<UserModel>(
            fromFirestore: (s, _) => UserModel.fromJson(s.data()!),
            toFirestore: (m, _) => m.toJson(),
          )
          .get();

      final user = snap.data();

      // ✅ Set active agency from cached value or fallback to primary
      final agencyCtrl = ref.read(sessionAgencyProvider.notifier);
      if (agencyCtrl.state == null && user != null) {
        await agencyCtrl.setAgency(user.activeAgencyId);
      }

      return user;
    } on FirebaseException catch (e, st) {
      if (e.code == 'permission-denied') return null;
      debugPrint('❌ AuthController.build: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();

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

      final user = snap.data();

      // ✅ Set active agency from primary
      if (user != null) {
        await ref
            .read(sessionAgencyProvider.notifier)
            .setAgency(user.activeAgencyId);
      }

      return user;
    });

    state = result;
    ref.invalidate(userProfileControllerProvider);
  }

  Future<void> signOut() async {
    // Clear UI immediately
    state = const AsyncValue.data(null);

    // Revoke auth and session
    await FirebaseAuth.instance.signOut();
    await ref.read(sessionAgencyProvider.notifier).clear();

    // Invalidate ourself
    ref.invalidateSelf();
  }
}
