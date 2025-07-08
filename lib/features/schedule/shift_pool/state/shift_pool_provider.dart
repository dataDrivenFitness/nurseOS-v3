// lib/features/schedule/shift_pool/state/shift_pool_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shift_model.dart';

final shiftPoolProvider = StreamProvider<List<ShiftModel>>((ref) {
  debugPrint('🔍 ShiftPoolProvider: Setting up stream...');

  final query = FirebaseFirestore.instance
      .collection('shifts')
      .where('status', isEqualTo: 'available')
      .withConverter<ShiftModel>(
        fromFirestore: (snap, _) {
          debugPrint('🔍 Converting document ${snap.id}');
          final data = snap.data();
          if (data == null) {
            debugPrint('❌ Document ${snap.id} has null data');
            throw Exception('Document ${snap.id} has null data');
          }

          debugPrint('🔍 Document ${snap.id} raw data: $data');

          // Add the document ID to the data
          final dataWithId = {...data, 'id': snap.id};
          debugPrint('🔍 Document ${snap.id} with ID: $dataWithId');

          try {
            final shift = ShiftModel.fromJson(dataWithId);
            debugPrint(
                '✅ Successfully converted ${snap.id}: ${shift.location}');
            return shift;
          } catch (e, stackTrace) {
            debugPrint('❌ Failed to convert document ${snap.id}: $e');
            debugPrint('Stack trace: $stackTrace');
            rethrow;
          }
        },
        toFirestore: (shift, _) => shift.toJson(),
      );

  return query.snapshots().map((snap) {
    debugPrint(
        '🔍 ShiftPoolProvider: Received snapshot with ${snap.docs.length} documents');

    final shifts = <ShiftModel>[];
    for (final doc in snap.docs) {
      try {
        final shift = doc.data();
        shifts.add(shift);
        debugPrint('✅ Added shift: ${shift.id} - ${shift.location}');
      } catch (e) {
        debugPrint('❌ Failed to process document ${doc.id}: $e');
      }
    }

    debugPrint('🔍 ShiftPoolProvider: Returning ${shifts.length} shifts total');
    return shifts;
  }).handleError((error, stackTrace) {
    debugPrint('❌ ShiftPoolProvider stream error: $error');
    debugPrint('Stack trace: $stackTrace');
  });
});
