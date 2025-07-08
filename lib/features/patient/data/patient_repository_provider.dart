// lib/features/patient/data/patient_repository_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';

import '../data/abstract_patient_repository.dart';
import '../data/mock_patient_repository.dart';
import '../data/firebase_patient_repository.dart';
import 'package:nurseos_v3/core/env/env.dart';

/// Provides the correct implementation of [PatientRepository] depending on the
/// current environment configuration.
///
/// If [useMockServices] is true, returns [MockPatientRepository].
/// Otherwise, returns [FirebasePatientRepository] using a Firestore instance.
final patientRepositoryProvider = Provider<PatientRepository?>((ref) {
  if (useMockServices) return MockPatientRepository();

  final firestore = FirebaseFirestore.instance;
  final user = ref.watch(authControllerProvider).value;

  if (user == null) return null; // Don't throw, just wait

  return FirebasePatientRepository(firestore, user);
});
