import 'package:fpdart/fpdart.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import '../../../core/error/failure.dart';

abstract class PatientRepository {
  Future<Either<Failure, List<Patient>>> getAllPatients();
}
