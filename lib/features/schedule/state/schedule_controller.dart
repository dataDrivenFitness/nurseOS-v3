import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/schedule_repository_provider.dart';
import '../models/scheduled_shift_model.dart';

class ScheduleController extends AsyncNotifier<List<ScheduledShiftModel>> {
  @override
  Future<List<ScheduledShiftModel>> build() async {
    final repo = ref.read(scheduleRepositoryProvider);
    final userId = 'mockUser'; // TODO: Replace with auth provider
    return await repo.getUpcomingShifts(userId);
  }

  Future<void> confirmShift(String shiftId) async {
    final repo = ref.read(scheduleRepositoryProvider);
    await repo.confirmShift(shiftId);
    ref.invalidateSelf();
  }
}

final scheduleControllerProvider =
    AsyncNotifierProvider<ScheduleController, List<ScheduledShiftModel>>(() => ScheduleController());
