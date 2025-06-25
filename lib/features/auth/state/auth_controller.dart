// lib/features/auth/state/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';

part 'auth_controller.g.dart';

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
          .withConverter(
            fromFirestore: (snapshot, _) =>
                UserModel.fromJson(snapshot.data()!),
            toFirestore: (user, _) => user.toJson(),
          )
          .get();

      return userDoc.data();
    });

    return result.value;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(() async {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .withConverter(
            fromFirestore: (snapshot, _) =>
                UserModel.fromJson(snapshot.data()!),
            toFirestore: (user, _) => user.toJson(),
          )
          .get();

      return userDoc.data();
    });

    debugPrint('[AuthController.signIn] user=${result.value?.email}');
    state = result;
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await FirebaseAuth.instance.signOut();
    state = const AsyncValue.data(null);

    ref.invalidateSelf(); // triggers build() again
  }
}
