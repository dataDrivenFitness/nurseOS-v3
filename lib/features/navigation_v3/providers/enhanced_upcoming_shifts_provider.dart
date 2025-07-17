// lib/features/navigation_v3/providers/enhanced_upcoming_shifts_provider.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model_extensions.dart';

/// Enhanced upcoming shifts provider that supports both agency and independent nurses
/// This is the new v3 provider that will replace the legacy upcoming shifts system
final enhancedUpcomingShiftsProvider =
    StreamProvider<List<ScheduledShiftModel>>((ref) {
  final authState = ref.watch(authControllerProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);

      debugPrint('🔍 Enhanced Upcoming Shifts: Loading for user ${user.uid}');

      // Query both agency and independent shifts
      return _getUnifiedUpcomingShifts(user.uid, user.isIndependentNurse);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Filtered upcoming shifts by agency context
final filteredUpcomingShiftsProvider =
    StreamProvider.family<List<ScheduledShiftModel>, ShiftFilter>(
  (ref, filter) {
    final allShiftsAsync = ref.watch(enhancedUpcomingShiftsProvider);

    return allShiftsAsync.when(
      data: (shifts) {
        var filteredShifts = shifts;

        // Apply agency filter
        if (filter.agencyId != null) {
          if (filter.agencyId == 'independent') {
            filteredShifts =
                shifts.where((shift) => shift.agencyId == null).toList();
          } else {
            filteredShifts = shifts
                .where((shift) => shift.agencyId == filter.agencyId)
                .toList();
          }
        }

        // Apply status filter
        if (filter.status != null) {
          switch (filter.status!) {
            case ShiftStatusFilter.confirmed:
              filteredShifts =
                  filteredShifts.where((shift) => shift.isConfirmed).toList();
              break;
            case ShiftStatusFilter.pending:
              filteredShifts =
                  filteredShifts.where((shift) => !shift.isConfirmed).toList();
              break;
            case ShiftStatusFilter.all:
              // No additional filtering
              break;
          }
        }

        // Apply date range filter
        if (filter.startDate != null && filter.endDate != null) {
          filteredShifts = filteredShifts
              .where((shift) =>
                  shift.startTime.isAfter(filter.startDate!) &&
                  shift.startTime.isBefore(filter.endDate!))
              .toList();
        }

        // Sort by start time
        filteredShifts.sort((a, b) => a.startTime.compareTo(b.startTime));

        return Stream.value(filteredShifts);
      },
      loading: () => Stream.value([]),
      error: (_, __) => Stream.value([]),
    );
  },
);

/// Grouped upcoming shifts by time periods
final groupedUpcomingShiftsProvider =
    Provider<AsyncValue<GroupedShifts>>((ref) {
  final shiftsAsync = ref.watch(enhancedUpcomingShiftsProvider);

  return shiftsAsync.when(
    data: (shifts) {
      final grouped = _groupShiftsByTimePeriod(shifts);
      return AsyncValue.data(grouped);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for shift creation capabilities - FIXED: Get agencies from shifts
final shiftCreationCapabilitiesProvider =
    Provider<ShiftCreationCapabilities>((ref) {
  final user = ref.watch(authControllerProvider).value;
  final shiftsAsync = ref.watch(enhancedUpcomingShiftsProvider);

  // Get available agencies from user's shifts
  final availableAgencies = shiftsAsync.when(
    data: (shifts) {
      final agencies = shifts
          .where((shift) => shift.agencyId != null)
          .map((shift) => shift.agencyId!)
          .toSet()
          .toList();
      return agencies;
    },
    loading: () => <String>[],
    error: (_, __) => <String>[],
  );

  return ShiftCreationCapabilities(
    canCreateIndependentShifts: user?.isIndependentNurse == true,
    canRequestAgencyShifts: true, // All nurses can request agency shifts
    availableAgencies: availableAgencies,
  );
});

/// Get unified upcoming shifts from both agency and independent collections
Stream<List<ScheduledShiftModel>> _getUnifiedUpcomingShifts(
    String userId, bool isIndependentNurse) {
  final now = DateTime.now();
  final nowTimestamp = Timestamp.fromDate(now);

  try {
    // Stream for agency shifts
    final agencyShiftsStream = FirebaseFirestore.instance
        .collectionGroup('scheduledShifts')
        .where('assignedTo', isEqualTo: userId)
        .where('startTime', isGreaterThan: nowTimestamp)
        .orderBy('startTime')
        .snapshots()
        .handleError((error) {
      debugPrint('❌ Agency shifts error: $error');
      return const Stream.empty();
    });

    // Stream for independent shifts (only if user is independent nurse)
    if (!isIndependentNurse) {
      // If not independent nurse, just return agency shifts
      return agencyShiftsStream.map((agencySnapshot) {
        final shifts = <ScheduledShiftModel>[];

        for (final doc in agencySnapshot.docs) {
          final shift = _parseShiftDocument(doc, isIndependent: false);
          if (shift != null) shifts.add(shift);
        }

        shifts.sort((a, b) => a.startTime.compareTo(b.startTime));

        debugPrint(
            '✅ Enhanced Upcoming Shifts: Found ${shifts.length} agency shifts for user $userId');
        return shifts;
      });
    }

    // For independent nurses, combine both streams
    final independentShiftsStream = FirebaseFirestore.instance
        .collection('independentShifts')
        .where('assignedTo', isEqualTo: userId)
        .where('startTime', isGreaterThan: nowTimestamp)
        .orderBy('startTime')
        .snapshots()
        .handleError((error) {
      debugPrint('❌ Independent shifts error: $error');
      return const Stream.empty();
    });

    // For independent nurses, combine both streams using StreamController
    return _combineStreamsWithController(
        agencyShiftsStream, independentShiftsStream, userId);
  } catch (e) {
    debugPrint('❌ Error in _getUnifiedUpcomingShifts: $e');
    return Stream.value([]);
  }
}

/// Combine streams using StreamController for better compatibility
Stream<List<ScheduledShiftModel>> _combineStreamsWithController(
  Stream<QuerySnapshot<Map<String, dynamic>>> agencyStream,
  Stream<QuerySnapshot<Map<String, dynamic>>> independentStream,
  String userId,
) {
  late StreamController<List<ScheduledShiftModel>> controller;

  QuerySnapshot<Map<String, dynamic>>? latestAgency;
  QuerySnapshot<Map<String, dynamic>>? latestIndependent;
  bool agencyInitialized = false;
  bool independentInitialized = false;

  void emitCombined() {
    if (!agencyInitialized || !independentInitialized) return;

    final allShifts = <ScheduledShiftModel>[];

    // Process agency shifts
    if (latestAgency != null) {
      for (final doc in latestAgency!.docs) {
        final shift = _parseShiftDocument(doc, isIndependent: false);
        if (shift != null) allShifts.add(shift);
      }
    }

    // Process independent shifts
    if (latestIndependent != null) {
      for (final doc in latestIndependent!.docs) {
        final shift = _parseShiftDocument(doc, isIndependent: true);
        if (shift != null) allShifts.add(shift);
      }
    }

    // Sort by start time
    allShifts.sort((a, b) => a.startTime.compareTo(b.startTime));

    final agencyCount = latestAgency?.docs.length ?? 0;
    final independentCount = latestIndependent?.docs.length ?? 0;
    debugPrint(
        '✅ Enhanced Upcoming Shifts: Found ${allShifts.length} total shifts ($agencyCount agency, $independentCount independent)');

    if (!controller.isClosed) {
      controller.add(allShifts);
    }
  }

  controller = StreamController<List<ScheduledShiftModel>>(
    onListen: () {
      // Listen to agency shifts
      agencyStream.listen(
        (snapshot) {
          latestAgency = snapshot;
          agencyInitialized = true;
          emitCombined();
        },
        onError: (error) {
          debugPrint('❌ Agency stream error: $error');
          if (!controller.isClosed) {
            controller.addError(error);
          }
        },
      );

      // Listen to independent shifts
      independentStream.listen(
        (snapshot) {
          latestIndependent = snapshot;
          independentInitialized = true;
          emitCombined();
        },
        onError: (error) {
          debugPrint('❌ Independent stream error: $error');
          if (!controller.isClosed) {
            controller.addError(error);
          }
        },
      );
    },
    onCancel: () {
      // Cleanup handled by Firestore listeners automatically
    },
  );

  return controller.stream;
}

/// Parse shift document with proper field handling
ScheduledShiftModel? _parseShiftDocument(
  QueryDocumentSnapshot<Map<String, dynamic>> doc, {
  required bool isIndependent,
}) {
  try {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = doc.id;

    // Set agency context
    if (isIndependent) {
      data['agencyId'] = null;
      data['isUserCreated'] = true;
    } else {
      // Extract agency ID from document path for agency shifts
      final pathSegments = doc.reference.path.split('/');
      if (pathSegments.length >= 2 && pathSegments[0] == 'agencies') {
        data['agencyId'] = pathSegments[1];
      }
      data['isUserCreated'] = data['isUserCreated'] ?? false;
    }

    // Ensure required fields have defaults
    data['locationType'] ??= 'other';
    data['isConfirmed'] ??= false;
    data['status'] ??= 'scheduled';
    data['assignedPatientIds'] ??= <String>[];

    return ScheduledShiftModel.fromJson(data);
  } catch (e) {
    debugPrint('❌ Error parsing shift ${doc.id}: $e');
    return null;
  }
}

/// Group shifts by time periods for better UX
GroupedShifts _groupShiftsByTimePeriod(List<ScheduledShiftModel> shifts) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final nextWeek = today.add(const Duration(days: 7));

  final grouped = GroupedShifts();

  for (final shift in shifts) {
    final shiftDate = DateTime(
      shift.startTime.year,
      shift.startTime.month,
      shift.startTime.day,
    );

    if (shiftDate.isAtSameMomentAs(today)) {
      grouped.today.add(shift);
    } else if (shiftDate.isAtSameMomentAs(tomorrow)) {
      grouped.tomorrow.add(shift);
    } else if (shift.startTime.isBefore(nextWeek)) {
      grouped.thisWeek.add(shift);
    } else {
      grouped.later.add(shift);
    }
  }

  return grouped;
}

/// Data classes for shift filtering and grouping

class ShiftFilter {
  final String?
      agencyId; // null = all, 'independent' = independent only, agencyId = specific agency
  final ShiftStatusFilter? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const ShiftFilter({
    this.agencyId,
    this.status,
    this.startDate,
    this.endDate,
  });

  ShiftFilter copyWith({
    String? agencyId,
    ShiftStatusFilter? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ShiftFilter(
      agencyId: agencyId ?? this.agencyId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShiftFilter &&
        other.agencyId == agencyId &&
        other.status == status &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(agencyId, status, startDate, endDate);
}

enum ShiftStatusFilter { all, confirmed, pending }

class GroupedShifts {
  final List<ScheduledShiftModel> today = [];
  final List<ScheduledShiftModel> tomorrow = [];
  final List<ScheduledShiftModel> thisWeek = [];
  final List<ScheduledShiftModel> later = [];

  int get totalShifts =>
      today.length + tomorrow.length + thisWeek.length + later.length;
  bool get isEmpty => totalShifts == 0;
  bool get hasToday => today.isNotEmpty;
  bool get hasTomorrow => tomorrow.isNotEmpty;
  bool get hasThisWeek => thisWeek.isNotEmpty;
  bool get hasLater => later.isNotEmpty;
}

class ShiftCreationCapabilities {
  final bool canCreateIndependentShifts;
  final bool canRequestAgencyShifts;
  final List<String> availableAgencies;

  const ShiftCreationCapabilities({
    required this.canCreateIndependentShifts,
    required this.canRequestAgencyShifts,
    required this.availableAgencies,
  });

  bool get hasAnyCapabilities =>
      canCreateIndependentShifts || canRequestAgencyShifts;
  bool get canWorkWithMultipleAgencies => availableAgencies.length > 1;
}
