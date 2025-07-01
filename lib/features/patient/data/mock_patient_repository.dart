import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/error/failure.dart';
import '../models/patient_model.dart';
import '../utils/patient_mocks.dart'; // ⬅️ correctly importing mock data
import 'abstract_patient_repository.dart';

class MockPatientRepository implements PatientRepository {
  @override
  Future<Either<Failure, List<Patient>>> getAllPatients() async {
    await Future.delayed(const Duration(milliseconds: 200));
    debugPrint('🧪 MockPatientRepository.getAllPatients()');
    return Right(mockPatients);
  }

  @override
  Future<Either<Failure, Patient?>> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final match = mockPatients.firstWhere(
      (p) => p.id == id,
      orElse: () => mockPatients.first.copyWith(id: id),
    );
    return Right(match);
  }

  @override
  Future<Either<Failure, void>> save(Patient patient) async {
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('/ MockPatientRepository.save() called for ${patient.id}');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('/ MockPatientRepository.delete() called for $id');
    return const Right(null);
  }

  /// 🔁 Simulates real-time patient list stream (static for now)
  @override
  Stream<Either<Failure, List<Patient>>> watchAllPatients() async* {
    debugPrint('🧪 MockPatientRepository.watchAllPatients()');
    yield Right(mockPatients);
  }
}
