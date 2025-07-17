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
/// Otherwise, returns [FirebasePatientRepository] using shift-centric patient access.
/// Returns null if user is not authenticated.
final patientRepositoryProvider = Provider<PatientRepository?>((ref) {
  if (useMockServices) return MockPatientRepository();

  final firestore = FirebaseFirestore.instance;
  final user = ref.watch(authControllerProvider).value;

  print('🔍 PatientRepository Debug:');
  print('  - User: ${user?.firstName} ${user?.lastName} (${user?.uid})');

  // Don't create repository if user not authenticated
  if (user == null) {
    print('  ❌ No user authenticated - returning null repository');
    return null;
  }

  print('  ✅ Creating FirebasePatientRepository for user: ${user.uid}');
  return FirebasePatientRepository(firestore, user);
});
