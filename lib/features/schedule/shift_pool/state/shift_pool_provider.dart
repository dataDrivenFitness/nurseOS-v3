// lib/features/schedule/shift_pool/state/shift_pool_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/agency/state/agency_context_provider.dart';
import '../models/shift_model.dart';

/// Main shift pool provider with agency-scoped data and robust error handling
final shiftPoolProvider = StreamProvider<List<ShiftModel>>((ref) {
  // Get current agency context
  final agencyId = ref.watch(currentAgencyIdProvider);

  // Return empty list if no agency selected (graceful degradation)
  if (agencyId == null) {
    return Stream.value(<ShiftModel>[]);
  }

  final query = FirebaseFirestore.instance
      .collection('agencies')
      .doc(agencyId)
      .collection('shifts')
      .where('status', isEqualTo: 'available')
      .withConverter<ShiftModel>(
        fromFirestore: (snap, _) {
          final rawData = snap.data() ?? {};
          final data = Map<String, dynamic>.from(rawData);

          try {
            // Set the document ID and agencyId
            data['id'] = snap.id;
            data['agencyId'] = agencyId; // Ensure agencyId is set

            // Provide defaults for optional fields to prevent null issues
            data['requestedBy'] ??= <String>[];
            data['status'] ??= 'available';
            data['isWeekendShift'] ??= false;
            data['isNightShift'] ??= false;

            // Check for required timestamp fields and provide better error info
            if (data['startTime'] == null) {
              throw ArgumentError('Missing startTime for shift ${snap.id}');
            }
            if (data['endTime'] == null) {
              throw ArgumentError('Missing endTime for shift ${snap.id}');
            }
            if (data['location'] == null) {
              throw ArgumentError('Missing location for shift ${snap.id}');
            }

            if (kDebugMode) {
              debugPrint('🔧 Processing shift ${snap.id} in agency $agencyId:');
              debugPrint(
                  '  - startTime: ${data['startTime']} (${data['startTime'].runtimeType})');
              debugPrint(
                  '  - endTime: ${data['endTime']} (${data['endTime'].runtimeType})');
              debugPrint('  - location: ${data['location']}');
            }

            return ShiftModel.fromJson(data);
          } catch (e) {
            debugPrint('❌ Failed to convert shift document ${snap.id}: $e');
            debugPrint('📋 Raw data: $rawData');
            rethrow; // Re-throw to be handled by stream error handling
          }
        },
        toFirestore: (shift, _) => shift.toJson(),
      );

  return query.snapshots().map((snap) {
    final shifts = <ShiftModel>[];

    for (final doc in snap.docs) {
      try {
        shifts.add(doc.data());
      } catch (e) {
        // Log the error but continue processing other documents
        debugPrint('⚠️ Skipping problematic shift document ${doc.id}: $e');
      }
    }

    debugPrint(
        '🔍 ShiftPoolProvider: Returning ${shifts.length} shifts for agency $agencyId');
    return shifts;
  });
});

/// Legacy shift pool provider that does manual conversion
/// (for comparison with current failing implementation)
final legacyShiftPoolProvider = StreamProvider<List<ShiftModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('shifts')
      .where('status', isEqualTo: 'available')
      .snapshots()
      .map((snapshot) {
    final shifts = <ShiftModel>[];

    debugPrint(
        '🔍 LegacyShiftPoolProvider: Received snapshot with ${snapshot.docs.length} documents');

    for (final doc in snapshot.docs) {
      try {
        debugPrint('🔍 Converting document ${doc.id}');
        final rawData = doc.data();
        debugPrint('🔍 Document ${doc.id} raw data: $rawData');

        final data = Map<String, dynamic>.from(rawData);
        data['id'] = doc.id;

        debugPrint('🔍 Document ${doc.id} with ID: $data');

        final shift = ShiftModel.fromJson(data);
        shifts.add(shift);
        debugPrint('✅ Successfully converted document ${doc.id}');
      } catch (e, stackTrace) {
        debugPrint('❌ Failed to convert document ${doc.id}: $e');
        debugPrint('Stack trace: $stackTrace');
        debugPrint('❌ Failed to process document ${doc.id}: $e');
        // Continue processing other documents instead of failing completely
      }
    }

    debugPrint(
        '🔍 LegacyShiftPoolProvider: Returning ${shifts.length} shifts total');
    return shifts;
  });
});
