import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/data/patient_repository_provider.dart';

class PatientController extends AsyncNotifier<List<Patient>> {
  @override
  FutureOr<List<Patient>> build() async {
    final repo = ref.read(patientRepositoryProvider);

    // Handle "repo not ready" (user not yet loaded)
    if (repo == null) {
      // Could throw, or just return empty while loading.
      // If you want to "wait," throw AsyncLoading and let Riverpod handle it.
      // But returning [] prevents UI from breaking:
      return [];
    }

    final result = await repo.getAllPatients();
    return result.match(
      (failure) => throw failure,
      (patients) => patients,
    );
  }

  Future<void> refreshPatients() async {
    state = const AsyncValue.loading();

    final repo = ref.read(patientRepositoryProvider);
    if (repo == null) {
      // Stay loading if repo not available yet.
      state = const AsyncValue.loading();
      return;
    }

    state = await AsyncValue.guard(() async {
      final result = await repo.getAllPatients();
      return result.match(
        (failure) => throw failure,
        (patients) => patients,
      );
    });
  }
}
