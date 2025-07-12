// lib/features/schedule/shift_pool/state/shift_request_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shift_model.dart';
import '../../../agency/state/agency_context_provider.dart';

final shiftRequestControllerProvider =
    Provider<ShiftRequestController>((ref) => ShiftRequestController(ref));

class ShiftRequestController {
  final Ref _ref;
  final _db = FirebaseFirestore.instance;

  ShiftRequestController(this._ref);

  /// Request a shift in the current agency
  Future<void> requestShift(String shiftId, String nurseUid) async {
    final agencyId = _ref.read(currentAgencyIdProvider);

    if (agencyId == null) {
      throw Exception(
          'No agency context available - user must select an agency');
    }

    await requestShiftInAgency(agencyId, shiftId, nurseUid);
  }

  /// Request a shift in a specific agency
  Future<void> requestShiftInAgency(
      String agencyId, String shiftId, String nurseUid) async {
    final ref = _db
        .collection('agencies')
        .doc(agencyId)
        .collection('shifts')
        .doc(shiftId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) throw Exception('Shift not found');

      final shift = ShiftModel.fromJson({
        ...data,
        'id': shiftId,
        'agencyId': agencyId,
      });

      final updatedRequesters = Set<String>.from(shift.requestedBy ?? []);
      updatedRequesters.add(nurseUid);

      tx.update(ref, {'requestedBy': updatedRequesters.toList()});
    });
  }

  /// Cancel a shift request in the current agency
  Future<void> cancelShiftRequest(String shiftId, String nurseUid) async {
    final agencyId = _ref.read(currentAgencyIdProvider);

    if (agencyId == null) {
      throw Exception(
          'No agency context available - user must select an agency');
    }

    await cancelShiftRequestInAgency(agencyId, shiftId, nurseUid);
  }

  /// Cancel a shift request in a specific agency
  Future<void> cancelShiftRequestInAgency(
      String agencyId, String shiftId, String nurseUid) async {
    final ref = _db
        .collection('agencies')
        .doc(agencyId)
        .collection('shifts')
        .doc(shiftId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) throw Exception('Shift not found');

      final shift = ShiftModel.fromJson({
        ...data,
        'id': shiftId,
        'agencyId': agencyId,
      });

      final updatedRequesters = Set<String>.from(shift.requestedBy ?? []);
      updatedRequesters.remove(nurseUid);

      tx.update(ref, {'requestedBy': updatedRequesters.toList()});
    });
  }

  /// Assign a shift to a nurse (admin/supervisor function)
  Future<void> assignShift(String shiftId, String nurseUid) async {
    final agencyId = _ref.read(currentAgencyIdProvider);

    if (agencyId == null) {
      throw Exception(
          'No agency context available - user must select an agency');
    }

    await assignShiftInAgency(agencyId, shiftId, nurseUid);
  }

  /// Assign a shift to a nurse in a specific agency
  Future<void> assignShiftInAgency(
      String agencyId, String shiftId, String nurseUid) async {
    final ref = _db
        .collection('agencies')
        .doc(agencyId)
        .collection('shifts')
        .doc(shiftId);

    await ref.update({
      'assignedTo': nurseUid,
      'status': 'assigned',
      'assignedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Legacy method for backward compatibility
  @Deprecated('Use requestShift() instead')
  Future<void> requestShiftLegacy(String shiftId, String nurseUid) async {
    final ref = _db.collection('shifts').doc(shiftId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) throw Exception('Shift not found');
      final shift = ShiftModel.fromJson({...data, 'id': shiftId});

      final updatedRequesters = Set<String>.from(shift.requestedBy ?? []);
      updatedRequesters.add(nurseUid);

      tx.update(ref, {'requestedBy': updatedRequesters.toList()});
    });
  }
}
