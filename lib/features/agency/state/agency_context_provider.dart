// 📁 lib/features/agency/state/agency_context_provider.dart
// FIXED: Proper async handling for agency context

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nurseos_v3/features/agency/models/agency_role_model.dart';
import 'package:nurseos_v3/features/auth/models/user_model_extensions.dart';
import '../models/agency_model.dart';
import '../../auth/state/auth_controller.dart';
import '../../auth/models/user_model.dart';

/// Manages the current agency context for the authenticated user
/// This is the single source of truth for which agency is currently active
class AgencyContextNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    // Watch the auth state to get current user
    final user = ref.watch(authControllerProvider).value;

    // Return the user's active agency ID
    return user?.activeAgencyId;
  }

  /// Switch to a different agency (with validation)
  Future<void> switchAgency(String agencyId) async {
    try {
      final user = ref.read(authControllerProvider).value;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Validate user has access to this agency
      if (!user.hasAccessToAgency(agencyId)) {
        throw Exception('User does not have access to agency: $agencyId');
      }

      // Update user's active agency in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'activeAgencyId': agencyId});

      // Update local state immediately for better UX
      state = AsyncData(agencyId);

      // Refresh auth controller to pick up the change
      ref.invalidate(authControllerProvider);

      debugPrint('✅ Switched to agency: $agencyId');
    } catch (e) {
      debugPrint('❌ Failed to switch agency: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Clear active agency (for sign out or agency removal)
  Future<void> clearAgency() async {
    try {
      final user = ref.read(authControllerProvider).value;
      if (user == null) return;

      // Clear active agency in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'activeAgencyId': null});

      // Update local state
      state = const AsyncData(null);

      // Refresh auth controller
      ref.invalidate(authControllerProvider);

      debugPrint('✅ Cleared active agency');
    } catch (e) {
      debugPrint('❌ Failed to clear agency: $e');
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// Set agency for first-time users or after migration
  Future<void> setInitialAgency(String agencyId) async {
    try {
      final user = ref.read(authControllerProvider).value;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // For initial setup, we're less strict about validation
      // (useful during migration when agencyRoles might not be set yet)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'activeAgencyId': agencyId});

      state = AsyncData(agencyId);
      ref.invalidate(authControllerProvider);

      debugPrint('✅ Set initial agency: $agencyId');
    } catch (e) {
      debugPrint('❌ Failed to set initial agency: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
}

/// Main provider for agency context
final agencyContextNotifierProvider =
    AsyncNotifierProvider<AgencyContextNotifier, String?>(
  () => AgencyContextNotifier(),
);

/// 🔧 FIXED: Convenience provider for current agency ID with proper async handling
final currentAgencyIdProvider = Provider<String?>((ref) {
  final asyncAgency = ref.watch(agencyContextNotifierProvider);

  // Handle async states properly
  return asyncAgency.when(
    data: (agencyId) => agencyId,
    loading: () {
      // During loading, try to get from user's activeAgencyId directly
      final user = ref.watch(authControllerProvider).value;
      final directAgencyId = user?.activeAgencyId;

      if (directAgencyId != null) {
        debugPrint(
            '🔄 Agency loading - using direct user.activeAgencyId: $directAgencyId');
        return directAgencyId;
      }

      debugPrint('🔄 Agency loading - no direct agency available');
      return null;
    },
    error: (error, stackTrace) {
      debugPrint('❌ Agency context error: $error');
      // Fallback to user's activeAgencyId on error
      final user = ref.watch(authControllerProvider).value;
      return user?.activeAgencyId;
    },
  );
});

/// Provider for current agency details
final currentAgencyProvider = FutureProvider<AgencyModel?>((ref) async {
  final agencyId = ref.watch(currentAgencyIdProvider);
  if (agencyId == null) return null;

  try {
    final doc = await FirebaseFirestore.instance
        .collection('agencies')
        .doc(agencyId)
        .withConverter<AgencyModel>(
          fromFirestore: (snap, _) =>
              AgencyModel.fromJson(snap.data()!..['id'] = snap.id),
          toFirestore: (agency, _) => agency.toJson(),
        )
        .get();

    return doc.exists ? doc.data() : null;
  } catch (e) {
    debugPrint('❌ Failed to fetch agency $agencyId: $e');
    return null;
  }
});

/// Provider for user's available agencies
final userAgenciesProvider = FutureProvider<List<AgencyModel>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null || !user.hasMultipleAgencies) return [];

  try {
    final agencies = <AgencyModel>[];

    // Fetch all agencies user has access to
    for (final agencyId in user.accessibleAgencies) {
      final doc = await FirebaseFirestore.instance
          .collection('agencies')
          .doc(agencyId)
          .withConverter<AgencyModel>(
            fromFirestore: (snap, _) =>
                AgencyModel.fromJson(snap.data()!..['id'] = snap.id),
            toFirestore: (agency, _) => agency.toJson(),
          )
          .get();

      if (doc.exists && doc.data()!.isActive) {
        agencies.add(doc.data()!);
      }
    }

    // Sort by name for consistent UI
    agencies.sort((a, b) => a.name.compareTo(b.name));

    return agencies;
  } catch (e) {
    debugPrint('❌ Failed to fetch user agencies: $e');
    return [];
  }
});

/// Provider for current user's role in current agency
final currentAgencyRoleProvider = Provider((ref) {
  final user = ref.watch(authControllerProvider).value;
  final agencyId = ref.watch(currentAgencyIdProvider);

  if (user == null || agencyId == null) return null;

  return user.getRoleAtAgency(agencyId);
});

/// Provider for checking if user can access admin features in current agency
final canAccessAdminDashboardProvider = Provider<bool>((ref) {
  final role = ref.watch(currentAgencyRoleProvider);
  return role?.canAccessAdminDashboard ?? false;
});

/// Provider for checking if user can manage users in current agency
final canManageUsersProvider = Provider<bool>((ref) {
  final role = ref.watch(currentAgencyRoleProvider);
  return role?.canManageUsers ?? false;
});

/// Provider for checking if user can schedule shifts in current agency
final canScheduleShiftsProvider = Provider<bool>((ref) {
  final role = ref.watch(currentAgencyRoleProvider);
  return role?.canScheduleShifts ?? false;
});

/// Provider to check if user needs agency selection
final needsAgencySelectionProvider = Provider<bool>((ref) {
  final user = ref.watch(authControllerProvider).value;
  return user?.needsAgencySelection ?? false;
});

/// Provider for agency switching capability
final canSwitchAgencyProvider = Provider<bool>((ref) {
  final user = ref.watch(authControllerProvider).value;
  return user?.hasMultipleAgencies ?? false;
});

/// Extension methods for easier agency context usage
extension AgencyContextRef on WidgetRef {
  /// Get current agency ID
  String? get currentAgencyId => watch(currentAgencyIdProvider);

  /// Get current agency role
  AgencyRoleModel? get currentAgencyRole => watch(currentAgencyRoleProvider);

  /// Check if user needs to select agency
  bool get needsAgencySelection => watch(needsAgencySelectionProvider);

  /// Check if user can access admin features
  bool get canAccessAdmin => watch(canAccessAdminDashboardProvider);

  /// Switch to different agency
  Future<void> switchAgency(String agencyId) async {
    await read(agencyContextNotifierProvider.notifier).switchAgency(agencyId);
  }

  /// Clear active agency
  Future<void> clearAgency() async {
    await read(agencyContextNotifierProvider.notifier).clearAgency();
  }
}
