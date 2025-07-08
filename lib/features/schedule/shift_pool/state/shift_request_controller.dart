import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shift_model.dart';

final shiftRequestControllerProvider =
    Provider<ShiftRequestController>((ref) => ShiftRequestController());

class ShiftRequestController {
  final _db = FirebaseFirestore.instance;

  Future<void> requestShift(String shiftId, String nurseUid) async {
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
