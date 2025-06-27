// 📁 lib/core/theme/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';

part 'theme_controller.g.dart';

/// Controls app-wide dark/light theme, persisted locally and to Firestore.
///
/// 🔹 SharedPreferences key: 'dark_mode'
/// 🔸 Firestore doc path: users/{uid}/preferences/global → { darkMode: true }
@Riverpod(keepAlive: true)
class ThemeController extends AsyncNotifier<ThemeMode> {
  static const _prefsKey = 'dark_mode';

  late final SharedPreferences _prefs;
  late final FirebaseFirestore _firestore;
  late final String _uid;

  /// Hydrates saved theme mode — fast boot via SharedPreferences, then Firestore.
  @override
  Future<ThemeMode> build() async {
    _prefs = await SharedPreferences.getInstance();
    _firestore = FirebaseFirestore.instance;

    final auth = ref.read(authControllerProvider).valueOrNull;
    _uid = auth?.uid ?? '';

    if (_uid.isEmpty) {
      debugPrint('⚠️ Skipping theme load — auth unavailable or uid empty');
      return ThemeMode.system;
    }

    debugPrint('📥 Loading theme for uid="$_uid"');

    // Try local cache first
    final local = _prefs.getBool(_prefsKey);
    if (local != null) return local ? ThemeMode.dark : ThemeMode.light;

    // Fallback to Firestore
    final doc = await _firestore.doc('users/$_uid/preferences/global').get();
    final remote = doc.data()?['darkMode'];

    if (remote is bool) {
      await _prefs.setBool(_prefsKey, remote);
      return remote ? ThemeMode.dark : ThemeMode.light;
    }

    return ThemeMode.system;
  }

  /// Toggles theme and saves to local + cloud.
  Future<void> toggleTheme(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = AsyncValue.data(newMode);

    // Local write
    await _prefs.setBool(_prefsKey, isDark);

    // Cloud write
    if (_uid.isNotEmpty) {
      await _firestore
          .doc('users/$_uid/preferences/global')
          .set({'darkMode': isDark}, SetOptions(merge: true));
    }
  }

  /// Exposes whether dark mode is active for toggles.
  bool get isDark => state.valueOrNull == ThemeMode.dark;
}
