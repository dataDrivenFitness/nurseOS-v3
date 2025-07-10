// 📁 lib/features/profile/state/user_profile_controller.dart (FINAL UPDATE)

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/user_role.dart';
import '../../auth/models/user_model.dart';

class UserProfileController extends AsyncNotifier<UserModel?> {
  static const _firstNameKey = 'cached_firstName';
  static const _lastNameKey = 'cached_lastName';

  late SharedPreferences _prefs;

  @override
  Future<UserModel?> build() async {
    _prefs = await SharedPreferences.getInstance();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    return _fetchUserProfile(currentUser);
  }

  Future<UserModel?> _fetchUserProfile(User currentUser) async {
    // Try Firestore first
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .withConverter<UserModel>(
            fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
            toFirestore: (user, _) => user.toJson(),
          )
          .get();

      final user = doc.data();
      if (user != null) {
        // Cache for future cold boots
        await _cacheUser(user);
        return user;
      }
    } catch (e) {
      // Firestore failed, try cache
      print('Firestore failed, using cache: $e');
    }

    // Fallback to cached data
    final cachedFirst = _prefs.getString(_firstNameKey);
    final cachedLast = _prefs.getString(_lastNameKey);

    if (cachedFirst != null && cachedLast != null) {
      return UserModel(
        uid: currentUser.uid,
        email: currentUser.email ?? '',
        firstName: cachedFirst,
        lastName: cachedLast,
        role: UserRole.nurse, // best-effort fallback
        activeAgencyId: 'default_agency',
        agencyRoles: const {}, // ✅ Fixed: was agencyRoleMap, now agencyRoles
        level: 1, // ✅ fallback default
        xp: 0, // ✅ fallback default
      );
    }

    // No cache available
    throw Exception('User document not found and no cache available');
  }

  Future<void> updateUser({
    required String firstName,
    required String lastName,
    File? photoFile,
    // Healthcare professional fields
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? specialty,
    String? department,
    String? shift,
    String? phoneExtension,
    DateTime? hireDate,
    List<String>? certifications,
    bool? isOnDuty,
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
      // Upload photo if provided
      if (photoFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('avatars/$uid');
        final uploadSnap = await storageRef.putFile(
          photoFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        newPhotoUrl = await uploadSnap.ref.getDownloadURL();
      }

      // Prepare update data (only include non-null values)
      final updates = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        if (newPhotoUrl != null) 'photoUrl': newPhotoUrl,

        // Healthcare professional fields
        if (licenseNumber != null) 'licenseNumber': licenseNumber,
        if (licenseExpiry != null)
          'licenseExpiry': Timestamp.fromDate(licenseExpiry),
        if (specialty != null) 'specialty': specialty,
        if (department != null) 'department': department,
        if (shift != null) 'shift': shift,
        if (phoneExtension != null) 'phoneExtension': phoneExtension,
        if (hireDate != null) 'hireDate': Timestamp.fromDate(hireDate),
        if (certifications != null) 'certifications': certifications,
        if (isOnDuty != null) 'isOnDuty': isOnDuty,
      };

      // Handle nullable fields explicitly (to allow clearing them)
      final nullableUpdates = <String, dynamic>{};

      // If these are explicitly passed as null, we want to clear them
      if (licenseNumber == '') nullableUpdates['licenseNumber'] = null;
      if (specialty == '') nullableUpdates['specialty'] = null;
      if (department == '') nullableUpdates['department'] = null;
      if (shift == '') nullableUpdates['shift'] = null;
      if (phoneExtension == '') nullableUpdates['phoneExtension'] = null;

      // Combine all updates
      updates.addAll(nullableUpdates);

      // Update Firestore
      await userDocRef.update(updates);

      // Get fresh document
      final fresh = await userDocRef.get();
      final model = fresh.data();
      if (model == null) throw Exception('Update failed to persist');

      // Cache new basic info locally for cold-restart
      await _cacheUser(model);
      return model;
    });
  }

  /// Helper method to clear specific healthcare fields
  Future<void> clearHealthcareField(String fieldName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('No signed-in user');

    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await userDocRef.update({fieldName: null});

      // Refresh the user data
      final fresh = await userDocRef
          .withConverter<UserModel>(
            fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
            toFirestore: (user, _) => user.toJson(),
          )
          .get();

      final model = fresh.data();
      if (model == null) throw Exception('Clear field failed');

      await _cacheUser(model);
      return model;
    });
  }

  /// Toggle duty status quickly
  Future<void> toggleDutyStatus() async {
    final user = state.value;
    if (user == null) return;

    await updateUser(
      firstName: user.firstName,
      lastName: user.lastName,
      isOnDuty: !(user.isOnDuty ?? false),
    );
  }

  Future<void> _cacheUser(UserModel user) async {
    await _prefs.setString(_firstNameKey, user.firstName);
    await _prefs.setString(_lastNameKey, user.lastName);
  }
}

final userProfileControllerProvider =
    AsyncNotifierProvider<UserProfileController, UserModel?>(
  () => UserProfileController(),
);

// Stream provider for real-time updates
final userProfileStreamProvider = StreamProvider<UserModel?>((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .withConverter<UserModel>(
        fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
        toFirestore: (user, _) => user.toJson(),
      )
      .snapshots()
      .map((snap) => snap.data())
      .handleError((error) {
    // Handle permission denied errors gracefully during logout
    if (error is FirebaseException && error.code == 'permission-denied') {
      return null;
    }
    throw error;
  });
});
