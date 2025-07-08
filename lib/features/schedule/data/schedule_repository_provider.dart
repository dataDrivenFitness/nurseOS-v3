import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/abstract_schedule_repository.dart';
import '../models/scheduled_shift_model.dart';

// Mock implementation for now
class MockScheduleRepository implements AbstractScheduleRepository {
  @override
  Future<List<ScheduledShiftModel>> getUpcomingShifts(String userId) async {
    return [
      ScheduledShiftModel(
        id: 'shift1',
        assignedTo: userId,
        status: 'scheduled',
        locationType: 'facility',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 9)),
        isConfirmed: false,
        facilityName: 'General Hospital',
        address: '123 Wellness Way',
        assignedPatientIds: ['pat1', 'pat2'],
      ),
    ];
  }

  @override
  Future<void> confirmShift(String shiftId) async {
    // No-op for mock
  }
}

final scheduleRepositoryProvider = Provider<AbstractScheduleRepository>((ref) {
  return MockScheduleRepository(); // Swap with real one later
});
