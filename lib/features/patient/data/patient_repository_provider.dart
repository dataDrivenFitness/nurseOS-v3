// lib/features/patient/data/patient_repository_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/agency/state/agency_context_provider.dart';

import '../data/abstract_patient_repository.dart';
import '../data/mock_patient_repository.dart';
import '../data/firebase_patient_repository.dart';
import 'package:nurseos_v3/core/env/env.dart';

/// Provides the correct implementation of [PatientRepository] depending on the
/// current environment configuration and agency context.
///
/// If [useMockServices] is true, returns [MockPatientRepository].
/// Otherwise, returns [FirebasePatientRepository] using agency-scoped collections.
/// Returns null if user is not authenticated or no agency is selected.
final patientRepositoryProvider = Provider<PatientRepository?>((ref) {
  if (useMockServices) return MockPatientRepository();

  final firestore = FirebaseFirestore.instance;
  final user = ref.watch(authControllerProvider).value;
  final agencyId = ref.watch(currentAgencyIdProvider);

  print('🔍 PatientRepository Debug:');
  print('  - User: ${user?.firstName} ${user?.lastName} (${user?.uid})');
  print('  - ActiveAgencyId: ${user?.activeAgencyId}');
  print('  - CurrentAgencyId from provider: $agencyId');

  // Don't create repository if user not authenticated
  if (user == null) {
    print('  ❌ No user authenticated - returning null repository');
    return null;
  }

  // Don't create repository if no agency selected (return null to show empty state)
  if (agencyId == null) {
    print('  ❌ No agencyId available - returning null repository');
    return null;
  }

  print('  ✅ Creating FirebasePatientRepository with agency: $agencyId');
  return FirebasePatientRepository(firestore, user, agencyId);
});
