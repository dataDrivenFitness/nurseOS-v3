import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'abstract_patient_repository.dart';
import 'firebase_patient_repository.dart';
import 'mock_patient_repository.dart';
import 'package:nurseos_v3/core/env/env.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  if (useMockServices) return MockPatientRepository();
  return FirebasePatientRepository();
});
