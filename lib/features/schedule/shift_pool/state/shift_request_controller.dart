// 📁 lib/features/schedule/shift_pool/state/shift_request_controller.dart (REFINED)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import '../models/shift_model.dart';

final shiftRequestControllerProvider =
    Provider<ShiftRequestController>((ref) => ShiftRequestController(ref));

class ShiftRequestController {
  final Ref _ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ShiftRequestController(this._ref);

  Future<void> requestShift(String shiftId, String agencyId) async {
    final user = _ref.read(authControllerProvider).value;
    if (user == null) throw Exception('User not authenticated');

    final nurseUid = user.uid;

    // Remove agency validation - shifts will validate nurse eligibility at approval time
    final shiftRef = _db
        .collection('agencies')
        .doc(agencyId)
        .collection('shifts')
        .doc(shiftId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(shiftRef);
      if (!snap.exists) throw Exception('Shift not found');

      final data = snap.data()!;
      final shift = ShiftModel.fromJson({
        ...data,
        'id': shiftId,
        'agencyId': agencyId,
      });

      if (shift.status != 'available') {
        throw Exception('Shift is no longer available');
      }

      if (shift.hasRequestedBy(nurseUid)) {
        throw Exception('You have already requested this shift');
      }

      final updatedRequesters = {...?shift.requestedBy, nurseUid}.toList();

      tx.update(shiftRef, {
        'requestedBy': updatedRequesters,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> cancelShiftRequest(String shiftId, String agencyId) async {
    final user = _ref.read(authControllerProvider).value;
    if (user == null) throw Exception('User not authenticated');

    final nurseUid = user.uid;

    final shiftRef = _db
        .collection('agencies')
        .doc(agencyId)
        .collection('shifts')
        .doc(shiftId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(shiftRef);
      if (!snap.exists) throw Exception('Shift not found');

      final data = snap.data()!;
      final shift = ShiftModel.fromJson({
        ...data,
        'id': shiftId,
        'agencyId': agencyId,
      });

      final updatedRequesters =
          (shift.requestedBy ?? []).where((uid) => uid != nurseUid).toList();

      tx.update(shiftRef, {
        'requestedBy': updatedRequesters,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<List<ShiftModel>> getMyRequests() async {
    final user = _ref.read(authControllerProvider).value;
    if (user == null) throw Exception('User not authenticated');

    final nurseUid = user.uid;

    // Use collection group query to find all shifts where nurse has requested
    final snapshot = await _db
        .collectionGroup('shifts')
        .where('requestedBy', arrayContains: nurseUid)
        .get();

    final requestedShifts = <ShiftModel>[];

    for (final doc in snapshot.docs) {
      try {
        // Extract agency ID from document path
        final pathSegments = doc.reference.path.split('/');
        final agencyId = pathSegments.length >= 2 ? pathSegments[1] : null;

        final shift = ShiftModel.fromJson({
          ...doc.data(),
          'id': doc.id,
          'agencyId': agencyId,
        });

        requestedShifts.add(shift);
      } catch (e) {
        print('Error parsing shift ${doc.id}: $e');
      }
    }

    requestedShifts.sort((a, b) => a.startTime.compareTo(b.startTime));
    return requestedShifts;
  }

  Future<List<ShiftModel>> getShiftsWithRequests(String agencyId) async {
    try {
      final snapshot = await _db
          .collection('agencies')
          .doc(agencyId)
          .collection('shifts')
          .where('status', isEqualTo: 'available')
          .withConverter<ShiftModel>(
            fromFirestore: (snap, _) => ShiftModel.fromJson(
              snap.data()!
                ..['id'] = snap.id
                ..['agencyId'] = agencyId,
            ),
            toFirestore: (shift, _) => shift.toJson(),
          )
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error loading shifts with requests: $e');
      return [];
    }
  }

  int getRequestCount(ShiftModel shift) => shift.requestedBy?.length ?? 0;

  List<String> getRequesters(ShiftModel shift) => shift.requestedBy ?? [];
}
