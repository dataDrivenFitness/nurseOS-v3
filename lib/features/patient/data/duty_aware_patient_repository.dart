// 📁 lib/features/patient/data/duty_aware_patient_repository.dart

import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/error/failure.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/work_history/state/work_history_controller.dart';
import 'abstract_patient_repository.dart';

/// Wrapper around PatientRepository that enforces duty-based edit restrictions
class DutyAwarePatientRepository implements PatientRepository {
  final PatientRepository _baseRepository;
  final Ref _ref;

  DutyAwarePatientRepository(this._baseRepository, this._ref);

  /// Check if nurse is currently on duty
  bool get _isOnDuty {
    final currentSession =
        _ref.read(currentWorkSessionStreamProvider).valueOrNull;
    return currentSession != null;
  }

  /// Read operations are always allowed
  @override
  Future<Either<Failure, List<Patient>>> getAllPatients() {
    return _baseRepository.getAllPatients();
  }

  @override
  Future<Either<Failure, Patient?>> fetchById(String id) {
    return _baseRepository.fetchById(id);
  }

  @override
  Stream<Either<Failure, List<Patient>>> watchAllPatients() {
    return _baseRepository.watchAllPatients();
  }

  /// Write operations require being on duty
  @override
  Future<Either<Failure, void>> save(Patient patient) async {
    if (!_isOnDuty) {
      debugPrint('❌ Patient save blocked: Nurse not on duty');
      return Left(Failure.unauthorized(
        'You must be on duty to edit or add patients. Please start your shift first.',
      ));
    }

    debugPrint('✅ Patient save allowed: Nurse is on duty');
    return _baseRepository.save(patient);
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    if (!_isOnDuty) {
      debugPrint('❌ Patient delete blocked: Nurse not on duty');
      return Left(Failure.unauthorized(
        'You must be on duty to delete patients. Please start your shift first.',
      ));
    }

    debugPrint('✅ Patient delete allowed: Nurse is on duty');
    return _baseRepository.delete(id);
  }
}
