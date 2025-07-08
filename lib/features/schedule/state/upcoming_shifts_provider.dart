import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scheduled_shift_model.dart';

final upcomingShiftsProvider =
    StreamProvider.family<List<ScheduledShiftModel>, String>((ref, userId) {
  final query = FirebaseFirestore.instance
      .collection('shifts')
      .where('assignedTo', isEqualTo: userId)
      .where('status', isEqualTo: 'accepted')
      .withConverter<ScheduledShiftModel>(
        fromFirestore: (snap, _) {
          final rawData = snap.data() ?? {};
          final data = Map<String, dynamic>.from(rawData);

          // Set the document ID
          data['id'] = snap.id;

          // Handle field name mismatch: 'location' -> 'locationType'
          if (data['location'] != null && data['locationType'] == null) {
            data['locationType'] = 'facility';
          }

          // Provide defaults for required fields that might be null
          data['locationType'] ??= 'other';
          data['isConfirmed'] ??= false;

          // Map the location name to facilityName if it exists
          if (data['location'] != null && data['facilityName'] == null) {
            data['facilityName'] = data['location'];
          }

          // Check for null timestamps and provide better error info
          if (data['startTime'] == null) {
            throw ArgumentError('Missing startTime for shift ${snap.id}');
          }
          if (data['endTime'] == null) {
            throw ArgumentError('Missing endTime for shift ${snap.id}');
          }

          if (kDebugMode) {
            print('🔧 Processing shift ${snap.id}:');
            print(
                '  - startTime: ${data['startTime']} (${data['startTime'].runtimeType})');
            print(
                '  - endTime: ${data['endTime']} (${data['endTime'].runtimeType})');
            print('  - locationType: ${data['locationType']}');
          }

          return ScheduledShiftModel.fromJson(data);
        },
        toFirestore: (model, _) => model.toJson(),
      );

  return query
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());
});
