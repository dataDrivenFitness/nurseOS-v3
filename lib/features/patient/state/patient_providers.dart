import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'patient_controller.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';

final patientProvider = AsyncNotifierProvider<PatientController, List<Patient>>(
  PatientController.new,
);
