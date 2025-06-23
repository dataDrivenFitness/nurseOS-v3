// test/mock/mock_patient_overrides.dart
import 'package:nurseos_v3/features/patient/state/patient_providers.dart';
import 'mock_patient_notifiers.dart';

/// Plug-and-play overrides – widgets choose the one they need.
final mockPatientsLoading =
    patientProvider.overrideWith(PatientLoadingNotifier.new);

final mockPatientsEmpty =
    patientProvider.overrideWith(PatientEmptyNotifier.new);

final mockPatientsError =
    patientProvider.overrideWith(PatientErrorNotifier.new);
