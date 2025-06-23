// test/mock/mock_patient_notifiers.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/state/patient_controller.dart';

/// DRY helper – all three mocks extend this.
abstract class _StaticPatientController extends PatientController {
  final AsyncValue<List<Patient>> _preset;

  _StaticPatientController(this._preset);

  @override
  Future<List<Patient>> build() async {
    state = _preset; // immediately seed the desired state
    return <Patient>[]; // value is never read in widget tests
  }

  // block any real repo calls
  @override
  Future<void> refreshPatients() async {
    state = _preset;
  }
}

/* ───────── loading ───────── */
class PatientLoadingNotifier extends _StaticPatientController {
  PatientLoadingNotifier() : super(const AsyncValue.loading());
}

/* ───────── empty list ────── */
class PatientEmptyNotifier extends _StaticPatientController {
  PatientEmptyNotifier() : super(const AsyncValue.data(<Patient>[]));
}

/* ───────── failure ───────── */
class PatientErrorNotifier extends _StaticPatientController {
  PatientErrorNotifier()
      : super(
          AsyncValue.error(
            Exception('Failed to load'),
            StackTrace.current,
          ),
        );
}
