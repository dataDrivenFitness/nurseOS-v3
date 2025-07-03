import 'patient_risk.dart';

/// 🧠 Single diagnosis definition
class DiagnosisEntry {
  final String label;
  final RiskLevel severity;

  const DiagnosisEntry({
    required this.label,
    required this.severity,
  });
}

/// 📚 Central catalog of diagnoses
const List<DiagnosisEntry> diagnosisCatalog = [
  DiagnosisEntry(label: 'Sepsis', severity: RiskLevel.high),
  DiagnosisEntry(label: 'Stroke', severity: RiskLevel.high),
  DiagnosisEntry(label: 'Myocardial Infarction', severity: RiskLevel.high),
  DiagnosisEntry(label: 'Pulmonary Embolism', severity: RiskLevel.high),
  DiagnosisEntry(label: 'Cardiac Arrest', severity: RiskLevel.high),
  DiagnosisEntry(label: 'GI Bleed', severity: RiskLevel.high),
  DiagnosisEntry(label: 'Respiratory Failure', severity: RiskLevel.high),
  DiagnosisEntry(label: 'Acute Renal Failure', severity: RiskLevel.high),
  DiagnosisEntry(label: 'Severe COVID-19', severity: RiskLevel.high),
  DiagnosisEntry(label: 'DKA', severity: RiskLevel.high),
  DiagnosisEntry(label: 'Status Epilepticus', severity: RiskLevel.high),
  DiagnosisEntry(label: 'Acute Confusion', severity: RiskLevel.high),
  DiagnosisEntry(label: 'Pneumonia', severity: RiskLevel.medium),
  DiagnosisEntry(label: 'Congestive Heart Failure', severity: RiskLevel.medium),
  DiagnosisEntry(label: 'UTI', severity: RiskLevel.medium),
  DiagnosisEntry(label: 'COPD Exacerbation', severity: RiskLevel.medium),
  DiagnosisEntry(label: 'Uncontrolled Diabetes', severity: RiskLevel.medium),
  DiagnosisEntry(label: 'Surgical Wound Infection', severity: RiskLevel.medium),
  DiagnosisEntry(label: 'Delirium', severity: RiskLevel.medium),
  DiagnosisEntry(label: 'Moderate COVID-19', severity: RiskLevel.medium),
  DiagnosisEntry(label: 'Pancreatitis', severity: RiskLevel.medium),
  DiagnosisEntry(label: 'Hip Fracture', severity: RiskLevel.medium),
  DiagnosisEntry(label: 'Clostridium Difficile', severity: RiskLevel.medium),
  DiagnosisEntry(label: 'Moderate Dehydration', severity: RiskLevel.medium),
  DiagnosisEntry(label: 'Wound Dehiscence', severity: RiskLevel.medium),
  DiagnosisEntry(label: 'Constipation', severity: RiskLevel.low),
  DiagnosisEntry(label: 'Hypertension', severity: RiskLevel.low),
  DiagnosisEntry(label: 'Type 2 Diabetes', severity: RiskLevel.low),
  DiagnosisEntry(label: 'Arthritis', severity: RiskLevel.low),
  DiagnosisEntry(label: 'Pressure Ulcer Stage 1', severity: RiskLevel.low),
  DiagnosisEntry(label: 'Mild Dehydration', severity: RiskLevel.low),
  DiagnosisEntry(label: 'Depression', severity: RiskLevel.low),
  DiagnosisEntry(label: 'Dementia', severity: RiskLevel.low),
  DiagnosisEntry(label: 'Anemia', severity: RiskLevel.low),
  DiagnosisEntry(label: 'Mobility Impairment', severity: RiskLevel.low),
  DiagnosisEntry(label: 'Fall History', severity: RiskLevel.low),
  DiagnosisEntry(label: 'Incontinence', severity: RiskLevel.low),
];

/// 🔍 Lookup helper
RiskLevel getRiskForDiagnosis(String diagnosis) {
  return diagnosisCatalog
      .firstWhere(
        (d) => d.label.toLowerCase() == diagnosis.toLowerCase().trim(),
        orElse: () =>
            DiagnosisEntry(label: diagnosis, severity: RiskLevel.unknown),
      )
      .severity;
}
