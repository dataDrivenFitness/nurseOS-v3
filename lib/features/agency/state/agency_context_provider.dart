// 📁 lib/features/agency/state/agency_context_provider.dart
// REFACTORED: Shift-centric architecture - derives agency relationships from shifts

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/agency_model.dart';
import '../../auth/state/auth_controller.dart';

/// Manages agency context by deriving relationships from scheduled shifts
/// This replaces the old bidirectional user-agency relationship model
class AgencyContextNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    // For shift-centric architecture, there's no single "active" agency
    // Instead, context is determined by current shift or user preference
    return null;
  }

  /// Set preferred agency for UI context (stored locally, not in user model)
  Future<void> setPreferredAgency(String agencyId) async {
    try {
      // Update local state for UI context
      state = AsyncData(agencyId);
      debugPrint('✅ Set preferred agency context: $agencyId');
    } catch (e) {
      debugPrint('❌ Failed to set preferred agency: $e');
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// Clear preferred agency context
  Future<void> clearPreferredAgency() async {
    try {
      state = const AsyncData(null);
      debugPrint('✅ Cleared preferred agency context');
    } catch (e) {
      debugPrint('❌ Failed to clear preferred agency: $e');
      state = AsyncError(e, StackTrace.current);
    }
  }
}

/// Main provider for agency context (UI preference only)
final agencyContextNotifierProvider =
    AsyncNotifierProvider<AgencyContextNotifier, String?>(
  () => AgencyContextNotifier(),
);

/// Convenience provider for current preferred agency ID
final currentAgencyIdProvider = Provider<String?>((ref) {
  final asyncAgency = ref.watch(agencyContextNotifierProvider);

  return asyncAgency.when(
    data: (agencyId) => agencyId,
    loading: () => null,
    error: (error, stackTrace) {
      debugPrint('❌ Agency context error: $error');
      return null;
    },
  );
});

/// Provider that finds agencies where user is a member (agency-controlled access)
final userAgenciesFromMembershipProvider =
    FutureProvider<List<String>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return [];

  try {
    // Query agencies that include this user in their nurseIds list
    final agenciesQuery = await FirebaseFirestore.instance
        .collection('agencies')
        .where('nurseIds', arrayContains: user.uid)
        .where('isActive', isEqualTo: true)
        .get();

    // Extract agency IDs
    final agencyIds = agenciesQuery.docs.map((doc) => doc.id).toList();

    debugPrint(
        '🔍 Found ${agencyIds.length} agencies where user is member: $agencyIds');
    return agencyIds;
  } catch (e) {
    debugPrint('❌ Failed to fetch user agencies from membership: $e');
    return [];
  }
});

/// Provider for current agency details (if preferred agency is set)
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

/// Provider for user's available agencies (agency-controlled membership)
final userAgenciesProvider = FutureProvider<List<AgencyModel>>((ref) async {
  final agencyIds = await ref.watch(userAgenciesFromMembershipProvider.future);
  if (agencyIds.isEmpty) return [];

  try {
    final agencies = <AgencyModel>[];

    // Fetch agency details for each ID where user is a member
    for (final agencyId in agencyIds) {
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

/// Provider for checking if user has multiple agencies (based on membership)
final hasMultipleAgenciesProvider = Provider<bool>((ref) {
  final agenciesAsync = ref.watch(userAgenciesFromMembershipProvider);
  return agenciesAsync.when(
    data: (agencies) => agencies.length > 1,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for checking if user can access admin features
/// Since we removed agency roles, this now checks the user's base role
final canAccessAdminDashboardProvider = Provider<bool>((ref) {
  final user = ref.watch(authControllerProvider).value;
  // For now, only admin users can access admin features
  // TODO: Implement agency-specific admin roles through a different mechanism
  return user?.role.name == 'admin';
});

/// Provider for checking if user can manage users
final canManageUsersProvider = Provider<bool>((ref) {
  final user = ref.watch(authControllerProvider).value;
  return user?.role.name == 'admin';
});

/// Provider for checking if user can schedule shifts
final canScheduleShiftsProvider = Provider<bool>((ref) {
  final user = ref.watch(authControllerProvider).value;
  return user?.role.name == 'admin';
});

/// Provider to check if user needs agency selection
final needsAgencySelectionProvider = Provider<bool>((ref) {
  final hasMultiple = ref.watch(hasMultipleAgenciesProvider);
  final currentAgency = ref.watch(currentAgencyIdProvider);

  // User needs to select if they have multiple agencies but no preference set
  return hasMultiple && currentAgency == null;
});

/// Provider for agency switching capability
final canSwitchAgencyProvider = Provider<bool>((ref) {
  return ref.watch(hasMultipleAgenciesProvider);
});

/// Extension methods for easier agency context usage
extension AgencyContextRef on WidgetRef {
  /// Get current preferred agency ID
  String? get currentAgencyId => watch(currentAgencyIdProvider);

  /// Check if user needs to select agency
  bool get needsAgencySelection => watch(needsAgencySelectionProvider);

  /// Check if user can access admin features
  bool get canAccessAdmin => watch(canAccessAdminDashboardProvider);

  /// Set preferred agency for UI context
  Future<void> setPreferredAgency(String agencyId) async {
    await read(agencyContextNotifierProvider.notifier)
        .setPreferredAgency(agencyId);
  }

  /// Clear preferred agency
  Future<void> clearPreferredAgency() async {
    await read(agencyContextNotifierProvider.notifier).clearPreferredAgency();
  }
}
