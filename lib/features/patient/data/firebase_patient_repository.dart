// lib/features/patient/data/firebase_patient_repository.dart
// FIXED: Use shift-centric queries across all agencies

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

  FirebasePatientRepository(this._firestore, this._user);

  /// Get all patients via shift-centric architecture across all agencies
  @override
  Future<Either<Failure, List<Patient>>> getAllPatients() async {
    try {
      print('🔍 DEBUG: Starting getAllPatients for user: ${_user.uid}');

      // Step 1: Query ALL scheduledShifts across agencies using collection group
      final shiftsQuery = _firestore
          .collectionGroup('scheduledShifts')
          .where('assignedTo', isEqualTo: _user.uid);

      print('🔍 DEBUG: About to query scheduledShifts across all agencies...');
      final shiftsSnapshot = await shiftsQuery.get();
      print('🔍 DEBUG: Found ${shiftsSnapshot.docs.length} scheduled shifts');

      if (shiftsSnapshot.docs.isEmpty) {
        print('🔍 DEBUG: No shifts found - returning empty list');
        return const Right([]);
      }

      // Step 2: Collect all patient IDs and their agency context from shifts
      final patientsByAgency = <String, Set<String>>{};
      for (final shiftDoc in shiftsSnapshot.docs) {
        try {
          final shiftData = shiftDoc.data();
          shiftData['id'] = shiftDoc.id;

          // Extract agency ID from document path
          final pathSegments = shiftDoc.reference.path.split('/');
          String? agencyId;
          if (pathSegments.length >= 2 && pathSegments[0] == 'agencies') {
            agencyId = pathSegments[1];
          }

          if (agencyId == null) {
            print(
                '⚠️ Warning: Could not extract agency ID from shift path: ${shiftDoc.reference.path}');
            continue;
          }

          print(
              '🔍 DEBUG: Processing shift ${shiftDoc.id} from agency: $agencyId');

          final shift = ScheduledShiftModel.fromJson(shiftData);
          if (shift.assignedPatientIds != null &&
              shift.assignedPatientIds!.isNotEmpty) {
            patientsByAgency.putIfAbsent(agencyId, () => <String>{});
            patientsByAgency[agencyId]!.addAll(shift.assignedPatientIds!);
            print(
                '🔍 DEBUG: Shift ${shiftDoc.id} has patients: ${shift.assignedPatientIds}');
          } else {
            print('🔍 DEBUG: Shift ${shiftDoc.id} has no assigned patients');
          }
        } catch (e) {
          print('⚠️ Warning: Failed to parse shift ${shiftDoc.id}: $e');
          print('   Shift data: ${shiftDoc.data()}');
          continue;
        }
      }

      if (patientsByAgency.isEmpty) {
        print(
            '🔍 DEBUG: Shifts found but no patients assigned - returning empty list');
        return const Right([]);
      }

      print(
          '🔍 DEBUG: Collected patients by agency: ${patientsByAgency.map((k, v) => MapEntry(k, v.length))}');

      // Step 3: Query patients from each agency
      final patients = <Patient>[];

      for (final agencyEntry in patientsByAgency.entries) {
        final agencyId = agencyEntry.key;
        final patientIds = agencyEntry.value.toList();

        print(
            '🔍 DEBUG: Querying ${patientIds.length} patients from agency: $agencyId');

        final agencyPatientsCollection = _firestore
            .collection('agencies')
            .doc(agencyId)
            .collection('patients')
            .withConverter<Patient>(
              fromFirestore: PatientConverter.fromFirestore,
              toFirestore: PatientConverter.toFirestore,
            );

        // Process in batches of 10 (Firestore limit)
        for (int i = 0; i < patientIds.length; i += 10) {
          final batch = patientIds.skip(i).take(10).toList();
          print(
              '🔍 DEBUG: Querying patient batch: $batch from agency: $agencyId');

          final patientsQuery = agencyPatientsCollection
              .where(FieldPath.documentId, whereIn: batch);
          final patientsSnapshot = await patientsQuery.get();

          print(
              '🔍 DEBUG: Found ${patientsSnapshot.docs.length} patients in batch from agency: $agencyId');

          for (final patientDoc in patientsSnapshot.docs) {
            try {
              final patient = patientDoc.data();
              patients.add(patient);
              print(
                  '🔍 DEBUG: Added patient: ${patient?.firstName} ${patient?.lastName}');
            } catch (e) {
              print('⚠️ Warning: Failed to parse patient ${patientDoc.id}: $e');
              continue;
            }
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

  /// Stream all patients via shift-centric queries across all agencies
  @override
  Stream<Either<Failure, List<Patient>>> watchAllPatients() {
    try {
      print(
          '🔍 DEBUG: Starting watchAllPatients stream for user: ${_user.uid}');

      // Watch ALL scheduledShifts across agencies using collection group
      return _firestore
          .collectionGroup('scheduledShifts')
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

          // Collect patient IDs by agency from current shifts
          final patientsByAgency = <String, Set<String>>{};
          for (final shiftDoc in shiftsSnapshot.docs) {
            try {
              final shiftData = shiftDoc.data();
              shiftData['id'] = shiftDoc.id;

              // Extract agency ID from document path
              final pathSegments = shiftDoc.reference.path.split('/');
              String? agencyId;
              if (pathSegments.length >= 2 && pathSegments[0] == 'agencies') {
                agencyId = pathSegments[1];
              }

              if (agencyId == null) continue;

              final shift = ScheduledShiftModel.fromJson(shiftData);
              if (shift.assignedPatientIds != null &&
                  shift.assignedPatientIds!.isNotEmpty) {
                patientsByAgency.putIfAbsent(agencyId, () => <String>{});
                patientsByAgency[agencyId]!.addAll(shift.assignedPatientIds!);
              }
            } catch (e) {
              print(
                  '⚠️ Warning: Failed to parse shift ${shiftDoc.id} in stream: $e');
            }
          }

          if (patientsByAgency.isEmpty) {
            print(
                '🔍 DEBUG: No patients in shifts stream - returning empty list');
            return const Right<Failure, List<Patient>>([]);
          }

          print(
              '🔍 DEBUG: Stream collected patients by agency: ${patientsByAgency.map((k, v) => MapEntry(k, v.length))}');

          // Query patients from each agency
          final patients = <Patient>[];

          for (final agencyEntry in patientsByAgency.entries) {
            final agencyId = agencyEntry.key;
            final patientIds = agencyEntry.value.toList();

            final agencyPatientsCollection = _firestore
                .collection('agencies')
                .doc(agencyId)
                .collection('patients')
                .withConverter<Patient>(
                  fromFirestore: PatientConverter.fromFirestore,
                  toFirestore: PatientConverter.toFirestore,
                );

            // Query in batches (Firestore whereIn limit = 10)
            for (int i = 0; i < patientIds.length; i += 10) {
              final batch = patientIds.skip(i).take(10).toList();

              final patientsSnapshot = await agencyPatientsCollection
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

  /// Single patient fetch - requires agency context for proper access
  @override
  Future<Either<Failure, Patient?>> fetchById(String id) async {
    try {
      // Since we don't have agency context, we need to search across agencies
      // where the nurse has active shifts
      final shiftsQuery = _firestore
          .collectionGroup('scheduledShifts')
          .where('assignedTo', isEqualTo: _user.uid)
          .where('assignedPatientIds', arrayContains: id);

      final shiftsSnapshot = await shiftsQuery.get();

      if (shiftsSnapshot.docs.isEmpty) {
        // Patient not accessible to this nurse
        return const Right(null);
      }

      // Get agency ID from first shift that contains this patient
      final shiftDoc = shiftsSnapshot.docs.first;
      final pathSegments = shiftDoc.reference.path.split('/');
      if (pathSegments.length < 2 || pathSegments[0] != 'agencies') {
        return Left(Failure.unexpected('Invalid shift path structure'));
      }

      final agencyId = pathSegments[1];

      final patientDoc = await _firestore
          .collection('agencies')
          .doc(agencyId)
          .collection('patients')
          .doc(id)
          .withConverter<Patient>(
            fromFirestore: PatientConverter.fromFirestore,
            toFirestore: PatientConverter.toFirestore,
          )
          .get();

      if (!patientDoc.exists) {
        return const Right(null);
      }

      return Right(patientDoc.data());
    } on FirebaseException catch (e) {
      return Left(Failure.unexpected('Failed to fetch patient: ${e.message}'));
    } catch (e) {
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  /// Patient save - requires agency context, derived from current shifts
  @override
  Future<Either<Failure, void>> save(Patient patient) async {
    try {
      // Determine agency context from nurse's current shifts
      String? targetAgencyId;

      if (patient.id.isNotEmpty) {
        // For existing patients, find which agency they belong to
        final shiftsQuery = _firestore
            .collectionGroup('scheduledShifts')
            .where('assignedTo', isEqualTo: _user.uid)
            .where('assignedPatientIds', arrayContains: patient.id);

        final shiftsSnapshot = await shiftsQuery.get();

        if (shiftsSnapshot.docs.isNotEmpty) {
          final pathSegments =
              shiftsSnapshot.docs.first.reference.path.split('/');
          if (pathSegments.length >= 2 && pathSegments[0] == 'agencies') {
            targetAgencyId = pathSegments[1];
          }
        }
      }

      if (targetAgencyId == null) {
        return Left(Failure.unexpected(
            'Cannot determine agency context for patient. Ensure you have an active shift.'));
      }

      final patientsCollection = _firestore
          .collection('agencies')
          .doc(targetAgencyId)
          .collection('patients')
          .withConverter<Patient>(
            fromFirestore: PatientConverter.fromFirestore,
            toFirestore: PatientConverter.toFirestore,
          );

      if (patient.id.isEmpty) {
        // Create new patient
        final patientWithContext = patient.copyWith(
          createdBy: _user.uid,
        );
        await patientsCollection.add(patientWithContext);
      } else {
        // Update existing patient
        await patientsCollection.doc(patient.id).set(patient);
      }

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(Failure.unexpected('Failed to save patient: ${e.message}'));
    } catch (e) {
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  /// Patient delete - requires agency context, derived from current shifts
  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      // Find which agency this patient belongs to through nurse's shifts
      final shiftsQuery = _firestore
          .collectionGroup('scheduledShifts')
          .where('assignedTo', isEqualTo: _user.uid)
          .where('assignedPatientIds', arrayContains: id);

      final shiftsSnapshot = await shiftsQuery.get();

      if (shiftsSnapshot.docs.isEmpty) {
        return Left(Failure.unexpected(
            'Patient not accessible - no active shifts contain this patient'));
      }

      final pathSegments = shiftsSnapshot.docs.first.reference.path.split('/');
      if (pathSegments.length < 2 || pathSegments[0] != 'agencies') {
        return Left(Failure.unexpected('Invalid shift path structure'));
      }

      final agencyId = pathSegments[1];

      await _firestore
          .collection('agencies')
          .doc(agencyId)
          .collection('patients')
          .doc(id)
          .delete();

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(Failure.unexpected('Failed to delete patient: ${e.message}'));
    } catch (e) {
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }
}
