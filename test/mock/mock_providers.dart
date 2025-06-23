//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/patient/state/patient_providers.dart';
import 'mock_patient_notifiers.dart';

/// These are what the widget tests import 👇
final mockPatientControllerLoading =
    patientProvider.overrideWith(PatientLoadingNotifier.new);

final mockPatientControllerEmpty =
    patientProvider.overrideWith(PatientEmptyNotifier.new);

final mockPatientControllerError =
    patientProvider.overrideWith(PatientErrorNotifier.new);
