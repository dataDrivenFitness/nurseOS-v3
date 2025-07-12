import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/models/patient_risk.dart';

final mockPatients = [
  Patient(
    id: 'mock_1',
    firstName: 'Jane',
    lastName: 'Doe',
    location: '3-East 12',
    primaryDiagnoses: ['Hypertension'],
    biologicalSex: 'female',
    pronouns: 'she/her',
    createdBy: 'nurse_001',
    //assignedNurses: ['nurse_001'],
    agencyId: 'demo-agency',
  ),
  Patient(
    id: 'mock_2',
    firstName: 'John',
    lastName: 'Smith',
    location: '2-West ICU',
    primaryDiagnoses: ['Sepsis'],
    isIsolation: true,
    manualRiskOverride: RiskLevel.high,
    allergies: ['penicillin'],
    codeStatus: 'DNR',
    birthDate: DateTime(1942, 9, 2),

    biologicalSex: 'male',
    pronouns: 'he/him',
    createdBy: 'nurse_001',
    //assignedNurses: ['nurse_001'],
    agencyId: 'demo-agency',
  ),
];
