import 'package:fpdart/fpdart.dart';
import 'package:nurseos_v3/core/error/failure.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';

abstract class PatientRepository {
  Future<Either<Failure, List<Patient>>> getAllPatients();
  Future<Either<Failure, Patient?>> fetchById(String id);
  Future<Either<Failure, void>> save(Patient patient);
  Future<Either<Failure, void>> delete(String id);
}
