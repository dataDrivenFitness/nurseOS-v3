// 📁 lib/core/theme/theme_controller.dart

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';

part 'theme_controller.g.dart';

/// Controls app-wide dark/light theme, persisted locally and to Firestore.
///
/// SharedPreferences key: `'dark_mode'`
/// Firestore path: `users/{uid}/preferences/global → { darkMode: true }`
@Riverpod(keepAlive: true)
class ThemeController extends AsyncNotifier<ThemeMode> {
  static const _prefsKey = 'dark_mode';

  SharedPreferences? _prefs;
  FirebaseFirestore? _firestore;
  String? _uid;

  bool get _isReady => _prefs != null && _firestore != null && _uid != null;

  Future<void> _initIfNeeded() async {
    if (_isReady) return;

    _prefs ??= await SharedPreferences.getInstance();
    _firestore ??= FirebaseFirestore.instance;

    final auth = await ref.watch(authControllerProvider.future);
    _uid = auth?.uid ?? '';
  }

  @override
  Future<ThemeMode> build() async {
    await _initIfNeeded();

    if (_uid!.isEmpty) {
      dev.log('🌓 Guest session — using system theme fallback');
      return ThemeMode.system;
    }

    final local = _prefs!.getBool(_prefsKey);
    if (local != null) {
      dev.log('📦 Theme loaded from local: $local');
      return local ? ThemeMode.dark : ThemeMode.light;
    }

    final doc = await _firestore!.doc('users/$_uid/preferences/global').get();
    final remote = doc.data()?['darkMode'];

    if (remote is bool) {
      await _prefs!.setBool(_prefsKey, remote);
      dev.log('☁️ Theme loaded from Firestore: $remote');
      return remote ? ThemeMode.dark : ThemeMode.light;
    }

    return ThemeMode.system;
  }

  Future<void> toggleTheme(bool isDark) async {
    await _initIfNeeded();

    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = AsyncValue.data(newMode);

    await _prefs!.setBool(_prefsKey, isDark);
    dev.log('💾 darkMode saved locally: $isDark');

    if (_uid!.isNotEmpty) {
      await _firestore!
          .doc('users/$_uid/preferences/global')
          .set({'darkMode': isDark}, SetOptions(merge: true));
      dev.log('🌐 darkMode saved remotely for $_uid: $isDark');
    }
  }
}
