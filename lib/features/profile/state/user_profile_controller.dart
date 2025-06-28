// 📁 lib/features/profile/state/user_profile_controller.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/core/providers/shared_prefs_provider.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*──────────────────────────────────────────────────────────────
  🔄  Reactive profile stream (safe for auth changes)
──────────────────────────────────────────────────────────────*/
final userProfileStreamProvider = StreamProvider<UserModel>((ref) {
  final authAsync = ref.watch(authControllerProvider);

  // If auth is loading, just wait.
  if (authAsync.isLoading) {
    return const Stream.empty();
  }

  // If user is null (logged out), emit nothing.
  final user = authAsync.value;
  if (user == null) {
    return const Stream.empty();
  }

  // Now we have a uid – subscribe to Firestore.
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .withConverter<UserModel>(
        fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
        toFirestore: (model, _) => model.toJson(),
      )
      .snapshots()
      .map((snap) => snap.data()!)
      .handleError((e, st) {
    if (e is FirebaseException && e.code == 'permission-denied') {
      // Happens briefly during sign-out; ignore.
    } else {
      Error.throwWithStackTrace(e, st);
    }
  });
});

/*──────────────────────────────────────────────────────────────
  One-shot fetch + update controller
──────────────────────────────────────────────────────────────*/
final userProfileProvider =
    AsyncNotifierProvider.autoDispose<UserProfileController, UserModel>(
  UserProfileController.new,
);

class UserProfileController extends AutoDisposeAsyncNotifier<UserModel> {
  static const _firstNameKey = 'cached_firstName';
  static const _lastNameKey = 'cached_lastName';

  late final SharedPreferences _prefs = ref.read(sharedPreferencesProvider);

  @override
  Future<UserModel> build() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('No user session');

    // 🟢 Fast path — local cache
    final cachedFirst = _prefs.getString(_firstNameKey);
    final cachedLast = _prefs.getString(_lastNameKey);
    if (cachedFirst != null && cachedLast != null) {
      // Return a lightweight model while Firestore loads
      return UserModel(
        uid: currentUser.uid,
        email: currentUser.email ?? '',
        firstName: cachedFirst,
        lastName: cachedLast,
        role: UserRole.nurse, // best-effort fallback
      );
    }

    // 🟡 Network path — fetch from Firestore
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .withConverter<UserModel>(
          fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
          toFirestore: (user, _) => user.toJson(),
        )
        .get();

    final user = doc.data();
    if (user == null) throw Exception('User document not found');

    // Cache for future cold boots
    await _cacheUser(user);
    return user;
  }

  Future<void> updateUser({
    required String firstName,
    required String lastName,
    File? photoFile,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('No signed-in user');

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

      final fresh = await userDocRef.get();
      final model = fresh.data();
      if (model == null) throw Exception('Update failed to persist');

      // 🆕  Cache new name locally for cold-restart
      await _cacheUser(model);
      return model;
    });
  }

  /*───────────────────────────────────────────────────────────
        Helper: write name to SharedPreferences
  ───────────────────────────────────────────────────────────*/
  Future<void> _cacheUser(UserModel user) async {
    await _prefs.setString(_firstNameKey, user.firstName);
    await _prefs.setString(_lastNameKey, user.lastName);
  }
}
