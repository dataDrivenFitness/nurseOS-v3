import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/error/failure.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'abstract_patient_repository.dart';

class FirebasePatientRepository implements PatientRepository {
  final patientsRef =
      FirebaseFirestore.instance.collection('patients').withConverter<Patient>(
            fromFirestore: (snap, _) => Patient.fromJson(snap.data()!),
            toFirestore: (p, _) => p.toJson(),
          );

  @override
  Future<Either<Failure, List<Patient>>> getAllPatients() async {
    try {
      final query = await patientsRef.get();
      return right(query.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      return left(Failure.unexpected(e.toString()));
    }
  }
}
