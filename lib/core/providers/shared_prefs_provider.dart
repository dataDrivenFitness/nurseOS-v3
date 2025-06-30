import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global singleton provider for [SharedPreferences].
/// Every repository must import THIS file, never redefine the provider.
/// Override in main.dart using ProviderScope.overrides.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // 🛑 This will still throw unless properly overridden in main.dart.
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in main.dart');
});
