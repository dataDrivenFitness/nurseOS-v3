// lib/features/patient/data/firebase_patient_repository.dart
// FIXED: Use agency-scoped queries instead of collection group

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:nurseos_v3/core/error/failure.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model.dart';
import 'package:nurseos_v3/shared/converters/patient_converter.dart';
import 'abstract_patient_repository.dart';

class FirebasePatientRepository implements PatientRepository {
  final FirebaseFirestore _firestore;
  final UserModel _user;
  final String _agencyId;

  FirebasePatientRepository(this._firestore, this._user, this._agencyId);

  /// Agency-scoped collection reference with robust converter
  CollectionReference<Patient> get _patients => _firestore
      .collection('agencies')
      .doc(_agencyId)
      .collection('patients')
      .withConverter<Patient>(
        fromFirestore: PatientConverter.fromFirestore,
        toFirestore: PatientConverter.toFirestore,
      );

  /// Agency-scoped shifts collection reference
  CollectionReference<Map<String, dynamic>> get _shifts => _firestore
      .collection('agencies')
      .doc(_agencyId)
      .collection('scheduledShifts');

  /// 🔧 FIXED: Get all patients via agency-scoped scheduled shifts
  @override
  Future<Either<Failure, List<Patient>>> getAllPatients() async {
    try {
      print(
          '🔍 DEBUG: Starting getAllPatients for user: ${_user.uid} in agency: $_agencyId');

      // Step 1: Query the agency-scoped scheduledShifts collection
      final shiftsQuery = _firestore
          .collection('agencies')
          .doc(_agencyId)
          .collection('scheduledShifts')
          .where('assignedTo', isEqualTo: _user.uid);

      print('🔍 DEBUG: About to query scheduledShifts...');
      final shiftsSnapshot = await shiftsQuery.get();
      print('🔍 DEBUG: Found ${shiftsSnapshot.docs.length} scheduled shifts');

      if (shiftsSnapshot.docs.isEmpty) {
        print('🔍 DEBUG: No shifts found - returning empty list');
        return const Right([]);
      }

      // Step 2: Collect all patient IDs from shifts
      final patientIds = <String>{};
      for (final shiftDoc in shiftsSnapshot.docs) {
        try {
          final shiftData = shiftDoc.data();
          // Add document ID to data for ScheduledShiftModel parsing
          shiftData['id'] = shiftDoc.id;

          print(
              '🔍 DEBUG: Processing shift ${shiftDoc.id} with data keys: ${shiftData.keys.toList()}');

          final shift = ScheduledShiftModel.fromJson(shiftData);
          if (shift.assignedPatientIds != null) {
            patientIds.addAll(shift.assignedPatientIds!);
            print(
                '🔍 DEBUG: Shift ${shiftDoc.id} has patients: ${shift.assignedPatientIds}');
          } else {
            print('🔍 DEBUG: Shift ${shiftDoc.id} has no assigned patients');
          }
        } catch (e) {
          print('⚠️ Warning: Failed to parse shift ${shiftDoc.id}: $e');
          print('   Shift data: ${shiftDoc.data()}');
          // Continue processing other shifts
        }
      }

      if (patientIds.isEmpty) {
        print(
            '🔍 DEBUG: Shifts found but no patients assigned - returning empty list');
        return const Right([]);
      }

      print('🔍 DEBUG: Collected patient IDs: $patientIds');

      // Step 3: Query patients by collected IDs in current agency
      final patients = <Patient>[];
      final patientIdsList = patientIds.toList();

      // Process in batches of 10 (Firestore limit)
      for (int i = 0; i < patientIdsList.length; i += 10) {
        final batch = patientIdsList.skip(i).take(10).toList();
        print('🔍 DEBUG: Querying patient batch: $batch');

        final patientsQuery =
            _patients.where(FieldPath.documentId, whereIn: batch);
        final patientsSnapshot = await patientsQuery.get();

        print(
            '🔍 DEBUG: Found ${patientsSnapshot.docs.length} patients in batch');

        for (final patientDoc in patientsSnapshot.docs) {
          try {
            final patient = patientDoc.data();
            patients.add(patient);
            print(
                '🔍 DEBUG: Added patient: ${patient?.firstName} ${patient?.lastName}');
          } catch (e) {
            print('⚠️ Warning: Failed to parse patient ${patientDoc.id}: $e');
            // Continue processing other patients
          }
        }
      }

      print('🔍 DEBUG: Returning ${patients.length} patients total');
      return Right(patients);
    } on FirebaseException catch (e) {
      print('❌ FirebaseException in getAllPatients: ${e.code} - ${e.message}');
      return Left(Failure.unexpected(
          'Failed to fetch patients via shifts: ${e.message}'));
    } catch (e) {
      print('❌ Exception in getAllPatients: $e');
      return Left(Failure.unexpected(
          'Unexpected error in shift-based patient query: $e'));
    }
  }

  /// 🔧 FIXED: Stream all patients via agency-scoped shift queries
  @override
  Stream<Either<Failure, List<Patient>>> watchAllPatients() {
    try {
      print(
          '🔍 DEBUG: Starting watchAllPatients stream for user: ${_user.uid} in agency: $_agencyId');

      // Watch agency-scoped scheduledShifts collection
      return _firestore
          .collection('agencies')
          .doc(_agencyId)
          .collection('scheduledShifts')
          .where('assignedTo', isEqualTo: _user.uid)
          .snapshots()
          .asyncMap((shiftsSnapshot) async {
        try {
          print(
              '🔍 DEBUG: Shifts snapshot received: ${shiftsSnapshot.docs.length} shifts');

          if (shiftsSnapshot.docs.isEmpty) {
            print('🔍 DEBUG: No shifts in stream - returning empty list');
            return const Right<Failure, List<Patient>>([]);
          }

          // Collect patient IDs from current shifts
          final patientIds = <String>{};
          for (final shiftDoc in shiftsSnapshot.docs) {
            try {
              final shiftData = shiftDoc.data();
              shiftData['id'] = shiftDoc.id;

              final shift = ScheduledShiftModel.fromJson(shiftData);
              if (shift.assignedPatientIds != null) {
                patientIds.addAll(shift.assignedPatientIds!);
              }
            } catch (e) {
              print(
                  '⚠️ Warning: Failed to parse shift ${shiftDoc.id} in stream: $e');
            }
          }

          if (patientIds.isEmpty) {
            print(
                '🔍 DEBUG: No patients in shifts stream - returning empty list');
            return const Right<Failure, List<Patient>>([]);
          }

          print('🔍 DEBUG: Stream collected patient IDs: $patientIds');

          // Query patients in batches (Firestore whereIn limit = 10)
          final patients = <Patient>[];
          final patientIdsList = patientIds.toList();

          for (int i = 0; i < patientIdsList.length; i += 10) {
            final batch = patientIdsList.skip(i).take(10).toList();

            final patientsSnapshot = await _patients
                .where(FieldPath.documentId, whereIn: batch)
                .get();

            for (final patientDoc in patientsSnapshot.docs) {
              try {
                final patient = patientDoc.data();
                patients.add(patient);
              } catch (e) {
                print(
                    '⚠️ Warning: Failed to parse patient ${patientDoc.id} in stream: $e');
              }
            }
          }

          print('🔍 DEBUG: Stream returning ${patients.length} patients');
          return Right<Failure, List<Patient>>(patients);
        } catch (e) {
          print('❌ Error in watchAllPatients stream: $e');
          return Left<Failure, List<Patient>>(
            Failure.unexpected('Failed to stream patients via shifts: $e'),
          );
        }
      });
    } catch (e) {
      print('❌ Error setting up watchAllPatients stream: $e');
      return Stream.value(
        Left(Failure.unexpected(
            'Failed to watch shifts for patient streaming: $e')),
      );
    }
  }

  /// ✅ UNCHANGED: Single patient fetch (no assignedNurses dependency)
  @override
  Future<Either<Failure, Patient?>> fetchById(String id) async {
    try {
      final doc = await _patients.doc(id).get();

      if (!doc.exists) {
        return const Right(null);
      }

      return Right(doc.data());
    } on FirebaseException catch (e) {
      return Left(Failure.unexpected('Failed to fetch patient: ${e.message}'));
    } catch (e) {
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  /// ✅ UNCHANGED: Patient save (no assignedNurses dependency)
  @override
  Future<Either<Failure, void>> save(Patient patient) async {
    try {
      if (patient.id.isEmpty) {
        // Create new patient - ensure agencyId is set
        final patientWithAgency = patient.copyWith(
          agencyId: _agencyId,
          createdBy: _user.uid,
        );
        await _patients.add(patientWithAgency);
      } else {
        // Update existing patient - preserve agencyId
        final patientWithAgency = patient.copyWith(agencyId: _agencyId);
        await _patients.doc(patient.id).set(patientWithAgency);
      }
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(Failure.unexpected('Failed to save patient: ${e.message}'));
    } catch (e) {
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  /// ✅ UNCHANGED: Patient delete (no assignedNurses dependency)
  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await _patients.doc(id).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(Failure.unexpected('Failed to delete patient: ${e.message}'));
    } catch (e) {
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }
}
