// 📁 lib/features/schedule/state/upcoming_shifts_provider.dart
// ═══════════════════════════════════════════════════════════════════
// 📅 UPCOMING SHIFTS PROVIDER - V2 ARCHITECTURE REFACTOR
// ═══════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scheduled_shift_model.dart';
import '../../auth/state/auth_controller.dart';
import '../../profile/state/user_profile_controller.dart';

// ═══════════════════════════════════════════════════════════════════
// 🏭 REPOSITORY ABSTRACTION FOR UPCOMING SHIFTS
// ═══════════════════════════════════════════════════════════════════

abstract class AbstractUpcomingShiftsRepository {
  Stream<List<ScheduledShiftModel>> watchUpcomingShifts(String userId,
      {String? agencyId});
  Stream<List<ScheduledShiftModel>> watchShiftsNeedingConfirmation(
      String userId,
      {String? agencyId});
}

class FirebaseUpcomingShiftsRepository
    implements AbstractUpcomingShiftsRepository {
  final FirebaseFirestore _firestore;

  FirebaseUpcomingShiftsRepository(this._firestore);

  @override
  Stream<List<ScheduledShiftModel>> watchUpcomingShifts(String userId,
      {String? agencyId}) {
    Query<Map<String, dynamic>> query;

    // Use Collection Group to query across all shift locations
    query = _firestore
        .collectionGroup(
            'scheduledShifts') // ✅ Fixed: Use scheduledShifts not shifts
        .where('assignedTo', isEqualTo: userId)
        .where('status', whereIn: [
      'scheduled',
      'confirmed',
      'accepted'
    ]) // ✅ Fixed: Include 'scheduled'
        .orderBy('startTime');

    // Add agency filter if provided
    if (agencyId != null) {
      query = query.where('agencyId', isEqualTo: agencyId);
    }

    return query.snapshots().handleError((error, stackTrace) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        debugPrint('🔒 Upcoming shifts access denied, returning empty list');
        return <ScheduledShiftModel>[];
      }
      debugPrint('❌ Upcoming shifts error: $error');
      throw error;
    }).map((snapshot) {
      final shifts = snapshot.docs
          .map((doc) => _mapDocumentToModel(doc))
          .whereType<ScheduledShiftModel>()
          .toList();

      debugPrint(
          '🔍 UpcomingShifts: Loaded ${shifts.length} shifts for user $userId');
      return shifts;
    });
  }

  @override
  Stream<List<ScheduledShiftModel>> watchShiftsNeedingConfirmation(
      String userId,
      {String? agencyId}) {
    return watchUpcomingShifts(userId, agencyId: agencyId)
        .map((shifts) => shifts.where((shift) => !shift.isConfirmed).toList());
  }

  ScheduledShiftModel? _mapDocumentToModel(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final rawData = doc.data();
      final data = Map<String, dynamic>.from(rawData);

      // Set the document ID
      data['id'] = doc.id;

      // Extract agency ID from document path if not present in data
      if (data['agencyId'] == null) {
        final pathSegments = doc.reference.path.split('/');
        if (pathSegments.length >= 2 && pathSegments[0] == 'agencies') {
          data['agencyId'] = pathSegments[1];
        }
      }

      // Handle field mappings and defaults
      _handleFieldMappings(data);
      _validateRequiredFields(data, doc.id);

      if (kDebugMode) {
        debugPrint('🔧 Processing shift ${doc.id}:');
        debugPrint(
            '  - startTime: ${data['startTime']} (${data['startTime'].runtimeType})');
        debugPrint(
            '  - endTime: ${data['endTime']} (${data['endTime'].runtimeType})');
        debugPrint('  - locationType: ${data['locationType']}');
        debugPrint('  - status: ${data['status']}');
        debugPrint('  - isConfirmed: ${data['isConfirmed']}');
        debugPrint('  - agencyId: ${data['agencyId'] ?? "global"}');
      }

      return ScheduledShiftModel.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error parsing shift ${doc.id}: $e');
      return null;
    }
  }

  void _handleFieldMappings(Map<String, dynamic> data) {
    // Handle field name mismatch: 'location' -> 'locationType'
    if (data['location'] != null && data['locationType'] == null) {
      data['locationType'] = 'facility';
    }

    // Provide defaults for required fields that might be null
    data['locationType'] ??= 'other';
    data['isConfirmed'] ??= false;
    data['status'] ??= 'scheduled'; // ✅ Default to 'scheduled' for new shifts

    // Map the location name to facilityName if it exists
    if (data['location'] != null && data['facilityName'] == null) {
      data['facilityName'] = data['location'];
    }

    // Build address from components if not present
    if (data['address'] == null) {
      final addressParts = <String>[];
      if (data['addressLine1'] != null) addressParts.add(data['addressLine1']);
      if (data['city'] != null) addressParts.add(data['city']);
      if (data['state'] != null) addressParts.add(data['state']);
      if (data['zip'] != null) addressParts.add(data['zip']);

      if (addressParts.isNotEmpty) {
        data['address'] = addressParts.join(', ');
      }
    }
  }

  void _validateRequiredFields(Map<String, dynamic> data, String docId) {
    if (data['startTime'] == null) {
      throw ArgumentError('Missing startTime for shift $docId');
    }
    if (data['endTime'] == null) {
      throw ArgumentError('Missing endTime for shift $docId');
    }
    if (data['assignedTo'] == null) {
      throw ArgumentError('Missing assignedTo for shift $docId');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// 🎯 REPOSITORY PROVIDER
// ═══════════════════════════════════════════════════════════════════

final upcomingShiftsRepositoryProvider =
    Provider<AbstractUpcomingShiftsRepository>((ref) {
  return FirebaseUpcomingShiftsRepository(FirebaseFirestore.instance);
});

// ═══════════════════════════════════════════════════════════════════
// 🌊 MAIN UPCOMING SHIFTS PROVIDER
// ═══════════════════════════════════════════════════════════════════

final upcomingShiftsProvider =
    StreamProvider.family<List<ScheduledShiftModel>, String>((ref, userId) {
  final repository = ref.watch(upcomingShiftsRepositoryProvider);
  final authState = ref.watch(authControllerProvider);

  return authState.when(
    data: (user) {
      if (user == null || user.uid != userId) {
        debugPrint('🔍 UpcomingShifts: No authenticated user or user mismatch');
        return Stream.value(<ScheduledShiftModel>[]);
      }

      // Get user profile to determine agency context
      final userProfileAsync = ref.watch(userProfileStreamProvider);

      return userProfileAsync.when(
        data: (profile) {
          final activeAgencyId = profile?.activeAgencyId;

          // Validate user has access to the active agency
          if (activeAgencyId != null &&
              profile?.agencyRoles[activeAgencyId] == null) {
            debugPrint(
                '⚠️ UpcomingShifts: User $userId has activeAgencyId $activeAgencyId but no role assignment');
            return repository.watchUpcomingShifts(userId); // Fallback to global
          }

          debugPrint(
              '🔍 UpcomingShifts: Loading shifts for user $userId, agency: ${activeAgencyId ?? "global"}');
          return repository.watchUpcomingShifts(userId,
              agencyId: activeAgencyId);
        },
        loading: () {
          debugPrint(
              '🔍 UpcomingShifts: User profile loading, using global query');
          return repository.watchUpcomingShifts(userId); // No agency filter
        },
        error: (error, stack) {
          debugPrint(
              '❌ UpcomingShifts: Profile error, falling back to global: $error');
          return repository.watchUpcomingShifts(userId); // No agency filter
        },
      );
    },
    loading: () {
      debugPrint('🔍 UpcomingShifts: Auth loading');
      return Stream.value(<ScheduledShiftModel>[]);
    },
    error: (error, stack) {
      debugPrint('❌ UpcomingShifts: Auth error: $error');
      return Stream.value(<ScheduledShiftModel>[]);
    },
  );
});

// ═══════════════════════════════════════════════════════════════════
// 🔔 SHIFTS NEEDING CONFIRMATION PROVIDER
// ═══════════════════════════════════════════════════════════════════

final shiftsNeedingConfirmationProvider =
    StreamProvider.family<List<ScheduledShiftModel>, String>((ref, userId) {
  final repository = ref.watch(upcomingShiftsRepositoryProvider);
  final authState = ref.watch(authControllerProvider);

  return authState.when(
    data: (user) {
      if (user == null || user.uid != userId) {
        return Stream.value(<ScheduledShiftModel>[]);
      }

      final userProfileAsync = ref.watch(userProfileStreamProvider);

      return userProfileAsync.when(
        data: (profile) {
          final activeAgencyId = profile?.activeAgencyId;
          return repository.watchShiftsNeedingConfirmation(userId,
              agencyId: activeAgencyId);
        },
        loading: () => repository.watchShiftsNeedingConfirmation(userId),
        error: (error, stack) =>
            repository.watchShiftsNeedingConfirmation(userId),
      );
    },
    loading: () => Stream.value(<ScheduledShiftModel>[]),
    error: (error, stack) => Stream.value(<ScheduledShiftModel>[]),
  );
});

// ═══════════════════════════════════════════════════════════════════
// 🎯 AGENCY-SPECIFIC PROVIDERS (FOR SPECIFIC USE CASES)
// ═══════════════════════════════════════════════════════════════════

final agencyUpcomingShiftsProvider = StreamProvider.family<
    List<ScheduledShiftModel>,
    ({String agencyId, String userId})>((ref, params) {
  final repository = ref.watch(upcomingShiftsRepositoryProvider);
  return repository.watchUpcomingShifts(params.userId,
      agencyId: params.agencyId);
});

// ═══════════════════════════════════════════════════════════════════
// 📊 CONVENIENCE PROVIDERS
// ═══════════════════════════════════════════════════════════════════

final todaysShiftsProvider =
    StreamProvider.family<List<ScheduledShiftModel>, String>((ref, userId) {
  final upcomingShiftsAsync = ref.watch(upcomingShiftsProvider(userId));

  return upcomingShiftsAsync.when(
    data: (shifts) {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final todaysShifts = shifts.where((shift) {
        return shift.startTime.isAfter(startOfDay) &&
            shift.startTime.isBefore(endOfDay);
      }).toList();

      return Stream.value(todaysShifts);
    },
    loading: () => Stream.value(<ScheduledShiftModel>[]),
    error: (error, stack) => Stream.value(<ScheduledShiftModel>[]),
  );
});

final thisWeekShiftsProvider =
    StreamProvider.family<List<ScheduledShiftModel>, String>((ref, userId) {
  final upcomingShiftsAsync = ref.watch(upcomingShiftsProvider(userId));

  return upcomingShiftsAsync.when(
    data: (shifts) {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      final weekShifts = shifts.where((shift) {
        return shift.startTime.isAfter(startOfWeek) &&
            shift.startTime.isBefore(endOfWeek);
      }).toList();

      return Stream.value(weekShifts);
    },
    loading: () => Stream.value(<ScheduledShiftModel>[]),
    error: (error, stack) => Stream.value(<ScheduledShiftModel>[]),
  );
});
