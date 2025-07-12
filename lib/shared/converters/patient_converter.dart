// lib/features/patient/data/patient_converter.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';

/// Robust converter for Patient models with comprehensive error handling
class PatientConverter {
  /// Convert Firestore document to Patient model with full error handling
  static Patient fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, _) {
    final rawData = snapshot.data();

    if (rawData == null) {
      throw Exception('Patient document ${snapshot.id} has no data');
    }

    try {
      // Create a safe copy with proper type handling
      final data = _createSafeDataMap(rawData, snapshot.id);

      if (kDebugMode) {
        print('🏥 Converting patient ${snapshot.id}:');
        print('  - Raw fields: ${rawData.keys.toList()}');
        print('  - Processed fields: ${data.keys.toList()}');
        _debugPrintCriticalFields(data);
      }

      return Patient.fromJson(data);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error converting patient ${snapshot.id}: $e');
        print('Raw data: $rawData');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Convert Patient model to Firestore format
  static Map<String, dynamic> toFirestore(Patient patient, _) {
    final json = patient.toJson();
    // Remove the ID field since Firestore handles that
    json.remove('id');
    return json;
  }

  /// Create a safe data map with proper type conversions and defaults
  static Map<String, dynamic> _createSafeDataMap(
      Map<String, dynamic> rawData, String docId) {
    final data = <String, dynamic>{};

    // Set document ID first
    data['id'] = docId;

    // Process each field with type safety
    _setStringField(data, rawData, 'firstName', required: true);
    _setStringField(data, rawData, 'lastName', required: true);
    _setStringField(data, rawData, 'location',
        required: true, defaultValue: 'residence');

    // Optional string fields
    _setStringField(data, rawData, 'mrn');
    _setStringField(data, rawData, 'agencyId'); // 🏢 Multi-agency support
    _setStringField(data, rawData, 'codeStatus');
    _setStringField(data, rawData, 'pronouns');
    _setStringField(data, rawData, 'photoUrl');
    _setStringField(data, rawData, 'language');
    _setStringField(data, rawData, 'ownerUid');
    _setStringField(data, rawData, 'createdBy');
    _setStringField(data, rawData, 'department');
    _setStringField(data, rawData, 'roomNumber');
    _setStringField(data, rawData, 'addressLine1');
    _setStringField(data, rawData, 'addressLine2');
    _setStringField(data, rawData, 'city');
    _setStringField(data, rawData, 'state');
    _setStringField(data, rawData, 'zip');
    _setStringField(data, rawData, 'biologicalSex',
        defaultValue: 'unspecified');

    // Boolean fields
    _setBoolField(data, rawData, 'isFallRisk', defaultValue: false);
    _setBoolField(data, rawData, 'isIsolation', defaultValue: false);

    // List fields - ⭐ REMOVED assignedNurses per shift-centric architecture
    _setListField(data, rawData, 'primaryDiagnoses');
    _setListField(data, rawData, 'allergies');
    _setListField(data, rawData, 'dietRestrictions');

    // Timestamp fields (keep as-is, TimestampConverter will handle them)
    data['admittedAt'] = rawData['admittedAt'];
    data['lastSeen'] = rawData['lastSeen'];
    data['createdAt'] = rawData['createdAt'];
    data['birthDate'] = rawData['birthDate'];

    // Special fields
    data['manualRiskOverride'] = rawData['manualRiskOverride'];

    return data;
  }

  /// Safely set a string field with proper null/empty handling
  static void _setStringField(
    Map<String, dynamic> data,
    Map<String, dynamic> source,
    String fieldName, {
    bool required = false,
    String? defaultValue,
  }) {
    final value = source[fieldName];

    if (value == null || (value is String && value.isEmpty)) {
      if (required) {
        if (defaultValue != null) {
          data[fieldName] = defaultValue;
        } else {
          throw Exception('Required field $fieldName is null/empty');
        }
      } else {
        data[fieldName] =
            defaultValue; // null for optional fields unless defaultValue provided
      }
    } else if (value is String) {
      data[fieldName] = value;
    } else {
      // Convert to string if not already
      data[fieldName] = value.toString();
    }
  }

  /// Safely set a boolean field
  static void _setBoolField(
    Map<String, dynamic> data,
    Map<String, dynamic> source,
    String fieldName, {
    bool defaultValue = false,
  }) {
    final value = source[fieldName];

    if (value == null) {
      data[fieldName] = defaultValue;
    } else if (value is bool) {
      data[fieldName] = value;
    } else if (value is String) {
      data[fieldName] = value.toLowerCase() == 'true';
    } else {
      data[fieldName] = defaultValue;
    }
  }

  /// Safely set a list field
  static void _setListField(
    Map<String, dynamic> data,
    Map<String, dynamic> source,
    String fieldName,
  ) {
    final value = source[fieldName];

    if (value == null) {
      data[fieldName] = <String>[];
    } else if (value is List) {
      data[fieldName] = value
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (value is String) {
      if (value.isEmpty) {
        data[fieldName] = <String>[];
      } else {
        // Handle comma-separated values
        data[fieldName] = value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } else {
      // Single non-string value
      data[fieldName] = [value.toString()];
    }
  }

  /// Debug print critical fields
  static void _debugPrintCriticalFields(Map<String, dynamic> data) {
    print('  🔍 Critical fields:');
    print('    - id: ${data['id']} (${data['id']?.runtimeType})');
    print(
        '    - firstName: ${data['firstName']} (${data['firstName']?.runtimeType})');
    print(
        '    - lastName: ${data['lastName']} (${data['lastName']?.runtimeType})');
    print(
        '    - location: ${data['location']} (${data['location']?.runtimeType})');
    print(
        '    - agencyId: ${data['agencyId']} (${data['agencyId']?.runtimeType})');
    print(
        '    - biologicalSex: ${data['biologicalSex']} (${data['biologicalSex']?.runtimeType})');
  }
}
