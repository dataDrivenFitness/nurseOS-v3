import 'package:fpdart/fpdart.dart';
import 'package:nurseos_v3/core/error/failure.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';

/// 📦 Abstract interface for all Patient data sources (Firebase or Mock)
abstract class PatientRepository {
  /// 🔁 Fetches all patients one-time (non-streaming).
  Future<Either<Failure, List<Patient>>> getAllPatients();

  /// 🔍 Fetches a single patient by ID.
  Future<Either<Failure, Patient?>> fetchById(String id);

  /// 💾 Saves (creates or updates) a patient record.
  Future<Either<Failure, void>> save(Patient patient);

  /// ❌ Deletes a patient by ID.
  Future<Either<Failure, void>> delete(String id);

  /// 🔄 Watches the full patient list in real-time (Firestore snapshot stream).
  /// Emits [Right<List<Patient>>] on success, or [Left<Failure>] on error.
  Stream<Either<Failure, List<Patient>>> watchAllPatients();
}
