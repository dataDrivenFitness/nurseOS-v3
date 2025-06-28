// 📁 lib/features/preferences/data/font_scale_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // ← FirebaseException
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nurseos_v3/core/env/env.dart';
import 'package:nurseos_v3/core/providers/shared_prefs_provider.dart';

/* ──────────────────────────────────────────────────────────────
   Abstraction
─────────────────────────────────────────────────────────────── */
abstract class AbstractFontScaleRepository {
  Future<double?> getFontScale(String uid);
  Future<void> setFontScale(String uid, double scale);
  Stream<double> watchFontScale(String uid); // live updates
}

/* ──────────────────────────────────────────────────────────────
   Firebase + SharedPreferences implementation
─────────────────────────────────────────────────────────────── */
class FirebaseFontScaleRepository implements AbstractFontScaleRepository {
  FirebaseFontScaleRepository(this._prefs, this._firestore);

  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;

  static const _prefsKey = 'fontScale';

  /// users/{uid}/preferences/global
  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.doc('users/$uid/preferences/global');

  @override
  Future<double?> getFontScale(String uid) async {
    if (uid.isEmpty) throw ArgumentError('UID required');

    // ① local cache
    final local = _prefs.getDouble(_prefsKey);
    if (local != null) return local;

    // ② Firestore fallback
    final raw = (await _doc(uid).get()).data()?['fontScale'];
    if (raw is num) {
      final value = raw.toDouble();
      await _prefs.setDouble(_prefsKey, value);
      return value;
    }
    return null;
  }

  @override
  Future<void> setFontScale(String uid, double scale) async {
    if (uid.isEmpty) throw ArgumentError('UID required');
    await _prefs.setDouble(_prefsKey, scale);
    await _doc(uid).set({'fontScale': scale}, SetOptions(merge: true));
  }

  /*─────────────────────────────
          Live Firestore stream
  ─────────────────────────────*/
  @override
  Stream<double> watchFontScale(String uid) {
    return _doc(uid)
        .snapshots()
        .handleError((e, st) {
          // 🛡️  Ignore the single permission-denied event after logout
          if (e is FirebaseException && e.code == 'permission-denied') {
            // no-op
          } else {
            Error.throwWithStackTrace(e, st); // bubble up anything else
          }
        })
        .map((snap) => snap.data()?['fontScale'])
        .where((raw) => raw is num)
        .map<double>((raw) => (raw as num).toDouble());
  }
}

/* ──────────────────────────────────────────────────────────────
   Provider
─────────────────────────────────────────────────────────────── */
final fontScaleRepositoryProvider =
    Provider<AbstractFontScaleRepository>((ref) {
  if (useMockServices) {
    throw UnimplementedError('MockFontScaleRepository not implemented');
  }

  final prefs = ref.watch(sharedPreferencesProvider);
  final firestore = FirebaseFirestore.instance;

  return FirebaseFontScaleRepository(prefs, firestore);
});
