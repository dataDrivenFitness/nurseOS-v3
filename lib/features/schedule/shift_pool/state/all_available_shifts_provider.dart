// 📁 lib/features/schedule/shift_pool/state/all_available_shifts_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import '../models/shift_model.dart';
import '../models/shift_model_extensions.dart';
import 'shift_pool_provider.dart';

/// 🌍 Universal provider that aggregates ALL available shifts for ANY nurse type
///
/// This provider combines:
/// - Agency shifts (from shiftPoolProvider)
/// - User-created independent shifts (from independentShiftsProvider)
/// - Future shift sources as needed
///
/// ✅ BENEFITS:
/// - Shows pill counts for ALL nurses (agency, independent, hybrid)
/// - Maintains shift-centric architecture
/// - Supports universal pill display regardless of nurse type
/// - Prepared for independent nurse functionality
final allAvailableShiftsProvider = StreamProvider<List<ShiftModel>>((ref) {
  final user = ref.watch(authControllerProvider).value;

  if (user == null) {
    return const Stream.empty();
  }

  // Get agency shifts (existing functionality)
  final agencyShiftsStream = ref.watch(shiftPoolProvider.stream);

  // Get independent shifts (placeholder for future implementation)
  final independentShiftsStream = ref.watch(independentShiftsProvider.stream);

  // Combine both streams into one universal stream
  return Rx.combineLatest2<List<ShiftModel>, List<ShiftModel>,
      List<ShiftModel>>(
    agencyShiftsStream,
    independentShiftsStream,
    (agencyShifts, independentShifts) {
      // Combine shifts from both sources
      final allShifts = <ShiftModel>[
        ...agencyShifts,
        ...independentShifts,
      ];

      // Sort by start time (earliest first)
      allShifts.sort((a, b) => a.startTime.compareTo(b.startTime));

      return allShifts;
    },
  ).handleError((error, stackTrace) {
    // Handle errors gracefully - return empty list instead of crashing
    return <ShiftModel>[];
  });
});

/// 🏠 Independent shifts provider (placeholder for future implementation)
///
/// This provider will handle shifts created by independent nurses
/// when the independent nurse functionality is fully implemented.
///
/// TODO: Implement this provider to query user-created shifts from:
/// - Collection: /users/{userId}/independentShifts
/// - Or: /independentShifts where createdBy == userId
final independentShiftsProvider = StreamProvider<List<ShiftModel>>((ref) {
  final user = ref.watch(authControllerProvider).value;

  if (user == null) {
    return const Stream.empty();
  }

  // TODO: Replace with actual independent shifts query
  // Example future implementation:
  // return FirebaseFirestore.instance
  //     .collection('users')
  //     .doc(user.uid)
  //     .collection('independentShifts')
  //     .where('status', isEqualTo: 'available')
  //     .where('assignedTo', isNull: true)
  //     .withConverter<ShiftModel>(...)
  //     .snapshots()
  //     .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  // For now, return empty stream (no independent shifts yet)
  return const Stream.empty();
});

/// 🎯 Shift categorization provider for pill display
///
/// Categorizes all available shifts into emergency, coverage, and regular
/// for the pill display header. Works with ANY nurse type.
final shiftCategoriesProvider = Provider<ShiftCategories>((ref) {
  final allShiftsAsync = ref.watch(allAvailableShiftsProvider);

  return allShiftsAsync.when(
    data: (shifts) {
      // Filter to only available shifts that aren't assigned
      final availableShifts = shifts
          .where((shift) =>
              shift.status == 'available' &&
              (shift.assignedTo == null || shift.assignedTo!.isEmpty))
          .toList();

      // Categorize using existing extension methods
      final emergencyShifts =
          availableShifts.where((s) => s.isEmergencyShift).toList();
      final coverageShifts =
          availableShifts.where((s) => s.isCoverageRequest).toList();
      final regularShifts =
          availableShifts.where((s) => s.isRegularShift).toList();

      return ShiftCategories(
        emergency: emergencyShifts,
        coverage: coverageShifts,
        regular: regularShifts,
      );
    },
    loading: () => const ShiftCategories.empty(),
    error: (_, __) => const ShiftCategories.empty(),
  );
});

/// 📊 Data class for categorized shifts
class ShiftCategories {
  final List<ShiftModel> emergency;
  final List<ShiftModel> coverage;
  final List<ShiftModel> regular;

  const ShiftCategories({
    required this.emergency,
    required this.coverage,
    required this.regular,
  });

  const ShiftCategories.empty()
      : emergency = const [],
        coverage = const [],
        regular = const [];

  /// Total count of all available shifts
  int get totalCount => emergency.length + coverage.length + regular.length;

  /// Whether there are any shifts available
  bool get hasShifts => totalCount > 0;

  /// Whether there are any emergency shifts
  bool get hasEmergencyShifts => emergency.isNotEmpty;

  /// Whether there are any coverage requests
  bool get hasCoverageRequests => coverage.isNotEmpty;

  /// Whether there are any regular shifts
  bool get hasRegularShifts => regular.isNotEmpty;
}
