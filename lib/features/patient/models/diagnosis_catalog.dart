import 'patient_risk.dart';

/// 🧠 Single diagnosis definition
class DiagnosisEntry {
  final String label;
  final RiskLevel severity;
  final String? code; // ICD-10 code
  final String category;

  const DiagnosisEntry({
    required this.label,
    required this.severity,
    this.code,
    required this.category,
  });
}

/// 📚 Central catalog of diagnoses organized by category and severity
const List<DiagnosisEntry> diagnosisCatalog = [
  // ═══════════════════════════════════════════════════════════════
  // 🫀 CARDIOVASCULAR - High Risk
  // ═══════════════════════════════════════════════════════════════
  DiagnosisEntry(
    label: 'Myocardial Infarction',
    severity: RiskLevel.high,
    code: 'I21.9',
    category: 'Cardiovascular',
  ),
  DiagnosisEntry(
    label: 'Cardiac Arrest',
    severity: RiskLevel.high,
    code: 'I46.9',
    category: 'Cardiovascular',
  ),
  DiagnosisEntry(
    label: 'Cardiogenic Shock',
    severity: RiskLevel.high,
    code: 'R57.0',
    category: 'Cardiovascular',
  ),
  DiagnosisEntry(
    label: 'Acute Heart Failure',
    severity: RiskLevel.high,
    code: 'I50.9',
    category: 'Cardiovascular',
  ),
  DiagnosisEntry(
    label: 'Ventricular Fibrillation',
    severity: RiskLevel.high,
    code: 'I49.01',
    category: 'Cardiovascular',
  ),

  // 🫀 CARDIOVASCULAR - Medium Risk
  DiagnosisEntry(
    label: 'Congestive Heart Failure',
    severity: RiskLevel.medium,
    code: 'I50.9',
    category: 'Cardiovascular',
  ),
  DiagnosisEntry(
    label: 'Atrial Fibrillation',
    severity: RiskLevel.medium,
    code: 'I48.91',
    category: 'Cardiovascular',
  ),
  DiagnosisEntry(
    label: 'Unstable Angina',
    severity: RiskLevel.medium,
    code: 'I20.0',
    category: 'Cardiovascular',
  ),

  // 🫀 CARDIOVASCULAR - Low Risk
  DiagnosisEntry(
    label: 'Hypertension',
    severity: RiskLevel.low,
    code: 'I10',
    category: 'Cardiovascular',
  ),
  DiagnosisEntry(
    label: 'Stable Angina',
    severity: RiskLevel.low,
    code: 'I20.9',
    category: 'Cardiovascular',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🫁 RESPIRATORY - High Risk
  // ═══════════════════════════════════════════════════════════════
  DiagnosisEntry(
    label: 'Respiratory Failure',
    severity: RiskLevel.high,
    code: 'J96.00',
    category: 'Respiratory',
  ),
  DiagnosisEntry(
    label: 'Pulmonary Embolism',
    severity: RiskLevel.high,
    code: 'I26.99',
    category: 'Respiratory',
  ),
  DiagnosisEntry(
    label: 'Severe COVID-19',
    severity: RiskLevel.high,
    code: 'U07.1',
    category: 'Respiratory',
  ),
  DiagnosisEntry(
    label: 'ARDS',
    severity: RiskLevel.high,
    code: 'J80',
    category: 'Respiratory',
  ),
  DiagnosisEntry(
    label: 'Tension Pneumothorax',
    severity: RiskLevel.high,
    code: 'J93.0',
    category: 'Respiratory',
  ),

  // 🫁 RESPIRATORY - Medium Risk
  DiagnosisEntry(
    label: 'Pneumonia',
    severity: RiskLevel.medium,
    code: 'J18.9',
    category: 'Respiratory',
  ),
  DiagnosisEntry(
    label: 'COPD Exacerbation',
    severity: RiskLevel.medium,
    code: 'J44.1',
    category: 'Respiratory',
  ),
  DiagnosisEntry(
    label: 'Moderate COVID-19',
    severity: RiskLevel.medium,
    code: 'U07.1',
    category: 'Respiratory',
  ),
  DiagnosisEntry(
    label: 'Pleural Effusion',
    severity: RiskLevel.medium,
    code: 'J94.8',
    category: 'Respiratory',
  ),
  DiagnosisEntry(
    label: 'Bronchitis',
    severity: RiskLevel.medium,
    code: 'J40',
    category: 'Respiratory',
  ),

  // 🫁 RESPIRATORY - Low Risk
  DiagnosisEntry(
    label: 'Asthma',
    severity: RiskLevel.low,
    code: 'J45.9',
    category: 'Respiratory',
  ),
  DiagnosisEntry(
    label: 'Sleep Apnea',
    severity: RiskLevel.low,
    code: 'G47.33',
    category: 'Respiratory',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🧠 NEUROLOGICAL - High Risk
  // ═══════════════════════════════════════════════════════════════
  DiagnosisEntry(
    label: 'Stroke',
    severity: RiskLevel.high,
    code: 'I63.9',
    category: 'Neurological',
  ),
  DiagnosisEntry(
    label: 'Status Epilepticus',
    severity: RiskLevel.high,
    code: 'G41.9',
    category: 'Neurological',
  ),
  DiagnosisEntry(
    label: 'Traumatic Brain Injury',
    severity: RiskLevel.high,
    code: 'S06.9',
    category: 'Neurological',
  ),
  DiagnosisEntry(
    label: 'Intracranial Hemorrhage',
    severity: RiskLevel.high,
    code: 'I62.9',
    category: 'Neurological',
  ),
  DiagnosisEntry(
    label: 'Acute Confusion',
    severity: RiskLevel.high,
    code: 'R41.0',
    category: 'Neurological',
  ),

  // 🧠 NEUROLOGICAL - Medium Risk
  DiagnosisEntry(
    label: 'Delirium',
    severity: RiskLevel.medium,
    code: 'F05',
    category: 'Neurological',
  ),
  DiagnosisEntry(
    label: 'Seizure Disorder',
    severity: RiskLevel.medium,
    code: 'G40.9',
    category: 'Neurological',
  ),
  DiagnosisEntry(
    label: 'Altered Mental Status',
    severity: RiskLevel.medium,
    code: 'R41.82',
    category: 'Neurological',
  ),

  // 🧠 NEUROLOGICAL - Low Risk
  DiagnosisEntry(
    label: 'Dementia',
    severity: RiskLevel.low,
    code: 'F03.90',
    category: 'Neurological',
  ),
  DiagnosisEntry(
    label: 'Depression',
    severity: RiskLevel.low,
    code: 'F32.9',
    category: 'Neurological',
  ),
  DiagnosisEntry(
    label: 'Anxiety',
    severity: RiskLevel.low,
    code: 'F41.9',
    category: 'Neurological',
  ),
  DiagnosisEntry(
    label: 'Migraine',
    severity: RiskLevel.low,
    code: 'G43.909',
    category: 'Neurological',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🦠 INFECTIOUS - High Risk
  // ═══════════════════════════════════════════════════════════════
  DiagnosisEntry(
    label: 'Sepsis',
    severity: RiskLevel.high,
    code: 'A41.9',
    category: 'Infectious',
  ),
  DiagnosisEntry(
    label: 'Septic Shock',
    severity: RiskLevel.high,
    code: 'R65.21',
    category: 'Infectious',
  ),
  DiagnosisEntry(
    label: 'Meningitis',
    severity: RiskLevel.high,
    code: 'G03.9',
    category: 'Infectious',
  ),
  DiagnosisEntry(
    label: 'Endocarditis',
    severity: RiskLevel.high,
    code: 'I33.9',
    category: 'Infectious',
  ),

  // 🦠 INFECTIOUS - Medium Risk
  DiagnosisEntry(
    label: 'Clostridium Difficile',
    severity: RiskLevel.medium,
    code: 'A04.7',
    category: 'Infectious',
  ),
  DiagnosisEntry(
    label: 'Surgical Wound Infection',
    severity: RiskLevel.medium,
    code: 'T81.4',
    category: 'Infectious',
  ),
  DiagnosisEntry(
    label: 'Cellulitis',
    severity: RiskLevel.medium,
    code: 'L03.90',
    category: 'Infectious',
  ),
  DiagnosisEntry(
    label: 'Osteomyelitis',
    severity: RiskLevel.medium,
    code: 'M86.9',
    category: 'Infectious',
  ),

  // 🦠 INFECTIOUS - Low Risk
  DiagnosisEntry(
    label: 'UTI',
    severity: RiskLevel.low,
    code: 'N39.0',
    category: 'Infectious',
  ),
  DiagnosisEntry(
    label: 'Upper Respiratory Infection',
    severity: RiskLevel.low,
    code: 'J06.9',
    category: 'Infectious',
  ),
  DiagnosisEntry(
    label: 'Gastroenteritis',
    severity: RiskLevel.low,
    code: 'K59.1',
    category: 'Infectious',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🍽️ GASTROINTESTINAL - High Risk
  // ═══════════════════════════════════════════════════════════════
  DiagnosisEntry(
    label: 'GI Bleed',
    severity: RiskLevel.high,
    code: 'K92.2',
    category: 'Gastrointestinal',
  ),
  DiagnosisEntry(
    label: 'Bowel Obstruction',
    severity: RiskLevel.high,
    code: 'K56.9',
    category: 'Gastrointestinal',
  ),
  DiagnosisEntry(
    label: 'Perforated Bowel',
    severity: RiskLevel.high,
    code: 'K63.1',
    category: 'Gastrointestinal',
  ),
  DiagnosisEntry(
    label: 'Severe Pancreatitis',
    severity: RiskLevel.high,
    code: 'K85.9',
    category: 'Gastrointestinal',
  ),

  // 🍽️ GASTROINTESTINAL - Medium Risk
  DiagnosisEntry(
    label: 'Pancreatitis',
    severity: RiskLevel.medium,
    code: 'K85.9',
    category: 'Gastrointestinal',
  ),
  DiagnosisEntry(
    label: 'Cholecystitis',
    severity: RiskLevel.medium,
    code: 'K81.9',
    category: 'Gastrointestinal',
  ),
  DiagnosisEntry(
    label: 'Diverticulitis',
    severity: RiskLevel.medium,
    code: 'K57.92',
    category: 'Gastrointestinal',
  ),
  DiagnosisEntry(
    label: 'Inflammatory Bowel Disease',
    severity: RiskLevel.medium,
    code: 'K50.90',
    category: 'Gastrointestinal',
  ),

  // 🍽️ GASTROINTESTINAL - Low Risk
  DiagnosisEntry(
    label: 'Constipation',
    severity: RiskLevel.low,
    code: 'K59.00',
    category: 'Gastrointestinal',
  ),
  DiagnosisEntry(
    label: 'GERD',
    severity: RiskLevel.low,
    code: 'K21.9',
    category: 'Gastrointestinal',
  ),
  DiagnosisEntry(
    label: 'Nausea and Vomiting',
    severity: RiskLevel.low,
    code: 'R11.2',
    category: 'Gastrointestinal',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🩸 ENDOCRINE - High Risk
  // ═══════════════════════════════════════════════════════════════
  DiagnosisEntry(
    label: 'DKA',
    severity: RiskLevel.high,
    code: 'E10.10',
    category: 'Endocrine',
  ),
  DiagnosisEntry(
    label: 'Hyperosmolar Hyperglycemic State',
    severity: RiskLevel.high,
    code: 'E11.01',
    category: 'Endocrine',
  ),
  DiagnosisEntry(
    label: 'Severe Hypoglycemia',
    severity: RiskLevel.high,
    code: 'E16.2',
    category: 'Endocrine',
  ),
  DiagnosisEntry(
    label: 'Thyroid Storm',
    severity: RiskLevel.high,
    code: 'E05.5',
    category: 'Endocrine',
  ),

  // 🩸 ENDOCRINE - Medium Risk
  DiagnosisEntry(
    label: 'Uncontrolled Diabetes',
    severity: RiskLevel.medium,
    code: 'E11.65',
    category: 'Endocrine',
  ),
  DiagnosisEntry(
    label: 'Hyperthyroidism',
    severity: RiskLevel.medium,
    code: 'E05.90',
    category: 'Endocrine',
  ),
  DiagnosisEntry(
    label: 'Adrenal Insufficiency',
    severity: RiskLevel.medium,
    code: 'E27.40',
    category: 'Endocrine',
  ),

  // 🩸 ENDOCRINE - Low Risk
  DiagnosisEntry(
    label: 'Type 2 Diabetes',
    severity: RiskLevel.low,
    code: 'E11.9',
    category: 'Endocrine',
  ),
  DiagnosisEntry(
    label: 'Type 1 Diabetes',
    severity: RiskLevel.low,
    code: 'E10.9',
    category: 'Endocrine',
  ),
  DiagnosisEntry(
    label: 'Hypothyroidism',
    severity: RiskLevel.low,
    code: 'E03.9',
    category: 'Endocrine',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🩺 RENAL - High Risk
  // ═══════════════════════════════════════════════════════════════
  DiagnosisEntry(
    label: 'Acute Renal Failure',
    severity: RiskLevel.high,
    code: 'N17.9',
    category: 'Renal',
  ),
  DiagnosisEntry(
    label: 'End Stage Renal Disease',
    severity: RiskLevel.high,
    code: 'N18.6',
    category: 'Renal',
  ),

  // 🩺 RENAL - Medium Risk
  DiagnosisEntry(
    label: 'Chronic Kidney Disease',
    severity: RiskLevel.medium,
    code: 'N18.9',
    category: 'Renal',
  ),
  DiagnosisEntry(
    label: 'Kidney Stones',
    severity: RiskLevel.medium,
    code: 'N20.0',
    category: 'Renal',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🦴 MUSCULOSKELETAL - Medium Risk
  // ═══════════════════════════════════════════════════════════════
  DiagnosisEntry(
    label: 'Hip Fracture',
    severity: RiskLevel.medium,
    code: 'S72.009A',
    category: 'Musculoskeletal',
  ),
  DiagnosisEntry(
    label: 'Spinal Cord Injury',
    severity: RiskLevel.medium,
    code: 'S14.109A',
    category: 'Musculoskeletal',
  ),
  DiagnosisEntry(
    label: 'Multiple Trauma',
    severity: RiskLevel.medium,
    code: 'T07',
    category: 'Musculoskeletal',
  ),

  // 🦴 MUSCULOSKELETAL - Low Risk
  DiagnosisEntry(
    label: 'Arthritis',
    severity: RiskLevel.low,
    code: 'M19.90',
    category: 'Musculoskeletal',
  ),
  DiagnosisEntry(
    label: 'Osteoporosis',
    severity: RiskLevel.low,
    code: 'M81.0',
    category: 'Musculoskeletal',
  ),
  DiagnosisEntry(
    label: 'Back Pain',
    severity: RiskLevel.low,
    code: 'M54.9',
    category: 'Musculoskeletal',
  ),
  DiagnosisEntry(
    label: 'Mobility Impairment',
    severity: RiskLevel.low,
    code: 'Z74.09',
    category: 'Musculoskeletal',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🩹 INTEGUMENTARY - Medium Risk
  // ═══════════════════════════════════════════════════════════════
  DiagnosisEntry(
    label: 'Wound Dehiscence',
    severity: RiskLevel.medium,
    code: 'T81.31',
    category: 'Integumentary',
  ),
  DiagnosisEntry(
    label: 'Pressure Ulcer Stage 3',
    severity: RiskLevel.medium,
    code: 'L89.93',
    category: 'Integumentary',
  ),
  DiagnosisEntry(
    label: 'Pressure Ulcer Stage 4',
    severity: RiskLevel.medium,
    code: 'L89.94',
    category: 'Integumentary',
  ),

  // 🩹 INTEGUMENTARY - Low Risk
  DiagnosisEntry(
    label: 'Pressure Ulcer Stage 1',
    severity: RiskLevel.low,
    code: 'L89.91',
    category: 'Integumentary',
  ),
  DiagnosisEntry(
    label: 'Pressure Ulcer Stage 2',
    severity: RiskLevel.low,
    code: 'L89.92',
    category: 'Integumentary',
  ),
  DiagnosisEntry(
    label: 'Chronic Wound',
    severity: RiskLevel.low,
    code: 'L89.90',
    category: 'Integumentary',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🩸 HEMATOLOGIC - Medium Risk
  // ═══════════════════════════════════════════════════════════════
  DiagnosisEntry(
    label: 'Deep Vein Thrombosis',
    severity: RiskLevel.medium,
    code: 'I82.40',
    category: 'Hematologic',
  ),
  DiagnosisEntry(
    label: 'Coagulopathy',
    severity: RiskLevel.medium,
    code: 'D68.9',
    category: 'Hematologic',
  ),

  // 🩸 HEMATOLOGIC - Low Risk
  DiagnosisEntry(
    label: 'Anemia',
    severity: RiskLevel.low,
    code: 'D64.9',
    category: 'Hematologic',
  ),
  DiagnosisEntry(
    label: 'Iron Deficiency',
    severity: RiskLevel.low,
    code: 'D50.9',
    category: 'Hematologic',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🌡️ GENERAL/OTHER - Medium Risk
  // ═══════════════════════════════════════════════════════════════
  DiagnosisEntry(
    label: 'Moderate Dehydration',
    severity: RiskLevel.medium,
    code: 'E86.0',
    category: 'Other',
  ),
  DiagnosisEntry(
    label: 'Electrolyte Imbalance',
    severity: RiskLevel.medium,
    code: 'E87.8',
    category: 'Other',
  ),
  DiagnosisEntry(
    label: 'Malnutrition',
    severity: RiskLevel.medium,
    code: 'E44.0',
    category: 'Other',
  ),

  // 🌡️ GENERAL/OTHER - Low Risk
  DiagnosisEntry(
    label: 'Mild Dehydration',
    severity: RiskLevel.low,
    code: 'E86.1',
    category: 'Other',
  ),
  DiagnosisEntry(
    label: 'Fall History',
    severity: RiskLevel.low,
    code: 'Z91.81',
    category: 'Other',
  ),
  DiagnosisEntry(
    label: 'Incontinence',
    severity: RiskLevel.low,
    code: 'R32',
    category: 'Other',
  ),
  DiagnosisEntry(
    label: 'Insomnia',
    severity: RiskLevel.low,
    code: 'G47.00',
    category: 'Other',
  ),
  DiagnosisEntry(
    label: 'Fatigue',
    severity: RiskLevel.low,
    code: 'R53.83',
    category: 'Other',
  ),
  DiagnosisEntry(
    label: 'Pain Management',
    severity: RiskLevel.low,
    code: 'G89.3',
    category: 'Other',
  ),
];

/// 🔍 Lookup helper
RiskLevel getRiskForDiagnosis(String diagnosis) {
  return diagnosisCatalog
      .firstWhere(
        (d) => d.label.toLowerCase() == diagnosis.toLowerCase().trim(),
        orElse: () => DiagnosisEntry(
          label: diagnosis,
          severity: RiskLevel.unknown,
          category: 'Other',
        ),
      )
      .severity;
}

/// 📊 Get diagnoses by category
List<DiagnosisEntry> getDiagnosesByCategory(String category) {
  return diagnosisCatalog
      .where((d) => d.category.toLowerCase() == category.toLowerCase())
      .toList();
}

/// 📈 Get diagnoses by risk level
List<DiagnosisEntry> getDiagnosesByRisk(RiskLevel risk) {
  return diagnosisCatalog.where((d) => d.severity == risk).toList();
}

/// 🔤 Get all available categories
List<String> getAvailableCategories() {
  return diagnosisCatalog.map((d) => d.category).toSet().toList()..sort();
}

/// ⭐ Get most common diagnoses (top 15 most frequently used)
List<DiagnosisEntry> getCommonDiagnoses() {
  return [
    diagnosisCatalog.firstWhere((d) => d.label == 'Hypertension'),
    diagnosisCatalog.firstWhere((d) => d.label == 'Type 2 Diabetes'),
    diagnosisCatalog.firstWhere((d) => d.label == 'Pneumonia'),
    diagnosisCatalog.firstWhere((d) => d.label == 'UTI'),
    diagnosisCatalog.firstWhere((d) => d.label == 'Congestive Heart Failure'),
    diagnosisCatalog.firstWhere((d) => d.label == 'COPD Exacerbation'),
    diagnosisCatalog.firstWhere((d) => d.label == 'Atrial Fibrillation'),
    diagnosisCatalog.firstWhere((d) => d.label == 'Delirium'),
    diagnosisCatalog.firstWhere((d) => d.label == 'Fall History'),
    diagnosisCatalog.firstWhere((d) => d.label == 'Anemia'),
    diagnosisCatalog.firstWhere((d) => d.label == 'Dementia'),
    diagnosisCatalog.firstWhere((d) => d.label == 'Cellulitis'),
    diagnosisCatalog.firstWhere((d) => d.label == 'Arthritis'),
    diagnosisCatalog.firstWhere((d) => d.label == 'Depression'),
    diagnosisCatalog.firstWhere((d) => d.label == 'Chronic Kidney Disease'),
  ];
}
