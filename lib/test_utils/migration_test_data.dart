// lib/test_utils/migration_test_data.dart
// FIXED: Add sample data with shift-centric patient assignments

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MigrationTestData {
  static const String defaultAgencyId = 'default_agency';

  static Future<void> generateTestData([String? agencyId]) async {
    final firestore = FirebaseFirestore.instance;
    final targetAgencyId = agencyId ?? defaultAgencyId;

    debugPrint(
        '🧪 Generating test data for migration (Agency: $targetAgencyId)...');

    // Ensure default agency exists first
    await _ensureAgencyExists(firestore, targetAgencyId);

    // Create test users (global, but with agency context)
    await _createTestUsers(firestore, targetAgencyId);

    // Create test patients (agency-scoped) - MUST be first for shift assignment
    await _createTestPatients(firestore, targetAgencyId);

    // Create test shifts (agency-scoped) - NOW with patient assignments
    await _createTestShifts(firestore, targetAgencyId);

    // Create test scheduled shifts (agency-scoped)
    await _createTestScheduledShifts(firestore, targetAgencyId);

    debugPrint('✅ Test data generation complete for agency $targetAgencyId!');
  }

  static Future<void> _ensureAgencyExists(
      FirebaseFirestore firestore, String agencyId) async {
    final agencyRef = firestore.collection('agencies').doc(agencyId);
    final agencyDoc = await agencyRef.get();

    if (!agencyDoc.exists) {
      await agencyRef.set({
        'id': agencyId,
        'name': agencyId == defaultAgencyId ? 'Default Agency' : 'Test Agency',
        'type': 'hospital',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'description': 'Test agency created for migration testing',
        'settings': {
          'allowCrossAgencyTransfers': false,
          'requireShiftConfirmation': true,
        },
        'tags': <String>[],
      });
      debugPrint('🏢 Created agency: $agencyId');
    } else {
      debugPrint('ℹ️ Agency $agencyId already exists');
    }
  }

  static Future<void> _createTestUsers(
      FirebaseFirestore firestore, String agencyId) async {
    final testUsers = [
      {
        'uid': 'leTZgslsRdSXm2wKLNbCyeIqcBu2',
        'firstName': 'Sarah',
        'lastName': 'Johnson',
        'email': 'sara@app.com',
        'role': 'nurse',
        'department': 'ICU',
        'unit': 'ICU-3',
        'shift': 'day',
        'phoneExtension': '1234',
        'specialty': 'Critical Care',
        'level': 5,
        'xp': 1250,
        'badges': ['first_shift', 'vitals_expert'],
        'activeAgencyId': agencyId,
        'agencyRoles': {
          agencyId: {
            'role': 'nurse',
            'status': 'active',
            'department': 'ICU',
            'unit': 'ICU-3',
            'shift': 'day',
            'assignedAt': FieldValue.serverTimestamp(),
            'joinedAt': FieldValue.serverTimestamp(),
            'lastActiveAt': FieldValue.serverTimestamp(),
            'permissions': <String>[],
            'metadata': {
              'createdForTesting': true,
            },
          },
        },
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'IjTRJyB6MThOCymSSnVDNlRQpaV2',
        'firstName': 'Michael',
        'lastName': 'Chen',
        'email': 'mike@app.com',
        'role': 'charge_nurse',
        'department': 'Emergency',
        'shift': 'night',
        'phoneExtension': '5678',
        'specialty': 'Emergency Medicine',
        'level': 8,
        'xp': 2400,
        'badges': ['leadership', 'emergency_response'],
        'activeAgencyId': agencyId,
        'agencyRoles': {
          agencyId: {
            'role': 'charge_nurse',
            'status': 'active',
            'department': 'Emergency',
            'shift': 'night',
            'assignedAt': FieldValue.serverTimestamp(),
            'joinedAt': FieldValue.serverTimestamp(),
            'lastActiveAt': FieldValue.serverTimestamp(),
            'permissions': ['approve_shifts', 'manage_staff'],
            'metadata': {
              'createdForTesting': true,
            },
          },
        },
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'test_admin_1',
        'firstName': 'Dr. Lisa',
        'lastName': 'Martinez',
        'email': 'lisa.martinez@test.com',
        'role': 'admin',
        'department': 'Administration',
        'level': 10,
        'xp': 5000,
        'badges': ['admin', 'supervisor'],
        'activeAgencyId': agencyId,
        'agencyRoles': {
          agencyId: {
            'role': 'admin',
            'status': 'active',
            'department': 'Administration',
            'assignedAt': FieldValue.serverTimestamp(),
            'joinedAt': FieldValue.serverTimestamp(),
            'lastActiveAt': FieldValue.serverTimestamp(),
            'permissions': ['full_access', 'user_management', 'system_admin'],
            'metadata': {
              'createdForTesting': true,
            },
          },
        },
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final user in testUsers) {
      await firestore.collection('users').doc(user['uid'] as String).set(user);
      debugPrint(
          '👤 Created test user: ${user['firstName']} ${user['lastName']} (Agency: $agencyId)');
    }
  }

  /// 🔧 FIXED: Create patients without assignedNurses field
  static Future<void> _createTestPatients(
      FirebaseFirestore firestore, String agencyId) async {
    final testPatients = [
      {
        'id': 'patient_001',
        'firstName': 'John',
        'lastName': 'Smith',
        'mrn': 'MRN001234',
        'location': 'hospital',
        'department': 'ICU',
        'roomNumber': '301A',
        'isFallRisk': true,
        'isIsolation': false,
        'biologicalSex': 'male',
        'primaryDiagnoses': ['Pneumonia', 'Diabetes'],
        // ✅ REMOVED: assignedNurses field (shift-centric architecture)
        'allergies': ['Penicillin'],
        'dietRestrictions': ['Diabetic'],
        'agencyId': agencyId,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'test_admin_1',
        'ownerUid': 'test_admin_1',
      },
      {
        'id': 'patient_002',
        'firstName': 'Mary',
        'lastName': 'Wilson',
        'mrn': 'MRN005678',
        'location': 'residence',
        'addressLine1': '123 Oak Street',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95123',
        'isFallRisk': false,
        'isIsolation': true,
        'biologicalSex': 'female',
        'primaryDiagnoses': ['Post-surgical recovery'],
        // ✅ REMOVED: assignedNurses field (shift-centric architecture)
        'allergies': [],
        'dietRestrictions': ['Low sodium'],
        'agencyId': agencyId,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'test_admin_1',
        'ownerUid': 'test_admin_1',
      },
      {
        'id': 'patient_003',
        'firstName': 'Robert',
        'lastName': 'Davis',
        'mrn': 'MRN009876',
        'location': 'hospital',
        'department': 'ICU',
        'roomNumber': '302B',
        'isFallRisk': false,
        'isIsolation': false,
        'biologicalSex': 'male',
        'primaryDiagnoses': ['Heart Failure', 'Hypertension'],
        'allergies': ['Shellfish'],
        'dietRestrictions': ['Low sodium', 'Heart healthy'],
        'agencyId': agencyId,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'test_admin_1',
        'ownerUid': 'test_admin_1',
      },
    ];

    for (final patient in testPatients) {
      await firestore
          .collection('agencies')
          .doc(agencyId)
          .collection('patients')
          .doc(patient['id'] as String)
          .set(patient);
      debugPrint(
          '🏥 Created test patient: ${patient['firstName']} ${patient['lastName']} (Agency: $agencyId)');
    }
  }

  /// 🔧 FIXED: Create shifts WITH patient assignments
  static Future<void> _createTestShifts(
      FirebaseFirestore firestore, String agencyId) async {
    final now = DateTime.now();

    final testShifts = [
      {
        'id': 'shift_test_001',
        'location': 'General Hospital',
        'facilityName': 'General Hospital',
        'department': 'ICU',
        'addressLine1': '123 Medical Center Dr',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95128',
        'startTime': Timestamp.fromDate(now.add(const Duration(hours: 2))),
        'endTime': Timestamp.fromDate(now.add(const Duration(hours: 10))),
        'status': 'available',
        'requestedBy': [],
        'isNightShift': false,
        'isWeekendShift': false,
        'agencyId': agencyId,
        // 🎯 CRITICAL: Add patients to this ICU shift
        'assignedPatientIds': [
          'patient_001',
          'patient_003'
        ], // Both ICU patients
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'shift_test_002',
        'location': 'Home Care',
        'addressLine1': '123 Oak Street', // Same as patient_002's address
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95123',
        'patientName': 'Mary Wilson', // Specific home care patient
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 8))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 16))),
        'status': 'available',
        'requestedBy': [],
        'isNightShift': false,
        'isWeekendShift': false,
        'agencyId': agencyId,
        // 🎯 CRITICAL: Add home care patient to this shift
        'assignedPatientIds': ['patient_002'], // Home care patient
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final shift in testShifts) {
      await firestore
          .collection('agencies')
          .doc(agencyId)
          .collection('shifts')
          .doc(shift['id'] as String)
          .set(shift);
      debugPrint(
          '📅 Created test shift: ${shift['id']} with ${(shift['assignedPatientIds'] as List).length} patients (Agency: $agencyId)');
    }
  }

  /// 🔧 FIXED: Create scheduled shifts WITH patient assignments
  static Future<void> _createTestScheduledShifts(
      FirebaseFirestore firestore, String agencyId) async {
    final now = DateTime.now();

    final testScheduledShifts = [
      {
        'id': 'scheduled_001',
        'assignedTo': 'leTZgslsRdSXm2wKLNbCyeIqcBu2',
        'status': 'scheduled',
        'locationType': 'facility',
        'facilityName': 'General Hospital',
        'addressLine1': '123 Medical Center Dr',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95128',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 2, hours: 7))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 2, hours: 19))),
        'isConfirmed': true,
        // 🎯 CRITICAL: Ensure patients are assigned to scheduled shift
        'assignedPatientIds': ['patient_001'], // This nurse gets patient_001
        'agencyId': agencyId,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final shift in testScheduledShifts) {
      await firestore
          .collection('agencies')
          .doc(agencyId)
          .collection('scheduledShifts')
          .doc(shift['id'] as String)
          .set(shift);
      debugPrint(
          '📋 Created test scheduled shift: ${shift['id']} with ${(shift['assignedPatientIds'] as List).length} patients (Agency: $agencyId)');
    }
  }

  static Future<void> clearTestData([String? agencyId]) async {
    final firestore = FirebaseFirestore.instance;
    final targetAgencyId = agencyId ?? defaultAgencyId;

    debugPrint('🧹 Clearing test data for agency $targetAgencyId...');

    // Clear test users (global collection, but only test users)
    await firestore.collection('users').doc('test_nurse_1').delete();
    await firestore.collection('users').doc('test_nurse_2').delete();
    await firestore.collection('users').doc('test_admin_1').delete();
    debugPrint('🗑️ Cleared test users');

    // Clear test patients (agency-scoped)
    await firestore
        .collection('agencies')
        .doc(targetAgencyId)
        .collection('patients')
        .doc('patient_001')
        .delete();
    await firestore
        .collection('agencies')
        .doc(targetAgencyId)
        .collection('patients')
        .doc('patient_002')
        .delete();
    await firestore
        .collection('agencies')
        .doc(targetAgencyId)
        .collection('patients')
        .doc('patient_003')
        .delete();
    debugPrint('🗑️ Cleared test patients from agency $targetAgencyId');

    // Clear test shifts (agency-scoped)
    await firestore
        .collection('agencies')
        .doc(targetAgencyId)
        .collection('shifts')
        .doc('shift_test_001')
        .delete();
    await firestore
        .collection('agencies')
        .doc(targetAgencyId)
        .collection('shifts')
        .doc('shift_test_002')
        .delete();
    debugPrint('🗑️ Cleared test shifts from agency $targetAgencyId');

    // Clear test scheduled shifts (agency-scoped)
    await firestore
        .collection('agencies')
        .doc(targetAgencyId)
        .collection('scheduledShifts')
        .doc('scheduled_001')
        .delete();
    debugPrint('🗑️ Cleared test scheduled shifts from agency $targetAgencyId');

    debugPrint('✅ Test data cleared for agency $targetAgencyId!');
  }
}
