// 📁 lib/features/patient/models/medication_catalog.dart

/// 💊 Comprehensive medication catalog for patient care
///
/// This file contains standardized lists of common medications organized by
/// therapeutic class and clinical priority. Should be reviewed periodically
/// by clinical staff to ensure completeness and accuracy.
library;

/// 💊 Common Medications by Therapeutic Class
///
/// Ordered by frequency/priority in healthcare settings.
/// "No medications" should always be first option.
const List<String> commonMedications = [
  // Most common selection
  'No current medications',

  // ═══════════════════════════════════════════════════════════════
  // 🫀 CARDIOVASCULAR - High Priority
  // ═══════════════════════════════════════════════════════════════

  // Blood Pressure - ACE Inhibitors
  'Lisinopril',
  'Enalapril',
  'Captopril',

  // Blood Pressure - ARBs
  'Losartan',
  'Valsartan',
  'Irbesartan',

  // Blood Pressure - Beta Blockers
  'Metoprolol',
  'Atenolol',
  'Propranolol',
  'Carvedilol',

  // Blood Pressure - Calcium Channel Blockers
  'Amlodipine',
  'Nifedipine',
  'Diltiazem',
  'Verapamil',

  // Blood Pressure - Diuretics
  'Hydrochlorothiazide (HCTZ)',
  'Furosemide (Lasix)',
  'Spironolactone',
  'Chlorthalidone',

  // Heart/Rhythm
  'Digoxin',
  'Amiodarone',
  'Warfarin (Coumadin)',
  'Apixaban (Eliquis)',
  'Rivaroxaban (Xarelto)',

  // Cholesterol
  'Atorvastatin (Lipitor)',
  'Simvastatin (Zocor)',
  'Rosuvastatin (Crestor)',

  // ═══════════════════════════════════════════════════════════════
  // 🩸 DIABETES & ENDOCRINE
  // ═══════════════════════════════════════════════════════════════

  // Diabetes - Insulin
  'Insulin - Humalog',
  'Insulin - NovoLog',
  'Insulin - Lantus',
  'Insulin - Levemir',
  'Insulin - Regular',
  'Insulin - NPH',

  // Diabetes - Oral
  'Metformin',
  'Glipizide',
  'Glyburide',
  'Januvia (Sitagliptin)',
  'Jardiance (Empagliflozin)',

  // Thyroid
  'Levothyroxine (Synthroid)',
  'Liothyronine (Cytomel)',

  // ═══════════════════════════════════════════════════════════════
  // 🦴 PAIN & INFLAMMATION
  // ═══════════════════════════════════════════════════════════════

  // Pain - Opioids (High Alert)
  'Morphine',
  'Oxycodone',
  'Hydrocodone',
  'Fentanyl',
  'Tramadol',
  'Codeine',

  // Pain - Non-Opioid
  'Acetaminophen (Tylenol)',
  'Ibuprofen (Advil)',
  'Naproxen (Aleve)',
  'Aspirin',
  'Celecoxib (Celebrex)',
  'Gabapentin',
  'Pregabalin (Lyrica)',

  // ═══════════════════════════════════════════════════════════════
  // 🧠 NEUROLOGICAL & PSYCHIATRIC
  // ═══════════════════════════════════════════════════════════════

  // Seizures
  'Phenytoin (Dilantin)',
  'Carbamazepine',
  'Valproic Acid',
  'Levetiracetam (Keppra)',
  'Lamotrigine',

  // Depression/Anxiety
  'Sertraline (Zoloft)',
  'Fluoxetine (Prozac)',
  'Escitalopram (Lexapro)',
  'Venlafaxine (Effexor)',
  'Alprazolam (Xanax)',
  'Lorazepam (Ativan)',
  'Clonazepam (Klonopin)',

  // Sleep
  'Zolpidem (Ambien)',
  'Trazodone',
  'Melatonin',

  // ═══════════════════════════════════════════════════════════════
  // 🫁 RESPIRATORY
  // ═══════════════════════════════════════════════════════════════

  // Asthma/COPD - Inhalers
  'Albuterol (ProAir/Ventolin)',
  'Ipratropium (Atrovent)',
  'Fluticasone (Flovent)',
  'Budesonide/Formoterol (Symbicort)',
  'Fluticasone/Salmeterol (Advair)',

  // Respiratory - Oral
  'Prednisone',
  'Prednisolone',
  'Montelukast (Singulair)',

  // ═══════════════════════════════════════════════════════════════
  // 🦠 ANTIMICROBIALS
  // ═══════════════════════════════════════════════════════════════

  // Antibiotics - Common
  'Amoxicillin',
  'Azithromycin (Z-pack)',
  'Ciprofloxacin',
  'Levofloxacin',
  'Cephalexin',
  'Doxycycline',
  'Clindamycin',
  'Vancomycin',

  // ═══════════════════════════════════════════════════════════════
  // 🍽️ GASTROINTESTINAL
  // ═══════════════════════════════════════════════════════════════

  // Acid Reducers
  'Omeprazole (Prilosec)',
  'Pantoprazole (Protonix)',
  'Esomeprazole (Nexium)',
  'Ranitidine',
  'Famotidine (Pepcid)',

  // GI Motility
  'Metoclopramide (Reglan)',
  'Ondansetron (Zofran)',
  'Docusate (Colace)',
  'Senna',
  'Polyethylene Glycol (Miralax)',

  // ═══════════════════════════════════════════════════════════════
  // 🩸 HEMATOLOGIC
  // ═══════════════════════════════════════════════════════════════

  // Anticoagulation
  'Heparin',
  'Enoxaparin (Lovenox)',
  'Clopidogrel (Plavix)',

  // Anemia
  'Iron Sulfate',
  'Ferrous Gluconate',
  'Epoetin (Procrit)',

  // ═══════════════════════════════════════════════════════════════
  // 💊 VITAMINS & SUPPLEMENTS
  // ═══════════════════════════════════════════════════════════════

  'Vitamin D3',
  'Vitamin B12',
  'Folic Acid',
  'Calcium Carbonate',
  'Magnesium',
  'Potassium Chloride',
  'Multivitamin',
];

/// 🏥 Medication Categories for Organization
enum MedicationCategory {
  cardiovascular,
  diabetes,
  pain,
  neurological,
  respiratory,
  antimicrobial,
  gastrointestinal,
  hematologic,
  vitamins,
  other,
}

/// ⚠️ High-Alert Medication Classifications
enum MedicationRisk {
  high, // Opioids, anticoagulants, insulin
  medium, // Seizure meds, cardiac drugs
  low, // Vitamins, simple analgesics
  unknown,
}

/// 🧠 Medication Management Utilities
class MedicationUtils {
  /// Determines the therapeutic category of a medication
  static MedicationCategory categorizeMedication(String medication) {
    final lower = medication.toLowerCase();

    if (_cardiovascularMeds.any((med) => lower.contains(med.toLowerCase()))) {
      return MedicationCategory.cardiovascular;
    }
    if (_diabetesMeds.any((med) => lower.contains(med.toLowerCase()))) {
      return MedicationCategory.diabetes;
    }
    if (_painMeds.any((med) => lower.contains(med.toLowerCase()))) {
      return MedicationCategory.pain;
    }
    if (_neurologicalMeds.any((med) => lower.contains(med.toLowerCase()))) {
      return MedicationCategory.neurological;
    }
    if (_respiratoryMeds.any((med) => lower.contains(med.toLowerCase()))) {
      return MedicationCategory.respiratory;
    }
    if (_antimicrobialMeds.any((med) => lower.contains(med.toLowerCase()))) {
      return MedicationCategory.antimicrobial;
    }
    if (_giMeds.any((med) => lower.contains(med.toLowerCase()))) {
      return MedicationCategory.gastrointestinal;
    }
    if (_hematologicMeds.any((med) => lower.contains(med.toLowerCase()))) {
      return MedicationCategory.hematologic;
    }
    if (_vitaminsMeds.any((med) => lower.contains(med.toLowerCase()))) {
      return MedicationCategory.vitamins;
    }

    return MedicationCategory.other;
  }

  /// Determines if a medication is high-alert/high-risk
  static MedicationRisk assessMedicationRisk(String medication) {
    final lower = medication.toLowerCase();

    if (_highAlertMeds.any((med) => lower.contains(med.toLowerCase()))) {
      return MedicationRisk.high;
    }
    if (_mediumRiskMeds.any((med) => lower.contains(med.toLowerCase()))) {
      return MedicationRisk.medium;
    }
    if (_lowRiskMeds.any((med) => lower.contains(med.toLowerCase()))) {
      return MedicationRisk.low;
    }

    return MedicationRisk.unknown;
  }

  /// Returns if medication requires special monitoring
  static bool requiresMonitoring(String medication) {
    final lower = medication.toLowerCase();
    return _monitoringRequired.any((med) => lower.contains(med.toLowerCase()));
  }
}

// Private helper lists for categorization
const _cardiovascularMeds = [
  'lisinopril',
  'enalapril',
  'captopril',
  'losartan',
  'valsartan',
  'irbesartan',
  'metoprolol',
  'atenolol',
  'propranolol',
  'carvedilol',
  'amlodipine',
  'nifedipine',
  'diltiazem',
  'verapamil',
  'hydrochlorothiazide',
  'hctz',
  'furosemide',
  'lasix',
  'spironolactone',
  'chlorthalidone',
  'digoxin',
  'amiodarone',
  'warfarin',
  'coumadin',
  'apixaban',
  'eliquis',
  'rivaroxaban',
  'xarelto',
  'atorvastatin',
  'lipitor',
  'simvastatin',
  'zocor',
  'rosuvastatin',
  'crestor'
];

const _diabetesMeds = [
  'insulin',
  'humalog',
  'novolog',
  'lantus',
  'levemir',
  'metformin',
  'glipizide',
  'glyburide',
  'januvia',
  'sitagliptin',
  'jardiance',
  'empagliflozin'
];

const _painMeds = [
  'morphine',
  'oxycodone',
  'hydrocodone',
  'fentanyl',
  'tramadol',
  'codeine',
  'acetaminophen',
  'tylenol',
  'ibuprofen',
  'advil',
  'naproxen',
  'aleve',
  'aspirin',
  'celecoxib',
  'celebrex',
  'gabapentin',
  'pregabalin',
  'lyrica'
];

const _neurologicalMeds = [
  'phenytoin',
  'dilantin',
  'carbamazepine',
  'valproic',
  'levetiracetam',
  'keppra',
  'lamotrigine',
  'sertraline',
  'zoloft',
  'fluoxetine',
  'prozac',
  'escitalopram',
  'lexapro',
  'venlafaxine',
  'effexor',
  'alprazolam',
  'xanax',
  'lorazepam',
  'ativan',
  'clonazepam',
  'klonopin',
  'zolpidem',
  'ambien',
  'trazodone',
  'melatonin'
];

const _respiratoryMeds = [
  'albuterol',
  'proair',
  'ventolin',
  'ipratropium',
  'atrovent',
  'fluticasone',
  'flovent',
  'budesonide',
  'symbicort',
  'advair',
  'prednisone',
  'prednisolone',
  'montelukast',
  'singulair'
];

const _antimicrobialMeds = [
  'amoxicillin',
  'azithromycin',
  'ciprofloxacin',
  'levofloxacin',
  'cephalexin',
  'doxycycline',
  'clindamycin',
  'vancomycin'
];

const _giMeds = [
  'omeprazole',
  'prilosec',
  'pantoprazole',
  'protonix',
  'esomeprazole',
  'nexium',
  'ranitidine',
  'famotidine',
  'pepcid',
  'metoclopramide',
  'reglan',
  'ondansetron',
  'zofran',
  'docusate',
  'colace',
  'senna',
  'miralax'
];

const _hematologicMeds = [
  'heparin',
  'enoxaparin',
  'lovenox',
  'clopidogrel',
  'plavix',
  'iron',
  'ferrous',
  'epoetin',
  'procrit'
];

const _vitaminsMeds = [
  'vitamin',
  'calcium',
  'magnesium',
  'potassium',
  'folic',
  'multivitamin'
];

// High-alert medications requiring special precautions
const _highAlertMeds = [
  'insulin',
  'morphine',
  'oxycodone',
  'hydrocodone',
  'fentanyl',
  'warfarin',
  'coumadin',
  'heparin',
  'digoxin',
  'amiodarone',
  'phenytoin',
  'vancomycin'
];

// Medium-risk medications requiring monitoring
const _mediumRiskMeds = [
  'metoprolol',
  'lisinopril',
  'furosemide',
  'lasix',
  'prednisone',
  'gabapentin',
  'sertraline',
  'alprazolam',
  'xanax',
  'lorazepam',
  'ativan'
];

// Low-risk medications
const _lowRiskMeds = [
  'acetaminophen',
  'tylenol',
  'vitamin',
  'calcium',
  'magnesium',
  'melatonin',
  'docusate',
  'colace',
  'senna'
];

// Medications requiring regular monitoring/lab work
const _monitoringRequired = [
  'warfarin',
  'coumadin',
  'digoxin',
  'phenytoin',
  'carbamazepine',
  'valproic',
  'lithium',
  'vancomycin',
  'amiodarone',
  'metformin',
  'insulin'
];
