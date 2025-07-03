// 📁 lib/features/patient/models/patient_field_options.dart

import 'package:nurseos_v3/features/patient/models/patient_risk.dart';

/// 🌍 Common patient field options
const locationOptions = [
  'residence',
  'hospital',
  'snf', // skilled nursing facility
  'rehab',
  'assisted living',
  'memory care',
  'other',
];

const languageOptions = [
  'English',
  'Spanish',
  'Mandarin',
  'Tagalog',
  'Vietnamese',
  'Cantonese',
  'Arabic',
  'Korean',
  'Other',
];

const diagnosisOptions = [
  // 🧠 Neuro
  'Stroke',
  'TIA',
  'Seizure',
  'Parkinson\'s',
  'Dementia',

  // 🫀 Cardiac
  'CHF',
  'CAD',
  'MI',
  'Arrhythmia',
  'Hypertension',

  // 🫁 Respiratory
  'COPD',
  'Pneumonia',
  'COVID-19',
  'Asthma',
  'Pulmonary Embolism',

  // 🧫 Infectious
  'Sepsis',
  'UTI',
  'C. Diff',
  'MRSA',

  // 🧍 Mobility / Falls
  'Hip Fracture',
  'Femur Fracture',
  'Recent Fall',

  // 🩺 Metabolic
  'Diabetes',
  'Hypoglycemia',
  'Thyroid Disorder',

  // 🧬 Other
  'Cancer',
  'Renal Failure',
  'Liver Disease',
  'Constipation',
  'Anemia',
  'Other',
];

const codeStatusOptions = [
  'DNR',
  'DNI',
  'FULL',
  'FULL CODE',
  'LIMITED',
];

const biologicalSexOptions = [
  'Male',
  'Female',
  'Intersex',
  'Unspecified',
];

/// 🚨 Map of diagnoses to triage risk levels
const diagnosisRiskMap = <String, RiskLevel>{
  // High Risk
  'Sepsis': RiskLevel.high,
  'Stroke': RiskLevel.high,
  'MI': RiskLevel.high,
  'Pulmonary Embolism': RiskLevel.high,
  'C. Diff': RiskLevel.high,

  // Medium Risk
  'Hip Fracture': RiskLevel.medium,
  'Pneumonia': RiskLevel.medium,
  'CHF': RiskLevel.medium,
  'COVID-19': RiskLevel.medium,
  'UTI': RiskLevel.medium,
  'Arrhythmia': RiskLevel.medium,
  'Cancer': RiskLevel.medium,

  // Low Risk
  'Constipation': RiskLevel.low,
  'Diabetes': RiskLevel.low,
  'Hypertension': RiskLevel.low,
  'Anemia': RiskLevel.low,
  'Thyroid Disorder': RiskLevel.low,
};

/// 🩺 Diagnosis-to-risk mapping
const Map<RiskLevel, List<String>> diagnosisRiskLevels = {
  RiskLevel.high: ['Sepsis', 'Stroke', 'Cardiac Arrest', 'ARDS', 'AMI'],
  RiskLevel.medium: ['Pneumonia', 'UTI', 'COPD', 'Heart Failure'],
  RiskLevel.low: ['Constipation', 'Hypertension', 'Diabetes Type 2'],
};

/// 🧠 Helper to look up risk level for a single diagnosis
RiskLevel getRiskForDiagnosis(String diagnosis) {
  final normalized = diagnosis.trim().toLowerCase();
  final entry = diagnosisRiskMap.entries.firstWhere(
    (e) => e.key.toLowerCase() == normalized,
    orElse: () => const MapEntry('Unknown', RiskLevel.unknown),
  );
  return entry.value;
}
