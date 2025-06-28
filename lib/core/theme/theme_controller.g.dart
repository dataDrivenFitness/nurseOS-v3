// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeModeStreamHash() => r'bbce163685dddc1256a3cbcbc4423ced14a22072';

/// See also [themeModeStream].
@ProviderFor(themeModeStream)
final themeModeStreamProvider = StreamProvider<ThemeMode>.internal(
  themeModeStream,
  name: r'themeModeStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeModeStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ThemeModeStreamRef = StreamProviderRef<ThemeMode>;
String _$themeControllerHash() => r'd88f91df4a2369df6bb141eed16c90ce84dda9a6';

/// See also [ThemeController].
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
