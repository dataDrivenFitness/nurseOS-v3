// lib/core/providers/feature_flag_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// lib/core/providers/feature_flag_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple feature flag provider without code generation
///
/// Usage: ref.watch(featureFlagProvider('navigation_v3'))
final featureFlagProvider = Provider.family<bool, String>((ref, flagName) {
  // Simple map-based feature flags for development
  const flags = {
    'navigation_v3': true, // ✅ Re-enabled with proper routes
    'independent_nurse': true, // Independent nurse functionality
    'task_system': false, // Enhanced task management
    'shift_creation': true, // User-created shift workflows
    'patient_assignment': true, // Shift-based patient assignment
    'advanced_filtering': true, // Enhanced filtering options
    'real_time_updates': true, // Live data synchronization
    'shift_analytics': false, // Shift performance metrics
    'mobile_admin': true, // Mobile admin panel features
    'gamification_v2': false, // Enhanced gamification system
  };

  return flags[flagName] ?? false;
});

/// Provider for getting multiple feature flags at once
final multipleFeatureFlagsProvider =
    Provider.family<Map<String, bool>, List<String>>((ref, flagNames) {
  final result = <String, bool>{};
  for (final flagName in flagNames) {
    result[flagName] = ref.watch(featureFlagProvider(flagName));
  }
  return result;
});

/// Provider to check if any experimental features are enabled
final hasExperimentalFeaturesProvider = Provider<bool>((ref) {
  const experimentalFlags = [
    'task_system',
    'shift_analytics',
    'gamification_v2',
  ];

  return experimentalFlags.any((flag) => ref.watch(featureFlagProvider(flag)));
});

/// Provider to get list of enabled feature flags
final enabledFeatureFlagsProvider = Provider<List<String>>((ref) {
  const allFlags = [
    'navigation_v3',
    'independent_nurse',
    'task_system',
    'shift_creation',
    'patient_assignment',
    'advanced_filtering',
    'real_time_updates',
    'shift_analytics',
    'mobile_admin',
    'gamification_v2',
  ];

  return allFlags
      .where((flag) => ref.watch(featureFlagProvider(flag)))
      .toList();
});

/// Helper class for feature flag management in debug builds
class FeatureFlagDebugger {
  static void printEnabledFlags(WidgetRef ref) {
    final enabled = ref.read(enabledFeatureFlagsProvider);
    print('🎛️ Enabled Feature Flags: ${enabled.join(', ')}');
  }

  static void printExperimentalStatus(WidgetRef ref) {
    final hasExperimental = ref.read(hasExperimentalFeaturesProvider);
    print('🧪 Experimental Features Enabled: $hasExperimental');
  }
}
