import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/data/patient_repository_provider.dart';
import 'package:nurseos_v3/core/error/failure.dart';

/// 📦 PatientController using Firestore stream with Riverpod v2
class PatientController extends AutoDisposeStreamNotifier<List<Patient>> {
  @override
  Stream<List<Patient>> build() {
    final repo = ref.watch(patientRepositoryProvider);

    if (repo == null) {
      return const Stream.empty();
    }

    return repo.watchAllPatients().map(
          (either) => either.match(
            (failure) => throw failure,
            (patients) => patients,
          ),
        );
  }
}
