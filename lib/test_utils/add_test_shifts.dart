// lib/test_utils/add_test_shifts.dart
// Run this once to populate your Firestore with test available shifts

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TestShiftGenerator {
  static Future<void> addTestAvailableShifts() async {
    final firestore = FirebaseFirestore.instance;

    // Generate test shifts for the next few days
    final now = DateTime.now();

    final testShifts = [
      // Today's shifts
      {
        'id': 'shift_001',
        'location': 'General Hospital - ICU',
        'startTime': Timestamp.fromDate(now.add(const Duration(hours: 2))),
        'endTime': Timestamp.fromDate(now.add(const Duration(hours: 10))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'shift_002',
        'location': 'St. Mary\'s Medical Center - ER',
        'startTime': Timestamp.fromDate(now.add(const Duration(hours: 4))),
        'endTime': Timestamp.fromDate(now.add(const Duration(hours: 12))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },

      // Tomorrow's shifts
      {
        'id': 'shift_003',
        'location': 'Regional Medical Center - Med-Surg',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 6))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 18))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'shift_004',
        'location': 'Patient Home - Mrs. Johnson',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 8))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 16))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },

      // Day after tomorrow
      {
        'id': 'shift_005',
        'location': 'Children\'s Hospital - NICU',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 2, hours: 7))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 2, hours: 19))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'shift_006',
        'location': 'Sunrise Senior Living',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 2, hours: 22))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 3, hours: 6))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },

      // Weekend shifts
      {
        'id': 'shift_007',
        'location': 'Emergency Care Clinic',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 5, hours: 9))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 5, hours: 17))),
        'status': 'available',
        'assignedTo': null,
        'requestedBy': [],
        'createdAt': Timestamp.now(),
      },
    ];

    // Add each shift to Firestore
    for (final shift in testShifts) {
      final shiftId = shift['id'] as String;
      final shiftData = Map<String, dynamic>.from(shift);
      shiftData.remove('id'); // Don't store ID in the document data

      try {
        await firestore.collection('shifts').doc(shiftId).set(shiftData);
        if (kDebugMode) {
          print('✅ Added test shift: $shiftId - ${shift['location']}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to add shift $shiftId: $e');
        }
      }
    }

    if (kDebugMode) {
      print('🎉 Test available shifts added to Firestore!');
    }
  }

  // Helper to clear test shifts if needed
  static Future<void> clearTestShifts() async {
    final firestore = FirebaseFirestore.instance;

    final testShiftIds = [
      'shift_001',
      'shift_002',
      'shift_003',
      'shift_004',
      'shift_005',
      'shift_006',
      'shift_007'
    ];

    for (final shiftId in testShiftIds) {
      try {
        await firestore.collection('shifts').doc(shiftId).delete();
        if (kDebugMode) {
          print('🗑️ Deleted test shift: $shiftId');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to delete shift $shiftId: $e');
        }
      }
    }

    if (kDebugMode) {
      print('🧹 Test shifts cleared from Firestore!');
    }
  }
}
