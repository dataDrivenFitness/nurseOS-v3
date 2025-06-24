import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/auth/services/abstract_auth_service.dart';

class FirebaseAuthService implements AbstractAuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<UserModel> signIn(String email, String password) async {
    debugPrint('🔐 Attempting Firebase sign-in for: $email');

    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user?.uid;
    if (uid == null) {
      debugPrint('❌ Sign-in failed: UID is null');
      throw Exception('Authentication failed: UID is missing.');
    }

    debugPrint('✅ Firebase Auth success — UID: $uid');

    final docRef = _db.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      debugPrint('❌ No Firestore user profile found for UID: $uid');
      throw Exception('User profile not found in Firestore');
    }

    final rawData = doc.data();
    debugPrint('🧾 Raw Firestore data: $rawData');

    try {
      final user = UserModel.fromJson(rawData!);
      debugPrint(
          '🧩 UserModel constructed: ${user.email}, role=${user.role.name}');
      return user;
    } catch (e, stack) {
      debugPrint('🛑 Failed to deserialize Firestore doc: $e');
      debugPrintStack(stackTrace: stack);
      throw Exception('Invalid user document format.');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    debugPrint('👋 User signed out');
  }

  @override
  Stream<UserModel?> get onAuthStateChanged {
    return _auth.authStateChanges().asyncMap((fb.User? user) async {
      if (user == null) {
        debugPrint('🔁 Auth stream: no user signed in');
        return null;
      }

      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        debugPrint('⚠️ Auth stream: no Firestore doc for UID: ${user.uid}');
        return null;
      }

      final raw = doc.data();
      debugPrint('🧾 Auth stream raw user doc: $raw');

      try {
        final model = UserModel.fromJson(raw!);
        debugPrint(
            '📲 Auth stream loaded user: ${model.email}, role=${model.role.name}');
        return model;
      } catch (e) {
        debugPrint('🛑 Auth stream deserialization failed: $e');
        return null;
      }
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('🔎 No current Firebase user session');
      return null;
    }

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      debugPrint('🛑 Firestore doc missing for current user UID: ${user.uid}');
      return null;
    }

    final raw = doc.data();
    debugPrint('🧾 Current user Firestore data: $raw');

    try {
      final model = UserModel.fromJson(raw!);
      debugPrint('✅ Current Firebase user restored: ${model.email}');
      return model;
    } catch (e) {
      debugPrint('🛑 Current user deserialization failed: $e');
      return null;
    }
  }
}
