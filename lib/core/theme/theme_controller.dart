import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nurseos_v3/core/providers/shared_prefs_provider.dart';
import 'package:nurseos_v3/features/preferences/data/display_preferences_repository.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';

part 'theme_controller.g.dart';

@Riverpod(keepAlive: true)
class ThemeController extends AsyncNotifier<ThemeMode> {
  static const _prefsKey = 'dark_mode';

  late final SharedPreferences _prefs;
  late final DisplayPreferencesRepository _repo;
  late final String _uid;

  @override
  Future<ThemeMode> build() async {
    _prefs = ref.read(sharedPreferencesProvider);
    _repo = ref.read(displayPreferencesRepositoryProvider);
    final auth = await ref.watch(authControllerProvider.future);
    _uid = auth?.uid ?? '';

    // Local load
    final local = _prefs.getBool(_prefsKey);
    if (local != null) return local ? ThemeMode.dark : ThemeMode.light;

    // Firestore fallback
    final remote = await _repo.getThemeMode(_uid);
    if (remote != null) {
      await _prefs.setBool(_prefsKey, remote == ThemeMode.dark);
      return remote;
    }

    return ThemeMode.system;
  }

  /// 🔁 Used by ProfileScreen toggle
  Future<void> toggleTheme(bool isDark) {
    return updateThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  /// ✅ Public method for explicit setting (testable)
  Future<void> updateThemeMode(ThemeMode newMode) async {
    state = AsyncValue.data(newMode);
    await _prefs.setBool(_prefsKey, newMode == ThemeMode.dark);
    if (_uid.isNotEmpty) {
      await _repo.setThemeMode(_uid, newMode);
    }
  }
}

@Riverpod(keepAlive: true)
Stream<ThemeMode> themeModeStream(ThemeModeStreamRef ref) async* {
  final auth = await ref.watch(authControllerProvider.future);
  final uid = auth?.uid ?? '';

  if (uid.isEmpty) {
    yield ThemeMode.system;
    return;
  }

  final repo = ref.watch(displayPreferencesRepositoryProvider);
  await for (final mode in repo.watchThemeMode(uid)) {
    yield mode;
  }
}
