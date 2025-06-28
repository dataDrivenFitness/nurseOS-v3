// 📁 lib/features/preferences/data/locale_repository.dart

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nurseos_v3/core/env/env.dart';
import 'package:nurseos_v3/core/providers/shared_prefs_provider.dart'; // ✅ single source

/* ──────────────────────────────────────────────────────────────
   Abstraction layer
─────────────────────────────────────────────────────────────── */
abstract class AbstractLocaleRepository {
  Future<Locale?> getLocale(String uid);
  Future<void> setLocale(String uid, Locale locale);
}

/* ──────────────────────────────────────────────────────────────
   Firebase + SharedPreferences implementation
─────────────────────────────────────────────────────────────── */
class FirebaseLocaleRepository implements AbstractLocaleRepository {
  FirebaseLocaleRepository(this._prefs, this._firestore);

  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;

  static const _prefsKey = 'app_locale';

  @override
  Future<Locale?> getLocale(String uid) async {
    if (uid.isEmpty) throw ArgumentError('UID is required for getLocale');

    // 1️⃣ Local read (fast path)
    final localCode = _prefs.getString(_prefsKey);
    if (localCode?.isNotEmpty == true) return Locale(localCode!);

    // 2️⃣ Firestore fallback
    final doc = await _firestore.doc('users/$uid/preferences/global').get();
    final remoteCode = doc.data()?['locale'];

    if (remoteCode is String && remoteCode.isNotEmpty) {
      await _prefs.setString(_prefsKey, remoteCode); // cache locally
      return Locale(remoteCode);
    }

    return null;
  }

  @override
  Future<void> setLocale(String uid, Locale locale) async {
    if (uid.isEmpty) throw ArgumentError('UID is required for setLocale');

    final code = locale.languageCode;

    // Write local & remote
    await _prefs.setString(_prefsKey, code);
    await _firestore
        .doc('users/$uid/preferences/global')
        .set({'locale': code}, SetOptions(merge: true));
  }
}

/* ──────────────────────────────────────────────────────────────
   Provider
─────────────────────────────────────────────────────────────── */
final localeRepositoryProvider = Provider<AbstractLocaleRepository>((ref) {
  if (useMockServices) {
    throw UnimplementedError('MockLocaleRepository not implemented');
  }

  // 🔹 Use the single global sharedPrefs provider
  final prefs = ref.watch(sharedPreferencesProvider);
  final firestore = FirebaseFirestore.instance;

  return FirebaseLocaleRepository(prefs, firestore);
});
