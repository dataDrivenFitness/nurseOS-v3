// 📁 lib/features/preferences/controllers/locale_controller.dart
import 'dart:developer' as dev;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart'; // 🆕
import 'package:nurseos_v3/core/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/state/auth_controller.dart';
import '../data/locale_repository.dart';

part 'locale_controller.g.dart';

/*──────────────────────────────────────────────────────────────
   1️⃣  Read-once + write controller (unchanged)
──────────────────────────────────────────────────────────────*/
class LocaleController extends AsyncNotifier<Locale> {
  late final SharedPreferences _prefs = ref.read(sharedPreferencesProvider);
  AbstractLocaleRepository? _repo;
  String? _uid;

  @override
  Future<Locale> build() async {
    final cached = _prefs.getString('app_locale');
    final initial = cached != null ? Locale(cached) : const Locale('en');
    _warmUpRemote(initial);
    return initial;
  }

  Future<void> _warmUpRemote(Locale current) async {
    if (_uid != null) return;
    _uid = (await ref.read(authControllerProvider.future))?.uid ?? '';
    if (_uid!.isEmpty) return;

    _repo ??= ref.read(localeRepositoryProvider);
    final remote = await _repo!.getLocale(_uid!);
    if (remote != null && remote != current) {
      state = AsyncValue.data(remote);
    }
  }

  Future<void> updateLocale(Locale locale) async {
    state = AsyncValue.data(locale);
    await _prefs.setString('app_locale', locale.languageCode);

    _uid ??= (await ref.read(authControllerProvider.future))?.uid ?? '';
    if (_uid!.isEmpty) return;

    _repo ??= ref.read(localeRepositoryProvider);
    try {
      await _repo!.setLocale(_uid!, locale);
      dev.log('🌐 locale saved = ${locale.languageCode}');
    } catch (e, st) {
      dev.log('❌ locale save failed', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}

final localeControllerProvider =
    AsyncNotifierProvider<LocaleController, Locale>(LocaleController.new);

/*──────────────────────────────────────────────────────────────
   2️⃣  Live Firestore stream provider
──────────────────────────────────────────────────────────────*/
@Riverpod(keepAlive: true)
Stream<Locale> localeStream(LocaleStreamRef ref) async* {
  final auth = await ref.watch(authControllerProvider.future);
  final uid = auth?.uid ?? '';

  if (uid.isEmpty) {
    yield const Locale('en');
    return;
  }

  final repo = ref.watch(localeRepositoryProvider);

  // Emit cached value first (fast paint)
  final cached = await repo.getLocale(uid);
  yield cached ?? const Locale('en');

  // Then forward live Firestore updates
  await for (final loc in repo.watchLocale(uid)) {
    yield loc;
  }
}
