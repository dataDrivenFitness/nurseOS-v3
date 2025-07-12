// lib/test_utils/add_test_shifts.dart
// Run this once to populate your Firestore with test available shifts

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TestShiftGenerator {
  /// Add test shifts to agency-scoped collection
  static Future<void> addTestAvailableShifts([String? agencyId]) async {
    final firestore = FirebaseFirestore.instance;
    final targetAgencyId = agencyId ?? 'default_agency';

    // Generate test shifts for the next few days
    final now = DateTime.now();

    final testShifts = [
      // Hospital/Facility shifts - using patient model structure
      {
        'id': 'shift_001',
        'location': 'hospital', // Patient model location type
        'department': 'ICU',
        'roomNumber': null,
        'facilityName': 'General Hospital',
        'addressLine1': '123 Medical Center Drive',
        'addressLine2': null,
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95128',
        'startTime': Timestamp.fromDate(now.add(const Duration(hours: 2))),
        'endTime': Timestamp.fromDate(now.add(const Duration(hours: 10))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'shift_002',
        'location': 'hospital',
        'department': 'Emergency',
        'roomNumber': null,
        'facilityName': 'St. Mary\'s Medical Center',
        'addressLine1': '456 Healthcare Blvd',
        'addressLine2': null,
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95112',
        'startTime': Timestamp.fromDate(now.add(const Duration(hours: 4))),
        'endTime': Timestamp.fromDate(now.add(const Duration(hours: 12))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },

      // SNF/Rehab facility shifts
      {
        'id': 'shift_003',
        'location': 'snf',
        'department': 'Med-Surg',
        'roomNumber': null,
        'facilityName': 'Regional Medical Center',
        'addressLine1': '789 Wellness Way',
        'addressLine2': 'Building A',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95123',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 6))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 18))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },

      // Home care shifts - residence location type
      {
        'id': 'shift_004',
        'location': 'residence',
        'department': null,
        'roomNumber': null,
        'facilityName': null,
        'addressLine1': '1234 Oak Street',
        'addressLine2': null,
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95123',
        'patientName': 'Mrs. Johnson',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 8))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 16))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },

      // Children's hospital
      {
        'id': 'shift_005',
        'location': 'hospital',
        'department': 'NICU',
        'roomNumber': null,
        'facilityName': 'Children\'s Hospital',
        'addressLine1': '321 Pediatric Circle',
        'addressLine2': null,
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95110',
        'specialRequirements': 'NICU certification required',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 2, hours: 7))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 2, hours: 19))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },

      // Senior living facility
      {
        'id': 'shift_006',
        'location': 'other', // Senior living
        'department': 'Long-term Care',
        'roomNumber': null,
        'facilityName': 'Sunrise Senior Living',
        'addressLine1': '654 Elder Care Lane',
        'addressLine2': null,
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95118',
        'isNightShift': true,
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 2, hours: 22))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 3, hours: 6))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },

      // Rehab facility
      {
        'id': 'shift_007',
        'location': 'rehab',
        'department': 'Physical Therapy',
        'roomNumber': null,
        'facilityName': 'Valley Rehabilitation Center',
        'addressLine1': '987 Recovery Road',
        'addressLine2': 'Suite 200',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95134',
        'isWeekendShift': true,
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 5, hours: 9))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 5, hours: 17))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },

      // Another home care shift
      {
        'id': 'shift_008',
        'location': 'residence',
        'department': null,
        'roomNumber': null,
        'facilityName': null,
        'addressLine1': '567 Pine Avenue',
        'addressLine2': 'Apt 12',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95112',
        'patientName': 'Mr. Davis',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 3, hours: 10))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 3, hours: 18))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },
    ];

    // Add each shift to agency-scoped collection
    for (final shift in testShifts) {
      final shiftId = shift['id'] as String;
      final shiftData = Map<String, dynamic>.from(shift);
      shiftData.remove('id'); // Don't store ID in the document data
      shiftData['agencyId'] = targetAgencyId; // Add agency context

      try {
        await firestore
            .collection('agencies')
            .doc(targetAgencyId)
            .collection('shifts')
            .doc(shiftId)
            .set(shiftData);
        if (kDebugMode) {
          print(
              '✅ Added test shift: $shiftId - ${shift['location']} (Agency: $targetAgencyId)');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to add shift $shiftId: $e');
        }
      }
    }

    if (kDebugMode) {
      print('🎉 Test available shifts added to agency $targetAgencyId!');
    }
  }

  // Helper to clear test shifts if needed
  static Future<void> clearTestShifts([String? agencyId]) async {
    final firestore = FirebaseFirestore.instance;
    final targetAgencyId = agencyId ?? 'default_agency';

    final testShiftIds = [
      'shift_001',
      'shift_002',
      'shift_003',
      'shift_004',
      'shift_005',
      'shift_006',
      'shift_007',
      'shift_008',
    ];

    for (final shiftId in testShiftIds) {
      try {
        await firestore
            .collection('agencies')
            .doc(targetAgencyId)
            .collection('shifts')
            .doc(shiftId)
            .delete();
        if (kDebugMode) {
          print('🗑️ Deleted test shift: $shiftId (Agency: $targetAgencyId)');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to delete shift $shiftId: $e');
        }
      }
    }

    if (kDebugMode) {
      print('🧹 Test shifts cleared from agency $targetAgencyId!');
    }
  }

  // Helper to add some emergency coverage requests for testing
  static Future<void> addEmergencyTestShifts([String? agencyId]) async {
    final firestore = FirebaseFirestore.instance;
    final targetAgencyId = agencyId ?? 'default_agency';
    final now = DateTime.now();

    final emergencyShifts = [
      {
        'id': 'emergency_001',
        'location': 'hospital',
        'department': 'ICU',
        'roomNumber': null,
        'facilityName': 'Metro General Hospital',
        'addressLine1': '999 Emergency Drive',
        'addressLine2': null,
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95131',
        'startTime': Timestamp.fromDate(now.add(const Duration(hours: 1))),
        'endTime': Timestamp.fromDate(now.add(const Duration(hours: 9))),
        'status': 'urgent',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
        'isEmergency': true,
        'urgencyLevel': 'critical',
        'reason': 'Staff called in sick - immediate coverage needed',
      },
      {
        'id': 'emergency_002',
        'location': 'residence',
        'department': null,
        'roomNumber': null,
        'facilityName': null,
        'addressLine1': '890 Elm Street',
        'addressLine2': null,
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95110',
        'patientName': 'Mrs. Chen',
        'startTime': Timestamp.fromDate(now.add(const Duration(hours: 3))),
        'endTime': Timestamp.fromDate(now.add(const Duration(hours: 11))),
        'status': 'urgent',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
        'isEmergency': true,
        'urgencyLevel': 'high',
        'reason': 'Family emergency - regular nurse unavailable',
      },
    ];

    for (final shift in emergencyShifts) {
      final shiftId = shift['id'] as String;
      final shiftData = Map<String, dynamic>.from(shift);
      shiftData.remove('id');
      shiftData['agencyId'] = targetAgencyId; // Add agency context

      try {
        await firestore
            .collection('agencies')
            .doc(targetAgencyId)
            .collection('shifts')
            .doc(shiftId)
            .set(shiftData);
        if (kDebugMode) {
          print(
              '🚨 Added emergency shift: $shiftId - ${shift['location']} (Agency: $targetAgencyId)');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to add emergency shift $shiftId: $e');
        }
      }
    }

    if (kDebugMode) {
      print('🚨 Emergency test shifts added to agency $targetAgencyId!');
    }
  }
}
