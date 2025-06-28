// 📁 lib/features/preferences/data/locale_repository.dart
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // ← FirebaseException
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nurseos_v3/core/env/env.dart';
import 'package:nurseos_v3/core/providers/shared_prefs_provider.dart';

/* ──────────────────────────────────────────────────────────────
   Abstraction layer
─────────────────────────────────────────────────────────────── */
abstract class AbstractLocaleRepository {
  Future<Locale?> getLocale(String uid);
  Future<void> setLocale(String uid, Locale locale);
  Stream<Locale> watchLocale(String uid); // live updates
}

/* ──────────────────────────────────────────────────────────────
   Firebase + SharedPreferences implementation
─────────────────────────────────────────────────────────────── */
class FirebaseLocaleRepository implements AbstractLocaleRepository {
  FirebaseLocaleRepository(this._prefs, this._firestore);

  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;

  static const _prefsKey = 'app_locale';
  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.doc('users/$uid/preferences/global');

  @override
  Future<Locale?> getLocale(String uid) async {
    if (uid.isEmpty) throw ArgumentError('UID is required');

    // ① local cache
    final cached = _prefs.getString(_prefsKey);
    if (cached?.isNotEmpty == true) return Locale(cached!);

    // ② Firestore fallback
    final code = (await _doc(uid).get()).data()?['locale'];
    if (code is String && code.isNotEmpty) {
      await _prefs.setString(_prefsKey, code);
      return Locale(code);
    }
    return null;
  }

  @override
  Future<void> setLocale(String uid, Locale locale) async {
    if (uid.isEmpty) throw ArgumentError('UID is required');

    final code = locale.languageCode;
    await _prefs.setString(_prefsKey, code);
    await _doc(uid).set({'locale': code}, SetOptions(merge: true));
  }

  /*───────────────────────────────────────────────────────────
                   Live Firestore stream
  ───────────────────────────────────────────────────────────*/
  @override
  Stream<Locale> watchLocale(String uid) {
    return _doc(uid)
        .snapshots()
        .handleError((e, st) {
          // 🛡️  Ignore post-logout permission error
          if (e is FirebaseException && e.code == 'permission-denied') {
            // no-op
          } else {
            Error.throwWithStackTrace(e, st); // bubble up unexpected errors
          }
        })
        .map((snap) => snap.data()?['locale'])
        .where((code) => code is String && code.isNotEmpty)
        .map<Locale>((code) => Locale(code as String));
  }
}

/* ──────────────────────────────────────────────────────────────
   Provider
─────────────────────────────────────────────────────────────── */
final localeRepositoryProvider = Provider<AbstractLocaleRepository>((ref) {
  if (useMockServices) {
    throw UnimplementedError('MockLocaleRepository not implemented');
  }
  final prefs = ref.watch(sharedPreferencesProvider);
  final firestore = FirebaseFirestore.instance;
  return FirebaseLocaleRepository(prefs, firestore);
});
