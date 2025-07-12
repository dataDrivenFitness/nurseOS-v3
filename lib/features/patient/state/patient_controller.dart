// lib/features/patient/state/patient_controller.dart
// WITH DEBUG LOGGING

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/data/patient_repository_provider.dart';

/// 📦 PatientController using Firestore stream with Riverpod v2
class PatientController extends AutoDisposeStreamNotifier<List<Patient>> {
  @override
  Stream<List<Patient>> build() {
    final repo = ref.watch(patientRepositoryProvider);

    print('🔍 PatientController.build() called');
    print('  - Repository available: ${repo != null}');

    if (repo == null) {
      print('  - Repository is null, returning empty stream');
      // Return stream that emits empty list instead of Stream.empty()
      // This prevents AsyncValue from staying in loading state indefinitely
      return Stream.value(<Patient>[]);
    }

    print('  - Starting watchAllPatients stream...');
    return repo.watchAllPatients().map(
          (either) => either.match(
            (failure) {
              print('❌ Patient repository failure: ${failure.message}');
              print('   Full failure: $failure');
              throw failure;
            },
            (patients) {
              print(
                  '✅ Patient repository success: ${patients.length} patients');
              if (patients.isNotEmpty) {
                print(
                    '   First patient: ${patients.first.firstName} ${patients.first.lastName}');
              }
              return patients;
            },
          ),
        );
  }
}
