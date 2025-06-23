import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';

import '../../../core/error/failure.dart';
import 'abstract_patient_repository.dart';

class FirebasePatientRepository implements PatientRepository {
  final FirebaseFirestore _db;

  FirebasePatientRepository(this._db);

  CollectionReference<Patient> get _patients =>
      _db.collection('patients').withConverter<Patient>(
            fromFirestore: (snap, _) =>
                Patient.fromJson(snap.data()!).copyWith(id: snap.id),
            toFirestore: (patient, _) => patient.toJson(),
          );

  @override
  Future<Either<Failure, List<Patient>>> getAllPatients() async {
    try {
      debugPrint('🔥 FirebasePatientRepository.getAllPatients() called');
      final snap = await _patients.get();
      final patients = snap.docs.map((doc) => doc.data()).toList();
      debugPrint('✅ Loaded ${patients.length} patients');
      return Right(patients);
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException: ${e.code} — ${e.message}');
      return Left(Failure.unexpected(e.message ?? 'Firestore error'));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Patient>> fetchById(String id) async {
    try {
      final doc = await _patients.doc(id).get();
      if (!doc.exists) {
        return Left(Failure.notFound('Patient not found'));
      }
      return Right(doc.data()!);
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException: ${e.code} — ${e.message}');
      return Left(Failure.unexpected(e.message ?? 'Firestore error'));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> save(Patient patient) async {
    try {
      await _patients.doc(patient.id).set(patient);
      return Right(unit);
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException: ${e.code} — ${e.message}');
      return Left(Failure.unexpected(e.message ?? 'Firestore error'));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _patients.doc(id).delete();
      return Right(unit);
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException: ${e.code} — ${e.message}');
      return Left(Failure.unexpected(e.message ?? 'Firestore error'));
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return Left(Failure.unexpected(e.toString()));
    }
  }
}
