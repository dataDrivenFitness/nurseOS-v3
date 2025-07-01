import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'patient_controller.dart';

/// 🎯 Canonical provider for real-time patient list.
/// Reflects live updates via Firestore stream.
final patientProvider =
    AutoDisposeStreamNotifierProvider<PatientController, List<Patient>>(
  PatientController.new,
);
