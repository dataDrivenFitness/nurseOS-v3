import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:nurseos_v3/core/error/failure.dart';
import 'package:nurseos_v3/features/patient/utils/patient_mocks.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';

import 'abstract_patient_repository.dart';

class MockPatientRepository implements PatientRepository {
  @override
  Future<Either<Failure, List<Patient>>> getAllPatients() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return right([
      mockLowRiskPatient(),
      mockHighRiskPatient(),
    ]);
  }
}
