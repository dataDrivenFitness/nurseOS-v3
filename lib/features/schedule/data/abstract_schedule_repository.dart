import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model.dart';

abstract class AbstractScheduleRepository {
  Future<List<ScheduledShiftModel>> getUpcomingShifts(String userId);
  Future<void> confirmShift(String shiftId);
}
