// lib/features/agency/services/agency_migration_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AgencyMigrationService {
  static const String defaultAgencyId = 'default_agency';
  final FirebaseFirestore _firestore;

  AgencyMigrationService([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Main migration entry point
  Future<MigrationResult> runFullMigration() async {
    debugPrint('🚀 Starting NurseOS Multi-Agency Migration...');

    try {
      // Step 1: Create default agency
      await _createDefaultAgency();

      // Step 2: Migrate all users to have agency context
      final userResult = await _migrateUsers();

      // Step 3: Migrate patients to agency-scoped collections
      final patientResult = await _migratePatients();

      // Step 4: Migrate shifts to agency-scoped collections
      final shiftResult = await _migrateShifts();

      // Step 5: Migrate scheduled shifts
      final scheduledShiftResult = await _migrateScheduledShifts();

      // Step 6: Validate migration
      final validationResult = await _validateMigration();

      final totalResult = MigrationResult(
        usersProcessed: userResult.usersProcessed,
        patientsProcessed: patientResult.patientsProcessed,
        shiftsProcessed: shiftResult.shiftsProcessed,
        scheduledShiftsProcessed: scheduledShiftResult.scheduledShiftsProcessed,
        errors: [
          ...userResult.errors,
          ...patientResult.errors,
          ...shiftResult.errors,
          ...scheduledShiftResult.errors,
          ...validationResult.errors,
        ],
        success: validationResult.success &&
            userResult.errors.isEmpty &&
            patientResult.errors.isEmpty &&
            shiftResult.errors.isEmpty &&
            scheduledShiftResult.errors.isEmpty,
      );

      debugPrint('✅ Migration completed! Result: $totalResult');
      return totalResult;
    } catch (e, stackTrace) {
      debugPrint('❌ Migration failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return MigrationResult(
        success: false,
        errors: ['Migration failed: $e'],
      );
    }
  }

  /// Step 1: Create default agency document
  Future<void> _createDefaultAgency() async {
    debugPrint('📝 Creating default agency...');

    final agencyRef = _firestore.collection('agencies').doc(defaultAgencyId);
    final agencyDoc = await agencyRef.get();

    if (!agencyDoc.exists) {
      await agencyRef.set({
        'id': defaultAgencyId,
        'name': 'Default Agency',
        'type': 'hospital',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'description': 'Default agency created during migration',
        'settings': {
          'allowCrossAgencyTransfers': false,
          'requireShiftConfirmation': true,
        },
        'tags': <String>[],
      });
      debugPrint('✅ Default agency created');
    } else {
      debugPrint('ℹ️ Default agency already exists');
    }
  }

  /// Step 2: Add agency context to all users
  Future<MigrationResult> _migrateUsers() async {
    debugPrint('👥 Migrating users to multi-agency structure...');

    int processed = 0;
    List<String> errors = [];

    try {
      final usersSnapshot = await _firestore.collection('users').get();
      debugPrint('📊 Found ${usersSnapshot.docs.length} users to process');

      final batch = _firestore.batch();
      int batchCount = 0;

      for (final userDoc in usersSnapshot.docs) {
        try {
          final userData = userDoc.data();
          final userId = userDoc.id;

          // Check if user already has agency context
          if (userData['activeAgencyId'] != null ||
              userData['agencyRoles'] != null) {
            debugPrint('ℹ️ User $userId already has agency context, skipping');
            continue;
          }

          // Create AgencyRoleModel JSON structure
          final agencyRoleData = {
            'role': userData['role'] ??
                'nurse', // Use existing role or default to nurse
            'status': 'active',
            'department':
                userData['department'] ?? userData['unit'] ?? 'general',
            'unit': userData['unit'],
            'shift': userData['shift'],
            'assignedAt': FieldValue.serverTimestamp(),
            'joinedAt': FieldValue.serverTimestamp(),
            'lastActiveAt': FieldValue.serverTimestamp(),
            'permissions': <String>[], // Will be populated based on role
            'metadata': <String, dynamic>{
              'migratedFromLegacy': true,
              'originalRole': userData['role'],
              'originalDepartment': userData['department'],
              'originalUnit': userData['unit'],
            },
          };

          // Add agency context to user
          batch.update(userDoc.reference, {
            'activeAgencyId': defaultAgencyId,
            'agencyRoles': {
              defaultAgencyId: agencyRoleData,
            },
            'migratedAt': FieldValue.serverTimestamp(),
          });

          processed++;
          batchCount++;

          // Commit batch every 450 operations (Firestore limit is 500)
          if (batchCount >= 450) {
            await batch.commit();
            debugPrint('📦 Committed batch of $batchCount user updates');
            batchCount = 0;
          }
        } catch (e) {
          final error = 'Failed to process user ${userDoc.id}: $e';
          errors.add(error);
          debugPrint('❌ $error');
        }
      }

      // Commit remaining operations
      if (batchCount > 0) {
        await batch.commit();
        debugPrint('📦 Committed final batch of $batchCount user updates');
      }

      debugPrint(
          '✅ User migration completed: $processed processed, ${errors.length} errors');
    } catch (e) {
      errors.add('User migration failed: $e');
      debugPrint('❌ User migration failed: $e');
    }

    return MigrationResult(usersProcessed: processed, errors: errors);
  }

  /// Step 3: Migrate patients to agency-scoped collections
  Future<MigrationResult> _migratePatients() async {
    debugPrint('🏥 Migrating patients to agency-scoped collections...');

    int processed = 0;
    List<String> errors = [];

    try {
      final patientsSnapshot = await _firestore.collection('patients').get();
      debugPrint(
          '📊 Found ${patientsSnapshot.docs.length} patients to migrate');

      final batch = _firestore.batch();
      int batchCount = 0;

      for (final patientDoc in patientsSnapshot.docs) {
        try {
          final patientData = patientDoc.data();
          final patientId = patientDoc.id;

          // Ensure required fields are present with defaults
          final migratedData = {
            ...patientData,
            'id': patientId,
            'agencyId': defaultAgencyId,
            'migratedAt': FieldValue.serverTimestamp(),
            // Ensure required fields have defaults if missing
            'location': patientData['location'] ?? 'residence',
            'firstName': patientData['firstName'] ?? 'Unknown',
            'lastName': patientData['lastName'] ?? 'Patient',
            'isFallRisk': patientData['isFallRisk'] ?? false,
            'isIsolation': patientData['isIsolation'] ?? false,
            'biologicalSex': patientData['biologicalSex'] ?? 'unspecified',
            'primaryDiagnoses': patientData['primaryDiagnoses'] ?? [],
            'assignedNurses': patientData['assignedNurses'] ?? [],
            'allergies': patientData['allergies'] ?? [],
            'dietRestrictions': patientData['dietRestrictions'] ?? [],
            // Add creation timestamp if missing
            'createdAt':
                patientData['createdAt'] ?? FieldValue.serverTimestamp(),
          };

          // Create patient in agency subcollection
          final newPatientRef = _firestore
              .collection('agencies')
              .doc(defaultAgencyId)
              .collection('patients')
              .doc(patientId);

          batch.set(newPatientRef, migratedData);
          processed++;
          batchCount++;

          // Commit batch every 450 operations
          if (batchCount >= 450) {
            await batch.commit();
            debugPrint('📦 Committed batch of $batchCount patient migrations');
            batchCount = 0;
          }
        } catch (e) {
          final error = 'Failed to migrate patient ${patientDoc.id}: $e';
          errors.add(error);
          debugPrint('❌ $error');
        }
      }

      // Commit remaining operations
      if (batchCount > 0) {
        await batch.commit();
        debugPrint(
            '📦 Committed final batch of $batchCount patient migrations');
      }

      debugPrint(
          '✅ Patient migration completed: $processed processed, ${errors.length} errors');
    } catch (e) {
      errors.add('Patient migration failed: $e');
      debugPrint('❌ Patient migration failed: $e');
    }

    return MigrationResult(patientsProcessed: processed, errors: errors);
  }

  /// Step 4: Migrate shifts to agency-scoped collections
  Future<MigrationResult> _migrateShifts() async {
    debugPrint('📅 Migrating shifts to agency-scoped collections...');

    int processed = 0;
    List<String> errors = [];

    try {
      final shiftsSnapshot = await _firestore.collection('shifts').get();
      debugPrint('📊 Found ${shiftsSnapshot.docs.length} shifts to migrate');

      final batch = _firestore.batch();
      int batchCount = 0;

      for (final shiftDoc in shiftsSnapshot.docs) {
        try {
          final shiftData = shiftDoc.data();
          final shiftId = shiftDoc.id;

          // Ensure required fields are present with defaults
          final migratedData = {
            ...shiftData,
            'id': shiftId,
            'agencyId': defaultAgencyId,
            'migratedAt': FieldValue.serverTimestamp(),
            // Ensure required fields have defaults if missing
            'location': shiftData['location'] ?? 'Hospital',
            'status': shiftData['status'] ?? 'available',
            'requestedBy': shiftData['requestedBy'] ?? [],
            'isNightShift': shiftData['isNightShift'] ?? false,
            'isWeekendShift': shiftData['isWeekendShift'] ?? false,
            // Add creation timestamp if missing
            'createdAt': shiftData['createdAt'] ?? FieldValue.serverTimestamp(),
            // Ensure start/end times exist (required fields)
            if (shiftData['startTime'] == null)
              'startTime': FieldValue.serverTimestamp(),
            if (shiftData['endTime'] == null)
              'endTime': FieldValue.serverTimestamp(),
          };

          // Create shift in agency subcollection
          final newShiftRef = _firestore
              .collection('agencies')
              .doc(defaultAgencyId)
              .collection('shifts')
              .doc(shiftId);

          batch.set(newShiftRef, migratedData);
          processed++;
          batchCount++;

          // Commit batch every 450 operations
          if (batchCount >= 450) {
            await batch.commit();
            debugPrint('📦 Committed batch of $batchCount shift migrations');
            batchCount = 0;
          }
        } catch (e) {
          final error = 'Failed to migrate shift ${shiftDoc.id}: $e';
          errors.add(error);
          debugPrint('❌ $error');
        }
      }

      // Commit remaining operations
      if (batchCount > 0) {
        await batch.commit();
        debugPrint('📦 Committed final batch of $batchCount shift migrations');
      }

      debugPrint(
          '✅ Shift migration completed: $processed processed, ${errors.length} errors');
    } catch (e) {
      errors.add('Shift migration failed: $e');
      debugPrint('❌ Shift migration failed: $e');
    }

    return MigrationResult(shiftsProcessed: processed, errors: errors);
  }

  /// Step 5: Migrate scheduled shifts to agency-scoped collections
  Future<MigrationResult> _migrateScheduledShifts() async {
    debugPrint('📋 Migrating scheduled shifts to agency-scoped collections...');

    int processed = 0;
    List<String> errors = [];

    try {
      final scheduledShiftsSnapshot =
          await _firestore.collection('scheduledShifts').get();
      debugPrint(
          '📊 Found ${scheduledShiftsSnapshot.docs.length} scheduled shifts to migrate');

      final batch = _firestore.batch();
      int batchCount = 0;

      for (final shiftDoc in scheduledShiftsSnapshot.docs) {
        try {
          final shiftData = shiftDoc.data();
          final shiftId = shiftDoc.id;

          // Ensure required fields are present with defaults
          final migratedData = {
            ...shiftData,
            'id': shiftId,
            'agencyId': defaultAgencyId,
            'migratedAt': FieldValue.serverTimestamp(),
            // Ensure required fields have defaults if missing
            'assignedTo': shiftData['assignedTo'] ?? '',
            'status': shiftData['status'] ?? 'scheduled',
            'locationType': shiftData['locationType'] ?? 'facility',
            'isConfirmed': shiftData['isConfirmed'] ?? false,
            'assignedPatientIds': shiftData['assignedPatientIds'] ?? [],
            // Ensure start/end times exist (required fields)
            if (shiftData['startTime'] == null)
              'startTime': FieldValue.serverTimestamp(),
            if (shiftData['endTime'] == null)
              'endTime': FieldValue.serverTimestamp(),
          };

          // Create scheduled shift in agency subcollection
          final newShiftRef = _firestore
              .collection('agencies')
              .doc(defaultAgencyId)
              .collection('scheduledShifts')
              .doc(shiftId);

          batch.set(newShiftRef, migratedData);
          processed++;
          batchCount++;

          // Commit batch every 450 operations
          if (batchCount >= 450) {
            await batch.commit();
            debugPrint(
                '📦 Committed batch of $batchCount scheduled shift migrations');
            batchCount = 0;
          }
        } catch (e) {
          final error = 'Failed to migrate scheduled shift ${shiftDoc.id}: $e';
          errors.add(error);
          debugPrint('❌ $error');
        }
      }

      // Commit remaining operations
      if (batchCount > 0) {
        await batch.commit();
        debugPrint(
            '📦 Committed final batch of $batchCount scheduled shift migrations');
      }

      debugPrint(
          '✅ Scheduled shift migration completed: $processed processed, ${errors.length} errors');
    } catch (e) {
      errors.add('Scheduled shift migration failed: $e');
      debugPrint('❌ Scheduled shift migration failed: $e');
    }

    return MigrationResult(scheduledShiftsProcessed: processed, errors: errors);
  }

  /// Step 6: Validate migration results
  Future<MigrationResult> _validateMigration() async {
    debugPrint('🔍 Validating migration results...');

    List<String> errors = [];

    try {
      // Check default agency exists
      final agencyDoc =
          await _firestore.collection('agencies').doc(defaultAgencyId).get();
      if (!agencyDoc.exists) {
        errors.add('Default agency not created');
      }

      // Check users have agency context
      final usersWithoutAgency = await _firestore
          .collection('users')
          .where('activeAgencyId', isNull: true)
          .get();

      if (usersWithoutAgency.docs.isNotEmpty) {
        errors.add(
            '${usersWithoutAgency.docs.length} users still missing agency context');
      }

      // Count totals for comparison
      final originalPatients =
          await _firestore.collection('patients').count().get();
      final migratedPatients = await _firestore
          .collection('agencies')
          .doc(defaultAgencyId)
          .collection('patients')
          .count()
          .get();

      final originalShifts =
          await _firestore.collection('shifts').count().get();
      final migratedShifts = await _firestore
          .collection('agencies')
          .doc(defaultAgencyId)
          .collection('shifts')
          .count()
          .get();

      debugPrint('📊 Validation Results:');
      debugPrint(
          '   - Original patients: ${originalPatients.count}, Migrated: ${migratedPatients.count}');
      debugPrint(
          '   - Original shifts: ${originalShifts.count}, Migrated: ${migratedShifts.count}');

      if (originalPatients.count != migratedPatients.count) {
        errors.add(
            'Patient count mismatch: ${originalPatients.count} original vs ${migratedPatients.count} migrated');
      }

      if (originalShifts.count != migratedShifts.count) {
        errors.add(
            'Shift count mismatch: ${originalShifts.count} original vs ${migratedShifts.count} migrated');
      }

      final success = errors.isEmpty;
      debugPrint(success
          ? '✅ Validation passed'
          : '❌ Validation failed with ${errors.length} errors');
    } catch (e) {
      errors.add('Validation failed: $e');
      debugPrint('❌ Validation error: $e');
    }

    return MigrationResult(errors: errors, success: errors.isEmpty);
  }

  /// Check if migration has already been completed
  Future<bool> isMigrationComplete() async {
    try {
      // Check if default agency exists
      final agencyDoc =
          await _firestore.collection('agencies').doc(defaultAgencyId).get();
      if (!agencyDoc.exists) return false;

      // Check if any agency-scoped data exists
      final agencyPatients = await _firestore
          .collection('agencies')
          .doc(defaultAgencyId)
          .collection('patients')
          .limit(1)
          .get();

      final agencyShifts = await _firestore
          .collection('agencies')
          .doc(defaultAgencyId)
          .collection('shifts')
          .limit(1)
          .get();

      return agencyPatients.docs.isNotEmpty || agencyShifts.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking migration status: $e');
      return false;
    }
  }

  /// Safe rollback - keeps original data, removes migrated data
  Future<void> rollbackMigration() async {
    debugPrint('🔄 Rolling back migration...');

    try {
      // Remove agency-scoped collections
      await _deleteCollection('agencies/$defaultAgencyId/patients');
      await _deleteCollection('agencies/$defaultAgencyId/shifts');
      await _deleteCollection('agencies/$defaultAgencyId/scheduledShifts');

      // Remove agency context from users (keep original data)
      final usersSnapshot = await _firestore.collection('users').get();
      final batch = _firestore.batch();

      for (final userDoc in usersSnapshot.docs) {
        batch.update(userDoc.reference, {
          'activeAgencyId': FieldValue.delete(),
          'agencyRoles': FieldValue.delete(),
          'migratedAt': FieldValue.delete(),
        });
      }

      await batch.commit();

      // Remove default agency
      await _firestore.collection('agencies').doc(defaultAgencyId).delete();

      debugPrint('✅ Rollback completed');
    } catch (e) {
      debugPrint('❌ Rollback failed: $e');
      rethrow;
    }
  }

  /// Helper to delete a collection
  Future<void> _deleteCollection(String path) async {
    final collectionRef = _firestore.collection(path);
    final batch = _firestore.batch();

    final snapshot = await collectionRef.get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    debugPrint('🗑️ Deleted collection: $path');
  }
}

/// Migration result data class
class MigrationResult {
  final int usersProcessed;
  final int patientsProcessed;
  final int shiftsProcessed;
  final int scheduledShiftsProcessed;
  final List<String> errors;
  final bool success;

  const MigrationResult({
    this.usersProcessed = 0,
    this.patientsProcessed = 0,
    this.shiftsProcessed = 0,
    this.scheduledShiftsProcessed = 0,
    this.errors = const [],
    this.success = true,
  });

  @override
  String toString() {
    return 'MigrationResult(users: $usersProcessed, patients: $patientsProcessed, '
        'shifts: $shiftsProcessed, scheduledShifts: $scheduledShiftsProcessed, '
        'errors: ${errors.length}, success: $success)';
  }
}
