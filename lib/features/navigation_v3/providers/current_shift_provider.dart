// lib/features/navigation_v3/providers/current_shift_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/work_history/state/work_history_controller.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model_converters.dart';

/// Provider that finds the current scheduled shift corresponding to active work session
/// This bridges the gap between WorkSession (duty tracking) and ScheduledShift (patient context)
final currentShiftDataProvider = StreamProvider<ScheduledShiftModel?>((ref) {
  final authState = ref.watch(authControllerProvider);
  final currentWorkSession = ref.watch(currentWorkSessionStreamProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);

      return currentWorkSession.when(
        data: (workSession) {
          if (workSession == null) return Stream.value(null);

          // Look for a scheduled shift that corresponds to the current work session
          return _findCorrespondingScheduledShift(user.uid, workSession);
        },
        loading: () => Stream.value(null),
        error: (_, __) => Stream.value(null),
      );
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// Find scheduled shift that corresponds to the active work session
Stream<ScheduledShiftModel?> _findCorrespondingScheduledShift(
  String userId,
  dynamic workSession,
) {
  try {
    final sessionStartTime = workSession.startTime as DateTime;
    final searchStart = sessionStartTime.subtract(const Duration(hours: 1));
    final searchEnd = sessionStartTime.add(const Duration(hours: 1));

    debugPrint(
        '🔍 Searching for scheduled shift between $searchStart and $searchEnd');

    // First, try to find agency shifts for this user
    return FirebaseFirestore.instance
        .collectionGroup('scheduledShifts') // Search across all agencies
        .where('assignedTo', isEqualTo: userId)
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(searchStart))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(searchEnd))
        .limit(1)
        .snapshots()
        .asyncMap((agencySnapshot) async {
      if (agencySnapshot.docs.isNotEmpty) {
        // Found an agency shift
        final doc = agencySnapshot.docs.first;
        debugPrint('✅ Found agency shift: ${doc.id}');

        return ScheduledShiftModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }

      // If no agency shift found, check independent shifts
      debugPrint('🔍 No agency shift found, checking independent shifts...');

      final independentSnapshot = await FirebaseFirestore.instance
          .collection('independentShifts')
          .where('assignedTo', isEqualTo: userId)
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(searchStart))
          .where('startTime',
              isLessThanOrEqualTo: Timestamp.fromDate(searchEnd))
          .limit(1)
          .get();

      if (independentSnapshot.docs.isNotEmpty) {
        final doc = independentSnapshot.docs.first;
        debugPrint('✅ Found independent shift: ${doc.id}');

        return ScheduledShiftModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }

      debugPrint('❌ No scheduled shift found for current work session');
      return null;
    });
  } catch (e) {
    debugPrint('❌ Error finding corresponding scheduled shift: $e');
    return Stream.value(null);
  }
}

/// Provider for checking if user can create shifts (independent nurses)
final canCreateShiftsProvider = Provider<bool>((ref) {
  final user = ref.watch(authControllerProvider).value;
  return user?.isIndependentNurse == true;
});

/// Provider that combines work session and scheduled shift into unified shift state
final unifiedCurrentShiftProvider = Provider<UnifiedShiftState>((ref) {
  final workSession = ref.watch(currentWorkSessionStreamProvider).value;
  final scheduledShift = ref.watch(currentShiftDataProvider).value;
  final canCreateShifts = ref.watch(canCreateShiftsProvider);

  if (workSession == null) {
    return UnifiedShiftState.offDuty(canCreateShifts: canCreateShifts);
  }

  if (scheduledShift == null) {
    return UnifiedShiftState.onDutyNoShift(
      workSession: workSession,
      canCreateShifts: canCreateShifts,
    );
  }

  return UnifiedShiftState.activeShift(
    workSession: workSession,
    scheduledShift: scheduledShift,
  );
});

/// Enum for different shift states
enum ShiftStatus { offDuty, onDutyNoShift, activeShift }

/// Unified shift state that combines work session and scheduled shift data
class UnifiedShiftState {
  final ShiftStatus status;
  final dynamic workSession;
  final ScheduledShiftModel? scheduledShift;
  final bool canCreateShifts;

  const UnifiedShiftState._({
    required this.status,
    this.workSession,
    this.scheduledShift,
    required this.canCreateShifts,
  });

  factory UnifiedShiftState.offDuty({required bool canCreateShifts}) {
    return UnifiedShiftState._(
      status: ShiftStatus.offDuty,
      canCreateShifts: canCreateShifts,
    );
  }

  factory UnifiedShiftState.onDutyNoShift({
    required dynamic workSession,
    required bool canCreateShifts,
  }) {
    return UnifiedShiftState._(
      status: ShiftStatus.onDutyNoShift,
      workSession: workSession,
      canCreateShifts: canCreateShifts,
    );
  }

  factory UnifiedShiftState.activeShift({
    required dynamic workSession,
    required ScheduledShiftModel scheduledShift,
  }) {
    return UnifiedShiftState._(
      status: ShiftStatus.activeShift,
      workSession: workSession,
      scheduledShift: scheduledShift,
      canCreateShifts: true, // If they have a shift, they can create shifts
    );
  }

  // Convenience getters
  bool get isOffDuty => status == ShiftStatus.offDuty;
  bool get isOnDutyNoShift => status == ShiftStatus.onDutyNoShift;
  bool get isActiveShift => status == ShiftStatus.activeShift;
  bool get hasPatientContext => scheduledShift != null;
  bool get isWorking => workSession != null;

  String get statusDisplay {
    switch (status) {
      case ShiftStatus.offDuty:
        return 'Off Duty';
      case ShiftStatus.onDutyNoShift:
        return 'On Duty - No Scheduled Shift';
      case ShiftStatus.activeShift:
        return 'Active Shift';
    }
  }
}
