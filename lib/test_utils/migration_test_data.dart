// lib/test_utils/migration_test_data.dart
// UPDATED: Shift-centric architecture test data with nurseIds in agencies

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MigrationTestData {
  // Define the 2 agencies
  static const String metroHospitalId = 'metro_hospital';
  static const String cityCareId = 'city_care';

  // Define the 3 nurses
  static const String nurseAId = 'leTZgslsRdSXm2wKLNbCyeIqcBu2'; // Metro only
  static const String nurseBId = 'IjTRJyB6MThOCymSSnVDNlRQpaV2'; // City only
  static const String nurseCId =
      'R3JMhImrBvddyAQo3EDOw11vqkh2'; // Both agencies

  static Future<void> generateTestData([String? targetAgencyId]) async {
    final firestore = FirebaseFirestore.instance;

    debugPrint('🧪 Generating shift-centric test data...');

    // Create the 2 agencies with nurseIds
    await _createTestAgencies(firestore);

    // Create 3 nurses (without agencyRoles)
    await _createTestNurses(firestore);

    // Create patients (18 total: 10 for Metro, 8 for City)
    await _createTestPatients(firestore);

    // Create 4 shifts with exact patient counts
    await _createTestShifts(firestore);

    // Create scheduled shifts for testing
    await _createTestScheduledShifts(firestore);

    debugPrint('✅ Shift-centric test data generation complete!');
    debugPrint('📊 Created: 2 agencies, 3 nurses, 18 patients, 4 shifts');
  }

  /// Create Metro Hospital and City Care agencies with nurseIds
  static Future<void> _createTestAgencies(FirebaseFirestore firestore) async {
    final agencies = [
      // Metro Hospital - Hospital type
      {
        'id': metroHospitalId,
        'name': 'Metro Hospital',
        'type': 'hospital',
        'isActive': true,
        'address': '123 Medical Center Drive, San Jose, CA 95128',
        'phone': '(408) 555-0100',
        'email': 'admin@metrohospital.com',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'test_admin',
        'nurseIds': [nurseAId, nurseCId], // Sarah and Jessica
        'settings': {
          'allowCrossAgencyScheduling': false,
          'requireLocationVerification': true,
          'enableTaskManagement': true,
          'gamificationEnabled': true,
          'shiftDurationHours': 12,
          'breakDurationMinutes': 30,
          'overtimeThresholdHours': 40,
        },
        'tags': ['hospital', 'acute_care', 'trauma_center'],
      },

      // City Care - Home Health type
      {
        'id': cityCareId,
        'name': 'City Care Home Health',
        'type': 'home_health',
        'isActive': true,
        'address': '456 Community Way, San Jose, CA 95112',
        'phone': '(408) 555-0200',
        'email': 'admin@citycare.com',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'test_admin',
        'nurseIds': [nurseBId, nurseCId], // Michael and Jessica
        'settings': {
          'allowCrossAgencyScheduling': false,
          'requireLocationVerification': true,
          'enableTaskManagement': true,
          'gamificationEnabled': true,
          'travelTimeIncluded': true,
          'mileageTracking': true,
          'addressVerificationRequired': true,
        },
        'tags': ['home_health', 'community_care', 'senior_services'],
      },
    ];

    for (final agency in agencies) {
      final agencyId = agency['id'] as String;
      final agencyData = Map<String, dynamic>.from(agency);
      agencyData.remove('id');

      await firestore.collection('agencies').doc(agencyId).set(agencyData);
      debugPrint(
          '🏢 Created agency: ${agency['name']} with nurses: ${agency['nurseIds']}');
    }
  }

  /// Create 3 nurses with simplified structure (no agencyRoles)
  static Future<void> _createTestNurses(FirebaseFirestore firestore) async {
    final now = DateTime.now();

    final nurses = [
      // Nurse A - Sarah Johnson (Metro Hospital only)
      {
        'uid': nurseAId,
        'firstName': 'Sarah',
        'lastName': 'Johnson',
        'email': 'sara@app.com',
        'role': 'nurse',
        'licenseNumber': 'RN123456',
        'licenseExpiry': now.add(const Duration(days: 365)).toIso8601String(),
        'specialty': 'Critical Care',
        'department': 'ICU',
        'shift': 'day',
        'phoneExtension': '1234',
        'isIndependentNurse': false,
        'level': 5,
        'xp': 1250,
        'badges': ['first_shift', 'vitals_expert'],
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Nurse B - Michael Chen (City Care only)
      {
        'uid': nurseBId,
        'firstName': 'Michael',
        'lastName': 'Chen',
        'email': 'mike@app.com',
        'role': 'nurse',
        'licenseNumber': 'RN789012',
        'licenseExpiry': now.add(const Duration(days: 400)).toIso8601String(),
        'specialty': 'Home Health',
        'department': 'Community Care',
        'shift': 'day',
        'phoneExtension': '5678',
        'isIndependentNurse': false,
        'level': 6,
        'xp': 1800,
        'badges': ['community_care', 'home_visits'],
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Nurse C - Jessica Rodriguez (Both agencies - multi-agency nurse)
      {
        'uid': nurseCId,
        'firstName': 'Jessica',
        'lastName': 'Rodriguez',
        'email': 'jess@app.com',
        'role': 'nurse',
        'licenseNumber': 'RN345678',
        'licenseExpiry': now.add(const Duration(days: 300)).toIso8601String(),
        'specialty': 'Multi-Specialty',
        'department': 'Float Pool',
        'shift': 'varies',
        'phoneExtension': '9012',
        'isIndependentNurse': true,
        'level': 8,
        'xp': 2400,
        'badges': ['leadership', 'multi_agency', 'adaptability'],
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final nurse in nurses) {
      await firestore
          .collection('users')
          .doc(nurse['uid'] as String)
          .set(nurse);
      debugPrint(
          '👤 Created nurse: ${nurse['firstName']} ${nurse['lastName']}');
    }
  }

  /// Create 18 patients (10 for Metro, 8 for City)
  static Future<void> _createTestPatients(FirebaseFirestore firestore) async {
    // Metro Hospital patients (10 total for 4+6 assignment)
    final metroPatients = [
      _createPatient(
          'metro_patient_01', 'John', 'Smith', metroHospitalId, 'hospital',
          department: 'ICU', room: '301A'),
      _createPatient(
          'metro_patient_02', 'Mary', 'Wilson', metroHospitalId, 'hospital',
          department: 'ICU', room: '301B'),
      _createPatient(
          'metro_patient_03', 'Robert', 'Davis', metroHospitalId, 'hospital',
          department: 'ICU', room: '302A'),
      _createPatient(
          'metro_patient_04', 'Linda', 'Brown', metroHospitalId, 'hospital',
          department: 'ICU', room: '302B'),
      _createPatient(
          'metro_patient_05', 'James', 'Taylor', metroHospitalId, 'hospital',
          department: 'Emergency', room: 'ER-1'),
      _createPatient('metro_patient_06', 'Patricia', 'Martinez',
          metroHospitalId, 'hospital',
          department: 'Emergency', room: 'ER-2'),
      _createPatient('metro_patient_07', 'William', 'Anderson', metroHospitalId,
          'hospital',
          department: 'Emergency', room: 'ER-3'),
      _createPatient(
          'metro_patient_08', 'Jennifer', 'Thomas', metroHospitalId, 'hospital',
          department: 'Med-Surg', room: '201A'),
      _createPatient(
          'metro_patient_09', 'David', 'Jackson', metroHospitalId, 'hospital',
          department: 'Med-Surg', room: '201B'),
      _createPatient(
          'metro_patient_10', 'Susan', 'White', metroHospitalId, 'hospital',
          department: 'Med-Surg', room: '202A'),
    ];

    // City Care patients (8 total for 3+5 assignment)
    final cityPatients = [
      _createPatient(
          'city_patient_01', 'Betty', 'Harris', cityCareId, 'residence',
          address: '123 Oak Street, San Jose, CA 95123'),
      _createPatient(
          'city_patient_02', 'George', 'Clark', cityCareId, 'residence',
          address: '456 Pine Avenue, San Jose, CA 95112'),
      _createPatient(
          'city_patient_03', 'Dorothy', 'Lewis', cityCareId, 'residence',
          address: '789 Elm Drive, San Jose, CA 95118'),
      _createPatient(
          'city_patient_04', 'Kenneth', 'Walker', cityCareId, 'residence',
          address: '321 Maple Lane, San Jose, CA 95110'),
      _createPatient(
          'city_patient_05', 'Helen', 'Hall', cityCareId, 'residence',
          address: '654 Cedar Court, San Jose, CA 95134'),
      _createPatient(
          'city_patient_06', 'Frank', 'Allen', cityCareId, 'residence',
          address: '987 Birch Street, San Jose, CA 95131'),
      _createPatient(
          'city_patient_07', 'Carol', 'Young', cityCareId, 'residence',
          address: '147 Willow Way, San Jose, CA 95128'),
      _createPatient(
          'city_patient_08', 'Anthony', 'King', cityCareId, 'residence',
          address: '258 Ash Avenue, San Jose, CA 95112'),
    ];

    // Save Metro patients
    for (final patient in metroPatients) {
      await firestore
          .collection('agencies')
          .doc(metroHospitalId)
          .collection('patients')
          .doc(patient['id'] as String)
          .set(patient);
    }
    debugPrint('🏥 Created 10 Metro Hospital patients');

    // Save City patients
    for (final patient in cityPatients) {
      await firestore
          .collection('agencies')
          .doc(cityCareId)
          .collection('patients')
          .doc(patient['id'] as String)
          .set(patient);
    }
    debugPrint('🏠 Created 8 City Care patients');
  }

  /// Helper to create patient data
  static Map<String, dynamic> _createPatient(
    String id,
    String firstName,
    String lastName,
    String agencyId,
    String location, {
    String? department,
    String? room,
    String? address,
  }) {
    final patient = <String, dynamic>{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'mrn': 'MRN${id.substring(id.length - 3).toUpperCase()}',
      'location': location,
      'agencyId': agencyId,
      'isFallRisk': id.hashCode % 3 == 0, // Random fall risk
      'isIsolation': id.hashCode % 5 == 0, // Random isolation
      'biologicalSex': id.hashCode % 2 == 0 ? 'male' : 'female',
      'primaryDiagnoses': _getRandomDiagnoses(location),
      'allergies': _getRandomAllergies(),
      'dietRestrictions': _getRandomDietRestrictions(),
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': 'test_admin',
      'ownerUid': 'test_admin',
    };

    // Add location-specific fields
    if (location == 'hospital') {
      patient['department'] = department;
      patient['roomNumber'] = room;
    } else if (location == 'residence') {
      final addressParts = address?.split(', ') ?? ['Unknown Address'];
      patient['addressLine1'] = addressParts[0];
      if (addressParts.length > 1) {
        patient['city'] = addressParts[1];
      }
      if (addressParts.length > 2) {
        final stateZip = addressParts[2].split(' ');
        patient['state'] = stateZip[0];
        if (stateZip.length > 1) {
          patient['zip'] = stateZip[1];
        }
      }
    }

    return patient;
  }

  /// Create 4 shifts with exact patient assignments
  static Future<void> _createTestShifts(FirebaseFirestore firestore) async {
    final now = DateTime.now();

    final shifts = [
      // Metro Hospital Shift 1 - 4 patients (ICU focus)
      {
        'id': 'metro_shift_1',
        'agencyId': metroHospitalId,
        'location': 'Metro Hospital',
        'facilityName': 'Metro Hospital',
        'department': 'ICU',
        'addressLine1': '123 Medical Center Drive',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95128',
        'startTime': Timestamp.fromDate(now.add(const Duration(hours: 2))),
        'endTime': Timestamp.fromDate(now.add(const Duration(hours: 14))),
        'status': 'available',
        'requestedBy': [],
        'assignedPatientIds': [
          'metro_patient_01',
          'metro_patient_02',
          'metro_patient_03',
          'metro_patient_04',
        ], // 4 patients - ICU patients
        'isNightShift': false,
        'isWeekendShift': false,
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Metro Hospital Shift 2 - 6 patients (Emergency + Med-Surg)
      {
        'id': 'metro_shift_2',
        'agencyId': metroHospitalId,
        'location': 'Metro Hospital',
        'facilityName': 'Metro Hospital',
        'department': 'Emergency',
        'addressLine1': '123 Medical Center Drive',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95128',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 6))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 18))),
        'status': 'available',
        'requestedBy': [],
        'assignedPatientIds': [
          'metro_patient_05',
          'metro_patient_06',
          'metro_patient_07',
          'metro_patient_08',
          'metro_patient_09',
          'metro_patient_10',
        ], // 6 patients - Emergency + Med-Surg
        'isNightShift': false,
        'isWeekendShift': false,
        'createdAt': FieldValue.serverTimestamp(),
      },

      // City Care Shift 1 - 3 patients (Home health)
      {
        'id': 'city_shift_1',
        'agencyId': cityCareId,
        'location': 'Community Route A',
        'department': 'Community Care',
        'addressLine1': 'Various Addresses - Route A',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95123',
        'startTime': Timestamp.fromDate(now.add(const Duration(hours: 8))),
        'endTime': Timestamp.fromDate(now.add(const Duration(hours: 16))),
        'status': 'available',
        'requestedBy': [],
        'assignedPatientIds': [
          'city_patient_01',
          'city_patient_02',
          'city_patient_03',
        ], // 3 patients - Home visits
        'isNightShift': false,
        'isWeekendShift': false,
        'createdAt': FieldValue.serverTimestamp(),
      },

      // City Care Shift 2 - 5 patients (Extended home health route)
      {
        'id': 'city_shift_2',
        'agencyId': cityCareId,
        'location': 'Community Route B',
        'department': 'Community Care',
        'addressLine1': 'Various Addresses - Route B',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95112',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 7))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 19))),
        'status': 'available',
        'requestedBy': [],
        'assignedPatientIds': [
          'city_patient_04',
          'city_patient_05',
          'city_patient_06',
          'city_patient_07',
          'city_patient_08',
        ], // 5 patients - Extended route
        'isNightShift': false,
        'isWeekendShift': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final shift in shifts) {
      final agencyId = shift['agencyId'] as String;
      final shiftId = shift['id'] as String;
      final shiftData = Map<String, dynamic>.from(shift);
      shiftData.remove('id');

      await firestore
          .collection('agencies')
          .doc(agencyId)
          .collection('shifts')
          .doc(shiftId)
          .set(shiftData);

      final patientCount = (shift['assignedPatientIds'] as List).length;
      debugPrint('📅 Created shift: $shiftId with $patientCount patients');
    }
  }

  /// Create some scheduled shifts for testing
  static Future<void> _createTestScheduledShifts(
      FirebaseFirestore firestore) async {
    final now = DateTime.now();

    final scheduledShifts = [
      // Nurse A scheduled at Metro Hospital
      {
        'id': 'scheduled_metro_1',
        'agencyId': metroHospitalId,
        'assignedTo': nurseAId,
        'status': 'scheduled',
        'locationType': 'facility',
        'facilityName': 'Metro Hospital',
        'address': '123 Medical Center Drive, San Jose, CA 95128',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 2, hours: 7))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 2, hours: 19))),
        'isConfirmed': true,
        'assignedPatientIds': ['metro_patient_01', 'metro_patient_02'],
        'isUserCreated': false,
        'createdBy': 'test_admin',
        'createdAt': FieldValue.serverTimestamp(),
      },

      // Nurse B scheduled at City Care
      {
        'id': 'scheduled_city_1',
        'agencyId': cityCareId,
        'assignedTo': nurseBId,
        'status': 'scheduled',
        'locationType': 'residence',
        'address': 'Home Care Route - San Jose',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 3, hours: 8))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 3, hours: 16))),
        'isConfirmed': true,
        'assignedPatientIds': ['city_patient_01', 'city_patient_02'],
        'isUserCreated': false,
        'createdBy': 'test_admin',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final shift in scheduledShifts) {
      final agencyId = shift['agencyId'] as String;
      final shiftId = shift['id'] as String;
      final shiftData = Map<String, dynamic>.from(shift);
      shiftData.remove('id');

      await firestore
          .collection('agencies')
          .doc(agencyId)
          .collection('scheduledShifts')
          .doc(shiftId)
          .set(shiftData);

      debugPrint('📋 Created scheduled shift: $shiftId');
    }
  }

  /// Helper functions for random patient data
  static List<String> _getRandomDiagnoses(String location) {
    if (location == 'hospital') {
      final hospitalDiagnoses = <List<String>>[
        ['Pneumonia', 'COPD'],
        ['Heart Failure', 'Hypertension'],
        ['Diabetes', 'Kidney Disease'],
        ['Post-surgical recovery'],
        ['Sepsis', 'Infection'],
      ];
      return hospitalDiagnoses[
          DateTime.now().millisecond % hospitalDiagnoses.length];
    } else {
      final homeDiagnoses = <List<String>>[
        ['Diabetes Management'],
        ['Wound Care'],
        ['Medication Management'],
        ['Physical Therapy'],
        ['Chronic Pain Management'],
      ];
      return homeDiagnoses[DateTime.now().millisecond % homeDiagnoses.length];
    }
  }

  static List<String> _getRandomAllergies() {
    final allergies = <List<String>>[
      <String>[],
      <String>['Penicillin'],
      <String>['Shellfish'],
      <String>['Latex'],
      <String>['Penicillin', 'Shellfish'],
    ];
    return allergies[DateTime.now().microsecond % allergies.length];
  }

  static List<String> _getRandomDietRestrictions() {
    final restrictions = <List<String>>[
      <String>[],
      <String>['Diabetic'],
      <String>['Low sodium'],
      <String>['Heart healthy'],
      <String>['Low sodium', 'Diabetic'],
    ];
    return restrictions[DateTime.now().microsecond % restrictions.length];
  }

  /// Clear all test data
  static Future<void> clearTestData() async {
    final firestore = FirebaseFirestore.instance;

    debugPrint('🧹 Clearing shift-centric test data...');

    // Clear test users
    await firestore.collection('users').doc(nurseAId).delete();
    await firestore.collection('users').doc(nurseBId).delete();
    await firestore.collection('users').doc(nurseCId).delete();
    debugPrint('🗑️ Cleared test users');

    // Clear Metro Hospital data
    final metroPatientIds = List.generate(
        10, (i) => 'metro_patient_${(i + 1).toString().padLeft(2, '0')}');
    for (final patientId in metroPatientIds) {
      await firestore
          .collection('agencies')
          .doc(metroHospitalId)
          .collection('patients')
          .doc(patientId)
          .delete();
    }

    await firestore
        .collection('agencies')
        .doc(metroHospitalId)
        .collection('shifts')
        .doc('metro_shift_1')
        .delete();
    await firestore
        .collection('agencies')
        .doc(metroHospitalId)
        .collection('shifts')
        .doc('metro_shift_2')
        .delete();

    await firestore
        .collection('agencies')
        .doc(metroHospitalId)
        .collection('scheduledShifts')
        .doc('scheduled_metro_1')
        .delete();

    // Clear City Care data
    final cityPatientIds = List.generate(
        8, (i) => 'city_patient_${(i + 1).toString().padLeft(2, '0')}');
    for (final patientId in cityPatientIds) {
      await firestore
          .collection('agencies')
          .doc(cityCareId)
          .collection('patients')
          .doc(patientId)
          .delete();
    }

    await firestore
        .collection('agencies')
        .doc(cityCareId)
        .collection('shifts')
        .doc('city_shift_1')
        .delete();
    await firestore
        .collection('agencies')
        .doc(cityCareId)
        .collection('shifts')
        .doc('city_shift_2')
        .delete();

    await firestore
        .collection('agencies')
        .doc(cityCareId)
        .collection('scheduledShifts')
        .doc('scheduled_city_1')
        .delete();

    // Clear agencies
    await firestore.collection('agencies').doc(metroHospitalId).delete();
    await firestore.collection('agencies').doc(cityCareId).delete();

    debugPrint('✅ Shift-centric test data cleared!');
  }
}
