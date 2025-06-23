import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/data/patient_repository_provider.dart';
//import 'package:nurseos_v3/core/error/failure.dart';
//import 'package:fpdart/fpdart.dart';

class PatientController extends AsyncNotifier<List<Patient>> {
  @override
  FutureOr<List<Patient>> build() async {
    final repo = ref.read(patientRepositoryProvider);
    final result = await repo.getAllPatients();
    return result.match(
      (failure) => throw failure,
      (patients) => patients,
    );
  }

  Future<void> refreshPatients() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(patientRepositoryProvider).getAllPatients();
      return result.fold(
        (failure) => throw failure,
        (patients) => patients,
      );
    });
  }
}
