// lib/features/patient/data/firebase_patient_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:nurseos_v3/core/error/failure.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/shared/converters/patient_converter.dart';
import 'abstract_patient_repository.dart';

class FirebasePatientRepository implements PatientRepository {
  final FirebaseFirestore _firestore;
  final UserModel _user;

  FirebasePatientRepository(this._firestore, this._user);

  /// Collection reference with robust converter
  CollectionReference<Patient> get _patients =>
      _firestore.collection('patients').withConverter<Patient>(
            fromFirestore: PatientConverter.fromFirestore,
            toFirestore: PatientConverter.toFirestore,
          );

  @override
  Future<Either<Failure, List<Patient>>> getAllPatients() async {
    try {
      final snapshot = await _patients
          .where('assignedNurses', arrayContains: _user.uid)
          .get();

      final patients = snapshot.docs.map((doc) => doc.data()).toList();
      return Right(patients);
    } on FirebaseException catch (e) {
      return Left(Failure.unexpected('Failed to fetch patients: ${e.message}'));
    } catch (e) {
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

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

  @override
  Future<Either<Failure, void>> save(Patient patient) async {
    try {
      if (patient.id.isEmpty) {
        // Create new patient
        await _patients.add(patient);
      } else {
        // Update existing patient
        await _patients.doc(patient.id).set(patient);
      }
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(Failure.unexpected('Failed to save patient: ${e.message}'));
    } catch (e) {
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

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

  @override
  Stream<Either<Failure, List<Patient>>> watchAllPatients() {
    try {
      return _patients
          .where('assignedNurses', arrayContains: _user.uid)
          .snapshots()
          .map((snapshot) {
        try {
          final patients = snapshot.docs.map((doc) => doc.data()).toList();
          return Right<Failure, List<Patient>>(patients);
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error in watchAllPatients stream: $e');
          }
          return Left<Failure, List<Patient>>(
            Failure.unexpected('Failed to parse patient data: $e'),
          );
        }
      });
    } catch (e) {
      return Stream.value(
        Left(Failure.unexpected('Failed to watch patients: $e')),
      );
    }
  }
}
