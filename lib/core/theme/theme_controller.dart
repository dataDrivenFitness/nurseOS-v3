import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nurseos_v3/core/providers/shared_prefs_provider.dart';
import 'package:nurseos_v3/features/preferences/data/display_preferences_repository.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';

/// 🔁 Theme controller using SharedPreferences + Firestore, works pre/post-auth.
final themeControllerProvider =
    AsyncNotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

class ThemeController extends AsyncNotifier<ThemeMode> {
  static const _prefsKey = 'dark_mode';

  SharedPreferences? _prefs; // Make nullable to prevent reinitialization
  DisplayPreferencesRepository? _repo;
  String _uid = '';

  @override
  Future<ThemeMode> build() async {
    // Only initialize if not already initialized
    _prefs ??= ref.read(sharedPreferencesProvider);
    _repo ??= ref.read(displayPreferencesRepositoryProvider);

    final auth = await ref.watch(authControllerProvider.future);
    _uid = auth?.uid ?? '';

    final local = _prefs!.getBool(_prefsKey);
    if (local != null) {
      return local ? ThemeMode.dark : ThemeMode.light;
    }

    final remote = await _repo!.getThemeMode(_uid);
    if (remote != null) {
      await _prefs!.setBool(_prefsKey, remote == ThemeMode.dark);
      return remote;
    }

    return ThemeMode.system;
  }

  Future<void> toggleTheme(bool isDark) {
    return updateThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> updateThemeMode(ThemeMode newMode) async {
    state = AsyncValue.data(newMode);
    await _prefs!.setBool(_prefsKey, newMode == ThemeMode.dark);

    if (_uid.isNotEmpty) {
      await _repo!.setThemeMode(_uid, newMode);
    }
  }
}

/// 🔁 Reactive dual-source theme stream, based on login state.
final themeModeStreamProvider = StreamProvider<ThemeMode>((ref) async* {
  final prefs = ref.read(sharedPreferencesProvider);
  final auth = await ref.watch(authControllerProvider.future);
  final uid = auth?.uid ?? '';

  if (uid.isEmpty) {
    final cached = prefs.getBool(ThemeController._prefsKey);
    if (cached == true) {
      yield ThemeMode.dark;
    } else if (cached == false) {
      yield ThemeMode.light;
    } else {
      yield ThemeMode.system;
    }
    return;
  }

  final repo = ref.watch(displayPreferencesRepositoryProvider);
  yield* repo.watchThemeMode(uid);
});
