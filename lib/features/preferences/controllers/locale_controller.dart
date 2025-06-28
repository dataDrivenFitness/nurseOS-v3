// 📁 lib/features/preferences/controllers/locale_controller.dart
import 'dart:developer' as dev;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/providers/shared_prefs_provider.dart'; // ✅
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/state/auth_controller.dart';
import '../data/locale_repository.dart';

class LocaleController extends AsyncNotifier<Locale> {
  late final SharedPreferences _prefs = ref.read(sharedPreferencesProvider);
  AbstractLocaleRepository? _repo; // built lazily once we have uid
  String? _uid;

  // ──────────────────────────────────────────────────────────────
  // 1️⃣  Build immediately from local cache (fast boot, no Auth needed)
  // 2️⃣  THEN (async) fetch uid and remote repo; if remote disagrees,
  //     update state a second time.
  // ──────────────────────────────────────────────────────────────
  @override
  Future<Locale> build() async {
    // Fast path — local cache
    final cachedCode = _prefs.getString('app_locale');
    final initialLocale =
        cachedCode != null ? Locale(cachedCode) : const Locale('en');

    // Kick off async auth + remote check without blocking UI
    _warmUpRemote(initialLocale);

    return initialLocale;
  }

  /* ------------------------------------------------------------
     Warm-up helper: resolve uid, repo and, if necessary, refresh
     the locale from Firestore. Runs once in background.
  ------------------------------------------------------------- */
  Future<void> _warmUpRemote(Locale current) async {
    if (_uid != null) return; // already warmed
    _uid = (await ref.read(authControllerProvider.future))?.uid ?? '';

    // If still no uid we’re done (guest session)
    if (_uid!.isEmpty) return;

    _repo ??= ref.read(localeRepositoryProvider);

    final remote = await _repo!.getLocale(_uid!); // may return null
    if (remote != null && remote != current) {
      // Push remote value to state & overwrite local cache
      state = AsyncValue.data(remote);
    }
  }

  /* ------------------------------------------------------------
     User selected a new language
  ------------------------------------------------------------- */
  Future<void> updateLocale(Locale locale) async {
    // 1.  Optimistic UI update
    state = AsyncValue.data(locale);
    await _prefs.setString('app_locale', locale.languageCode);

    // 2.  Persist remotely if we have a uid
    _uid ??= (await ref.read(authControllerProvider.future))?.uid ?? '';

    if (_uid!.isEmpty) return; // guest session

    _repo ??= ref.read(localeRepositoryProvider);
    try {
      await _repo!.setLocale(_uid!, locale);
      dev.log('🌐 locale saved = ${locale.languageCode}');
    } catch (e, st) {
      dev.log('❌ locale save failed', error: e, stackTrace: st);
      state = AsyncValue.error(e, st); // surface to UI
    }
  }
}

final localeControllerProvider =
    AsyncNotifierProvider<LocaleController, Locale>(LocaleController.new);
