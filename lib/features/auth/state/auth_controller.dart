import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
            fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
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
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .withConverter(
            fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
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
    ref.invalidateSelf();
  }

  Future<void> updateUser({
    required String firstName,
    required String lastName,
    File? photoFile,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No signed-in user');
    }

    final uid = currentUser.uid;
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);

    String? newPhotoUrl;

    try {
      if (photoFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('avatars/$uid');

        final uploadSnap = await storageRef.putFile(
          photoFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        newPhotoUrl = await uploadSnap.ref.getDownloadURL();
      }

      final updates = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        if (newPhotoUrl != null) 'photoUrl': newPhotoUrl,
      };

      await userDocRef.update(updates);

      // ✅ PATCH: update state directly to avoid triggering router redirect
      final previous = state.value!;
      final updated = previous.copyWith(
        firstName: firstName,
        lastName: lastName,
        photoUrl: newPhotoUrl ?? previous.photoUrl,
      );

      state = AsyncValue.data(updated);
    } catch (e, st) {
      debugPrint('[AuthController.updateUser] upload failed: $e / $st');
      rethrow;
    }
  }
}
