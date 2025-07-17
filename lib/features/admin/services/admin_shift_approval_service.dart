// 📁 lib/features/admin/services/admin_shift_approval_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model.dart';

class AdminShiftApprovalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Approve a shift request and move it to the nurse's scheduled shifts
  Future<void> approveShift({
    required String agencyId,
    required String shiftId,
    required String nurseUid,
  }) async {
    final shiftRef = _db
        .collection('agencies')
        .doc(agencyId)
        .collection('shifts')
        .doc(shiftId);
    final snap = await shiftRef.get();
    final data = snap.data();

    if (data == null) throw Exception('Shift not found');

    final shift = ShiftModel.fromJson({
      ...data,
      'id': shiftId,
      'agencyId': agencyId,
    });

    // Write to nurse's scheduled shifts
    final scheduled = ScheduledShiftModel(
      id: shift.id,
      assignedTo: nurseUid,
      status: 'confirmed',
      locationType: shift.location,
      facilityName: shift.facilityName,
      address: shift.fullAddress,
      assignedPatientIds: shift.assignedPatientIds,
      startTime: shift.startTime,
      endTime: shift.endTime,
      isConfirmed: true,
      agencyId: agencyId,
      isUserCreated: false,
      createdBy: 'admin_test',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final scheduledRef = _db
        .collection('agencies')
        .doc(agencyId)
        .collection('scheduledShifts')
        .doc(shift.id);

    await scheduledRef.set(scheduled.toJson());

    // Update original shift to reflect final state
    await shiftRef.update({
      'status': 'assigned',
      'approvedAt': FieldValue.serverTimestamp(),
      'approvedBy': 'admin_test',
    });
  }

  /// Deny a shift request
  Future<void> denyShift({
    required String agencyId,
    required String shiftId,
    required String nurseUid,
  }) async {
    final shiftRef = _db
        .collection('agencies')
        .doc(agencyId)
        .collection('shifts')
        .doc(shiftId);

    await shiftRef.update({
      'requestedBy': FieldValue.arrayRemove([nurseUid]),
      'deniedAt': FieldValue.serverTimestamp(),
      'deniedBy': 'admin_test',
      'status': 'available',
    });
  }
}
