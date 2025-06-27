import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';

final userProfileProvider =
    AsyncNotifierProvider<UserProfileController, UserModel>(
  UserProfileController.new,
);

/// 🧠 Handles display data like name/photo — NOT login or session state.
/// Keeps router stable even on user updates.
class UserProfileController extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('No user session');

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .withConverter<UserModel>(
          fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
          toFirestore: (user, _) => user.toJson(),
        )
        .get();

    final user = userDoc.data();
    if (user == null) throw Exception('User document not found');
    return user;
  }

  /// ✏️ Updates Firestore + optionally avatar
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
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .withConverter<UserModel>(
          fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
          toFirestore: (user, _) => user.toJson(),
        );

    String? newPhotoUrl;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
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

      // 🔁 Fetch updated profile
      final fresh = await userDocRef.get();
      final model = fresh.data();
      if (model == null) throw Exception('Update failed to persist');

      return model;
    });
  }
}
