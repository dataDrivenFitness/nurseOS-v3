// lib/features/patient/data/firebase_patient_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:nurseos_v3/core/error/failure.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'abstract_patient_repository.dart';

class FirebasePatientRepository implements PatientRepository {
  final FirebaseFirestore _firestore;
  final UserModel _user;

  FirebasePatientRepository(this._firestore, this._user);

  /// Collection reference with proper converter
  CollectionReference<Patient> get _patients =>
      _firestore.collection('patients').withConverter<Patient>(
            fromFirestore: _fromFirestore,
            toFirestore: _toFirestore,
          );

  /// Safe converter from Firestore to Patient model
  Patient _fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, _) {
    final rawData = snapshot.data() ?? {};
    final data = Map<String, dynamic>.from(rawData);

    try {
      // Set the document ID
      data['id'] = snapshot.id;

      // Fix List fields that might be stored as strings or other types
      _ensureListField(data, 'primaryDiagnoses');
      _ensureListField(data, 'assignedNurses');
      _ensureListField(data, 'allergies');
      _ensureListField(data, 'dietRestrictions');

      // Ensure required fields have defaults
      data['location'] ??= 'residence';
      data['isFallRisk'] ??= false;
      data['isIsolation'] ??= false;
      data['biologicalSex'] ??= 'unspecified';

      return Patient.fromJson(data);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error converting patient ${snapshot.id}: $e');
        print('Raw data: $rawData');
        print('Processed data: $data');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Convert Patient model to Firestore format
  Map<String, dynamic> _toFirestore(Patient patient, _) {
    final json = patient.toJson();
    // Remove the ID field since Firestore handles that
    json.remove('id');
    return json;
  }

  /// Helper to ensure list fields are properly formatted
  void _ensureListField(Map<String, dynamic> data, String fieldName) {
    final value = data[fieldName];

    if (value == null) {
      // Null value - set to empty list
      data[fieldName] = <String>[];
    } else if (value is String) {
      // Single string - convert to list
      if (value.isEmpty) {
        data[fieldName] = <String>[];
      } else {
        // Split comma-separated values or treat as single item
        if (value.contains(',')) {
          data[fieldName] = value.split(',').map((e) => e.trim()).toList();
        } else {
          data[fieldName] = [value];
        }
      }
    } else if (value is List) {
      // Already a list - ensure all elements are strings
      data[fieldName] = value
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      // Unknown type - convert to string then list
      final stringValue = value.toString();
      data[fieldName] = stringValue.isEmpty ? <String>[] : [stringValue];
    }
  }

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
          return Left<Failure, List<Patient>>(
            Failure.unexpected('Failed to process patient stream: $e'),
          );
        }
      }).handleError((error) {
        return Left<Failure, List<Patient>>(
          Failure.unexpected('Stream error: $error'),
        );
      });
    } catch (e) {
      return Stream.value(
        Left<Failure, List<Patient>>(
          Failure.unexpected('Failed to setup patient stream: $e'),
        ),
      );
    }
  }
}
