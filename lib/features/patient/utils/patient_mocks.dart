import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/utils/risk_utils.dart';

Patient mockLowRiskPatient() => Patient(
      id: 'mock_1',
      firstName: 'Jane',
      lastName: 'Doe',
      location: '3-East 12',
      primaryDiagnosis: 'Hypertension',
    );

Patient mockHighRiskPatient() => Patient(
      id: 'mock_2',
      firstName: 'John',
      lastName: 'Smith',
      location: '2-West ICU',
      primaryDiagnosis: 'Sepsis',
      isIsolation: true,
      manualRiskOverride: RiskLevel.high,
      allergies: ['penicillin'],
      codeStatus: 'DNR',
      birthDate: DateTime(1942, 9, 2),
      pronouns: 'he/him',
      assignedNurses: ['nurse_001'],
      createdBy: 'nurse_001',
      tags: ['fall', 'pressure_ulcer'],
      notes: 'Requires close monitoring overnight',
    );
