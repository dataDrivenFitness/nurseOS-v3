import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'patient_controller.dart';

/// ONE canonical provider that everything (UI, tests, mocks) refers to.
final patientProvider = AsyncNotifierProvider<PatientController, List<Patient>>(
  PatientController.new,
);
