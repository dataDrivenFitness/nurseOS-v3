import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

/// Drives `MaterialApp.themeMode` across NurseOS.
///
/// ⚠️ Persistence stub:
///   • In `build()` we’ll soon hydrate the saved value from
///     `DisplayPreferencesRepository`.

@Riverpod(keepAlive: true) // global state survives route changes
class ThemeController extends _$ThemeController {
  /// Initial theme — will switch to a saved user preference once we hydrate.
  @override
  ThemeMode build() => ThemeMode.system;

  /// Switches between light/dark directly from a UI toggle.
  ///
  /// • [isDark] comes straight from a `Switch`’s `onChanged` callback.
  /// • We intentionally ignore ThemeMode.system here; the “system” option
  ///   will live on its own row in Settings later if product wants it.
  void toggleTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;

    // TODO: await ref
    //   .read(displayPreferencesRepoProvider)
    //   .saveThemeMode(state);
  }

  /// Helper for UIs that need a simple boolean.
  bool get isDark => state == ThemeMode.dark;
}
