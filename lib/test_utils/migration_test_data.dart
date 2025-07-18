// lib/test_utils/migration_test_data.dart
// UPDATED: Enhanced shift test data with urgency levels, coverage requests, and emergency shifts
// CHANGED: Reduced to 1 coverage request, converted city_coverage_1 to regular shift

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
  static const String nurseDId = 'GK2p0eU6yRRWKtdx4NC6UIsM7s22'; // No agency

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

  static Future<void> generateTestData([String? targetAgencyId]) async {
    final firestore = FirebaseFirestore.instance;

    debugPrint('🧪 Generating enhanced shift-centric test data...');

    // Create the 2 agencies with nurseIds
    await _createTestAgencies(firestore);

    // Create 3 nurses (without agencyRoles)
    await _createTestNurses(firestore);

    // Create patients (18 total: 10 for Metro, 8 for City)
    await _createTestPatients(firestore);

    // Create 8 enhanced shifts with emergency, coverage, and regular types
    await _createEnhancedTestShifts(firestore);

    // Create scheduled shifts for testing
    await _createTestScheduledShifts(firestore);

    debugPrint('✅ Enhanced shift-centric test data generation complete!');
    debugPrint(
        '📊 Created: 2 agencies, 3 nurses, 18 patients, 8 shifts (3 emergency, 1 coverage, 4 regular)');
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

  /// Create 4 nurses with simplified structure (no agencyRoles)
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

      // Nurse D - Priya Patel (Independent only - no agency)
      {
        'uid': 'GK2p0eU6yRRWKtdx4NC6UIsM7s22',
        'firstName': 'Priya',
        'lastName': 'Patel',
        'email': 'pri@app.com',
        'role': 'nurse',
        'licenseNumber': 'RN567890',
        'licenseExpiry': now.add(const Duration(days: 365)).toIso8601String(),
        'specialty': 'Telehealth',
        'department': 'Remote Care',
        'shift': 'flex',
        'phoneExtension': '4321',
        'isIndependentNurse': true,
        'level': 4,
        'xp': 950,
        'badges': ['independent_practice', 'remote_ready'],
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
    // Metro Hospital patients (10 total for various assignments)
    final metroPatients = [
      _createPatient(
          'metro_patient_01', 'John', 'Smith', metroHospitalId, 'hospital',
          department: 'ICU', room: '301A', isHighRisk: true, isIsolation: true),
      _createPatient(
          'metro_patient_02', 'Mary', 'Wilson', metroHospitalId, 'hospital',
          department: 'ICU', room: '301B', isHighRisk: true, isFallRisk: true),
      _createPatient(
          'metro_patient_03', 'Robert', 'Davis', metroHospitalId, 'hospital',
          department: 'ICU', room: '302A', isHighRisk: true),
      _createPatient(
          'metro_patient_04', 'Linda', 'Brown', metroHospitalId, 'hospital',
          department: 'ICU', room: '302B', isFallRisk: true),
      _createPatient(
          'metro_patient_05', 'James', 'Taylor', metroHospitalId, 'hospital',
          department: 'Emergency',
          room: 'ER-1',
          isHighRisk: true,
          isIsolation: true),
      _createPatient('metro_patient_06', 'Patricia', 'Martinez',
          metroHospitalId, 'hospital',
          department: 'Emergency', room: 'ER-2', isHighRisk: true),
      _createPatient('metro_patient_07', 'William', 'Anderson', metroHospitalId,
          'hospital',
          department: 'Emergency', room: 'ER-3', isFallRisk: true),
      _createPatient(
          'metro_patient_08', 'Jennifer', 'Thomas', metroHospitalId, 'hospital',
          department: 'Med-Surg', room: '201A'),
      _createPatient(
          'metro_patient_09', 'David', 'Jackson', metroHospitalId, 'hospital',
          department: 'Med-Surg', room: '201B', isFallRisk: true),
      _createPatient(
          'metro_patient_10', 'Susan', 'White', metroHospitalId, 'hospital',
          department: 'Med-Surg', room: '202A'),
    ];

    // City Care patients (8 total for various assignments)
    final cityPatients = [
      _createPatient(
          'city_patient_01', 'Betty', 'Harris', cityCareId, 'residence',
          address: '123 Oak Street, San Jose, CA 95123', isFallRisk: true),
      _createPatient(
          'city_patient_02', 'George', 'Clark', cityCareId, 'residence',
          address: '456 Pine Avenue, San Jose, CA 95112'),
      _createPatient(
          'city_patient_03', 'Dorothy', 'Lewis', cityCareId, 'residence',
          address: '789 Elm Drive, San Jose, CA 95118', isIsolation: true),
      _createPatient(
          'city_patient_04', 'Kenneth', 'Walker', cityCareId, 'residence',
          address: '321 Maple Lane, San Jose, CA 95110'),
      _createPatient(
          'city_patient_05', 'Helen', 'Hall', cityCareId, 'residence',
          address: '654 Cedar Court, San Jose, CA 95134', isFallRisk: true),
      _createPatient(
          'city_patient_06', 'Frank', 'Allen', cityCareId, 'residence',
          address: '987 Birch Street, San Jose, CA 95131'),
      _createPatient(
          'city_patient_07', 'Carol', 'Young', cityCareId, 'residence',
          address: '147 Willow Way, San Jose, CA 95128'),
      _createPatient(
          'city_patient_08', 'Anthony', 'King', cityCareId, 'residence',
          address: '258 Ash Avenue, San Jose, CA 95112', isFallRisk: true),
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
    bool isHighRisk = false,
    bool isFallRisk = false,
    bool isIsolation = false,
  }) {
    final patient = <String, dynamic>{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'mrn': 'MRN${id.substring(id.length - 3).toUpperCase()}',
      'location': location,
      'agencyId': agencyId,
      'isFallRisk': isFallRisk,
      'isIsolation': isIsolation,
      'biologicalSex': id.hashCode % 2 == 0 ? 'male' : 'female',
      'primaryDiagnoses': _getRandomDiagnoses(location),
      'allergies': _getRandomAllergies(),
      'dietRestrictions': _getRandomDietRestrictions(),
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': 'test_admin',
      'ownerUid': 'test_admin',
    };

    // Add manual risk override for high risk patients
    if (isHighRisk) {
      patient['manualRiskOverride'] = 'RiskLevel.high'; // Match enum format
    }

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

  /// Create 8 enhanced shifts with emergency, coverage, and regular types
  static Future<void> _createEnhancedTestShifts(
      FirebaseFirestore firestore) async {
    final now = DateTime.now();

    final shifts = [
      // 🚨 EMERGENCY SHIFTS (3 total)

      // Emergency 1 - Metro Hospital ICU Critical Staffing
      {
        'id': 'metro_emergency_1',
        'agencyId': metroHospitalId,
        'location': 'Metro Hospital',
        'facilityName': 'Metro Hospital',
        'department': 'ICU',
        'unit': 'Unit 3A',
        'addressLine1': '123 Medical Center Drive',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95128',
        'startTime': Timestamp.fromDate(now.add(const Duration(hours: 2))),
        'endTime': Timestamp.fromDate(now.add(const Duration(hours: 14))),
        'status': 'available',
        'urgencyLevel': 'emergency',
        'requestedBy': [],
        'assignedPatientIds': [
          'metro_patient_01',
          'metro_patient_02',
          'metro_patient_03',
          'metro_patient_04'
        ],
        'specialRequirements':
            'Urgent: Nurse called in sick. Critical care experience preferred. COVID patients.',
        'hourlyRate': 45.0,
        'urgencyBonus': 15.0,
        'requiredCertifications': ['BLS', 'ACLS', 'Critical Care'],
        'isNightShift': false,
        'isWeekendShift': false,
        'createdAt':
            Timestamp.fromDate(now.subtract(const Duration(minutes: 23))),
        'createdBy': 'test_admin',
      },

      // Emergency 2 - Metro Hospital Emergency Department
      {
        'id': 'metro_emergency_2',
        'agencyId': metroHospitalId,
        'location': 'Metro Hospital',
        'facilityName': 'Metro Hospital',
        'department': 'Emergency Department',
        'addressLine1': '123 Medical Center Drive',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95128',
        'startTime': Timestamp.fromDate(now.add(const Duration(minutes: 45))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(hours: 8, minutes: 45))),
        'status': 'available',
        'urgencyLevel': 'emergency',
        'requestedBy': [nurseCId],
        'assignedPatientIds': [
          'metro_patient_05',
          'metro_patient_06',
          'metro_patient_07',
          'metro_patient_08',
          'metro_patient_09',
          'metro_patient_10'
        ],
        'specialRequirements':
            'Emergency: Multiple trauma incoming. ACLS certification required.',
        'hourlyRate': 48.0,
        'urgencyBonus': 20.0,
        'requiredCertifications': ['BLS', 'ACLS', 'PALS'],
        'isNightShift': false,
        'isWeekendShift': false,
        'createdAt':
            Timestamp.fromDate(now.subtract(const Duration(minutes: 8))),
        'createdBy': 'test_admin',
      },

      // Emergency 3 - City Care Urgent Home Health
      {
        'id': 'city_emergency_1',
        'agencyId': cityCareId,
        'location': 'Emergency Home Health Route',
        'department': 'Community Care',
        'addressLine1': 'Various Addresses - Emergency Route',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95123',
        'startTime': Timestamp.fromDate(now.add(const Duration(hours: 1))),
        'endTime': Timestamp.fromDate(now.add(const Duration(hours: 9))),
        'status': 'available',
        'urgencyLevel': 'emergency',
        'requestedBy': [],
        'assignedPatientIds': ['city_patient_01', 'city_patient_03'],
        'specialRequirements':
            'Emergency: Nurse called out sick. Isolation precautions required for one patient.',
        'hourlyRate': 42.0,
        'urgencyBonus': 12.0,
        'requiredCertifications': ['BLS'],
        'isNightShift': false,
        'isWeekendShift': false,
        'createdAt': Timestamp.fromDate(
            now.subtract(const Duration(hours: 1, minutes: 15))),
        'createdBy': 'test_admin',
      },

      // 🆘 COVERAGE REQUEST SHIFTS (1 total)

      // Coverage 1 - Metro Hospital Med-Surg (Sarah needs coverage)
      {
        'id': 'metro_coverage_1',
        'agencyId': metroHospitalId,
        'location': 'Metro Hospital',
        'facilityName': 'Metro Hospital',
        'department': 'Med-Surg',
        'unit': 'Floor 4',
        'addressLine1': '123 Medical Center Drive',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95128',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 7))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 1, hours: 19))),
        'status': 'available',
        'urgencyLevel': 'coverage',
        'requestingNurseId': nurseAId,
        'requestingNurseNote':
            'Family emergency came up. Would really appreciate the help! Patients are stable.',
        'requestedBy': [],
        'assignedPatientIds': [
          'metro_patient_08',
          'metro_patient_09',
          'metro_patient_10'
        ],
        'hourlyRate': 42.0,
        'requiredCertifications': ['BLS'],
        'isNightShift': false,
        'isWeekendShift': false,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
        'createdBy': nurseAId,
      },

      // 📅 REGULAR OPEN SHIFTS (4 total)

      // Regular 1 - Metro Hospital Med-Surg
      {
        'id': 'metro_regular_1',
        'agencyId': metroHospitalId,
        'location': 'Metro Hospital',
        'facilityName': 'Metro Hospital',
        'department': 'Med-Surg',
        'unit': 'Floor 3',
        'addressLine1': '123 Medical Center Drive',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95128',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 3, hours: 7))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 3, hours: 19))),
        'status': 'available',
        'urgencyLevel': 'regular',
        'requestedBy': [],
        'assignedPatientIds': ['metro_patient_08', 'metro_patient_09'],
        'hourlyRate': 40.0,
        'requiredCertifications': ['BLS'],
        'isNightShift': false,
        'isWeekendShift': false,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'createdBy': 'test_admin',
      },

      // Regular 2 - City Care Community Health Center
      {
        'id': 'city_regular_1',
        'agencyId': cityCareId,
        'location': 'Community Health Center',
        'facilityName': 'Community Health Center',
        'department': 'Outpatient Clinic',
        'addressLine1': '789 Community Way',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95112',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 4, hours: 8))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 4, hours: 16))),
        'status': 'available',
        'urgencyLevel': 'regular',
        'requestedBy': [],
        'assignedPatientIds': [],
        'specialRequirements':
            'Routine outpatient appointments. Great for nurses who prefer clinic setting.',
        'hourlyRate': 38.0,
        'requiredCertifications': ['BLS'],
        'isNightShift': false,
        'isWeekendShift': false,
        'createdAt': Timestamp.fromDate(
            now.subtract(const Duration(days: 1, hours: 12))),
        'createdBy': 'test_admin',
      },

      // Regular 3 - City Care Pediatric Clinic (Weekend)
      {
        'id': 'city_regular_2',
        'agencyId': cityCareId,
        'location': 'Pediatric Clinic',
        'facilityName': 'Pediatric Clinic',
        'department': 'Children\'s Care Unit',
        'addressLine1': '321 Family Health Drive',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95134',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 5, hours: 12))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 5, hours: 20))),
        'status': 'available',
        'urgencyLevel': 'regular',
        'requestedBy': [],
        'assignedPatientIds': [
          'city_patient_02',
          'city_patient_04',
          'city_patient_06',
          'city_patient_07',
          'city_patient_08'
        ],
        'specialRequirements':
            'Great for nurses who love working with children. PALS certification preferred.',
        'hourlyRate': 40.0,
        'urgencyBonus': 5.0,
        'requiredCertifications': ['BLS', 'PALS'],
        'isNightShift': false,
        'isWeekendShift': true,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 3))),
        'createdBy': 'test_admin',
      },

      // Regular 4 - City Care Route (Former Coverage Request - Now Regular)
      {
        'id': 'city_regular_3',
        'agencyId': cityCareId,
        'location': 'Community Route B',
        'department': 'Community Care',
        'addressLine1': 'Various Addresses - Route B',
        'city': 'San Jose',
        'state': 'CA',
        'zip': '95112',
        'startTime':
            Timestamp.fromDate(now.add(const Duration(days: 2, hours: 8))),
        'endTime':
            Timestamp.fromDate(now.add(const Duration(days: 2, hours: 16))),
        'status': 'available',
        'urgencyLevel': 'regular',
        'requestedBy': [],
        'assignedPatientIds': [
          'city_patient_04',
          'city_patient_05',
          'city_patient_06'
        ],
        'specialRequirements':
            'Routine home health visits. Good for nurses familiar with community care.',
        'hourlyRate': 38.0,
        'requiredCertifications': ['BLS'],
        'isNightShift': false,
        'isWeekendShift': false,
        'createdAt': Timestamp.fromDate(
            now.subtract(const Duration(hours: 4, minutes: 30))),
        'createdBy': 'test_admin',
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
      final urgencyLevel = shift['urgencyLevel'] as String;
      debugPrint(
          '📅 Created $urgencyLevel shift: $shiftId with $patientCount patients');
    }

    debugPrint('🎯 Created shifts breakdown:');
    debugPrint('  🚨 Emergency: 3 shifts');
    debugPrint('  🆘 Coverage: 1 shift');
    debugPrint('  📅 Regular: 4 shifts');
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

  /// Clear all test data
  static Future<void> clearTestData() async {
    final firestore = FirebaseFirestore.instance;

    debugPrint('🧹 Clearing enhanced shift-centric test data...');

    // Clear test users
    await firestore.collection('users').doc(nurseAId).delete();
    await firestore.collection('users').doc(nurseBId).delete();
    await firestore.collection('users').doc(nurseCId).delete();
    await firestore.collection('users').doc(nurseDId).delete();
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

    // Clear Metro shifts (emergency, coverage, regular)
    final metroShiftIds = [
      'metro_emergency_1',
      'metro_emergency_2',
      'metro_coverage_1',
      'metro_regular_1',
    ];
    for (final shiftId in metroShiftIds) {
      await firestore
          .collection('agencies')
          .doc(metroHospitalId)
          .collection('shifts')
          .doc(shiftId)
          .delete();
    }

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

    // Clear City shifts (emergency, regular) - Updated shift list
    final cityShiftIds = [
      'city_emergency_1',
      'city_regular_1',
      'city_regular_2',
      'city_regular_3', // Updated from city_coverage_1
    ];
    for (final shiftId in cityShiftIds) {
      await firestore
          .collection('agencies')
          .doc(cityCareId)
          .collection('shifts')
          .doc(shiftId)
          .delete();
    }

    await firestore
        .collection('agencies')
        .doc(cityCareId)
        .collection('scheduledShifts')
        .doc('scheduled_city_1')
        .delete();

    // Clear agencies
    await firestore.collection('agencies').doc(metroHospitalId).delete();
    await firestore.collection('agencies').doc(cityCareId).delete();

    debugPrint('✅ Enhanced shift-centric test data cleared!');
    debugPrint('🗑️ Cleared: 2 agencies, 4 nurses, 18 patients, 8 shifts');
  }
}
