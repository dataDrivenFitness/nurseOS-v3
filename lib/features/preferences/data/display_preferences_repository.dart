// 📁 lib/features/preferences/data/display_preferences_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // ← for FirebaseException
import '../domain/display_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DisplayPreferencesRepository {
  DisplayPreferencesRepository({required this.firestore});
  final FirebaseFirestore firestore;

  /*──────────────── Canonical doc path ─────────────────────*/
  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      firestore.doc('users/$uid/preferences/global');

  /*──────────────── Whole-object helpers ───────────────────*/
  Future<DisplayPreferences> fetch(String uid) async {
    final snap = await _doc(uid).get();
    if (!snap.exists) return DisplayPreferences.defaults();
    return DisplayPreferences.fromJson(snap.data() ?? {});
  }

  Future<void> save(String uid, DisplayPreferences prefs) async {
    await _doc(uid).set(prefs.toJson());
  }

  /*──────────────── Dark-mode helpers (boolean) ────────────*/
  Future<ThemeMode?> getThemeMode(String uid) async {
    final data = (await _doc(uid).get()).data();
    final raw = data?['darkMode'];

    // Back-compat: accept former string field as well
    if (raw == true) return ThemeMode.dark;
    if (raw == false) return ThemeMode.light;
    if (raw == 'dark') return ThemeMode.dark;
    if (raw == 'light') return ThemeMode.light;
    return null;
  }

  Future<void> setThemeMode(String uid, ThemeMode mode) async {
    final value = mode == ThemeMode.dark;
    await _doc(uid).set({'darkMode': value}, SetOptions(merge: true));
  }

  Stream<ThemeMode> watchThemeMode(String uid) {
    return _doc(uid).snapshots().handleError((e, st) {
      // 🛡️  Silently swallow the logout permission error
      if (e is FirebaseException && e.code == 'permission-denied') {
        // no-op
      } else {
        // Propagate anything unexpected
        Error.throwWithStackTrace(e, st);
      }
    }).map((snap) {
      final raw = snap.data()?['darkMode'];
      if (raw == true) return ThemeMode.dark;
      if (raw == false) return ThemeMode.light;

      // Legacy string values
      if (raw == 'dark') return ThemeMode.dark;
      if (raw == 'light') return ThemeMode.light;

      return ThemeMode.system;
    });
  }
}

/*──────────────── Provider ─────────────────────────────────*/
final displayPreferencesRepositoryProvider = Provider((ref) {
  return DisplayPreferencesRepository(
    firestore: FirebaseFirestore.instance,
  );
});
