// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeControllerHash() => r'36d8dd692bb456af3afa18b6066b88d205c21388';

/// Controls app-wide dark/light theme, persisted locally and to Firestore.
///
/// Stores the value at:
/// 🔹 SharedPreferences: 'dark_mode'
/// 🔸 Firestore: users/{uid}/preferences → { darkMode: true }
///
/// Copied from [ThemeController].
@ProviderFor(ThemeController)
final themeControllerProvider =
    AsyncNotifierProvider<ThemeController, ThemeMode>.internal(
  ThemeController.new,
  name: r'themeControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeController = AsyncNotifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
