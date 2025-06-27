import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/env/env.dart';

/// Interface for font scale persistence.
///
/// Supports fast local read via SharedPreferences and long-term sync via Firestore.
abstract class AbstractFontScaleRepository {
  /// Returns most recently saved font scale.
  ///
  /// 1. Checks [SharedPreferences]
  /// 2. Fallbacks to Firestore: `users/{uid}/preferences/global.font_scale`
  Future<double?> getFontScale(String uid);

  /// Saves font scale to both local cache and Firestore.
  Future<void> setFontScale(String uid, double scale);
}

/// Firebase-backed repository that supports dual persistence.
class FirebaseFontScaleRepository implements AbstractFontScaleRepository {
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;

  FirebaseFontScaleRepository(this._prefs, this._firestore);

  static const _prefsKey = 'font_scale';

  @override
  Future<double?> getFontScale(String uid) async {
    debugPrint('📥 getFontScale called with uid: $uid');

    if (uid.isEmpty) {
      throw ArgumentError('UID is empty — cannot load font scale');
    }

    // Local read
    final localValue = _prefs.getDouble(_prefsKey);
    if (localValue != null) return localValue;

    // Firestore read (now pointing to: users/{uid}/preferences/global)
    final doc = await _firestore.doc('users/$uid/preferences/global').get();

    final remoteValue = doc.data()?['font_scale'];
    if (remoteValue is num) {
      final scale = remoteValue.toDouble();
      await _prefs.setDouble(_prefsKey, scale);
      return scale;
    }

    return null;
  }

  @override
  Future<void> setFontScale(String uid, double scale) async {
    if (uid.isEmpty) {
      throw ArgumentError('UID is empty — cannot save font scale');
    }

    // Local write
    await _prefs.setDouble(_prefsKey, scale);

    // Firestore write
    await _firestore
        .doc('users/$uid/preferences/global')
        .set({'font_scale': scale}, SetOptions(merge: true));
  }
}

/// Async Singleton Provider for SharedPreferences.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main.dart using ProviderScope');
});

/// Provider for choosing mock or live persistence.
final fontScaleRepositoryProvider =
    Provider<AbstractFontScaleRepository>((ref) {
  if (useMockServices) {
    throw UnimplementedError('MockFontScaleRepository not yet implemented');
  }

  final prefs = ref.watch(sharedPreferencesProvider);
  final firestore = FirebaseFirestore.instance;

  return FirebaseFontScaleRepository(prefs, firestore);
});
