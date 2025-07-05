// 📁 lib/features/patient/models/patient_safety_options.dart

/// 🚨 Critical safety information options for patient care
///
/// This file contains standardized lists of common allergies and dietary
/// restrictions used throughout the healthcare workflow. These should be
/// reviewed periodically by clinical staff to ensure completeness and accuracy.
library;

/// 🧬 Common Drug and Environmental Allergies
///
/// Ordered by frequency/severity in healthcare settings.
/// NKDA (No Known Drug Allergies) should always be first option.
const List<String> commonAllergies = [
  // Most common selection
  'NKDA', // No Known Drug Allergies

  // High-frequency drug allergies
  'Penicillin',
  'Sulfa drugs',
  'Latex',
  'Iodine/Contrast',

  // Pain medications
  'Morphine',
  'Codeine',
  'Aspirin',
  'NSAIDs',
  'Oxycodone',

  // Antibiotics
  'Amoxicillin',
  'Cephalexin',
  'Erythromycin',
  'Ciprofloxacin',

  // Food allergies (relevant to medication additives)
  'Shellfish',
  'Nuts',
  'Peanuts',
  'Tree nuts',
  'Eggs',
  'Dairy/Milk',
  'Soy',
  'Wheat/Gluten',

  // Environmental/procedural
  'Adhesive tape',
  'Betadine',
  'Chlorhexidine',
  'Surgical glue',

  // Other medications
  'Insulin',
  'Heparin',
  'Warfarin',
  'Statins',
];

/// 🍽️ Dietary Restrictions and Special Diets
///
/// Ordered by clinical priority and frequency.
/// NPO should always be first as it's the most critical.
const List<String> commonDietaryRestrictions = [
  // Critical/immediate restrictions
  'NPO', // Nothing by mouth - most critical
  'Clear liquids only',
  'NPO except medications',

  // Texture modifications (swallowing safety)
  'Pureed diet',
  'Mechanical soft',
  'Minced and moist',
  'Thickened liquids',
  'Soft diet',

  // Medical diet modifications
  'Diabetic diet',
  'Low sodium (2g)',
  'Low sodium (1g)',
  'Renal diet',
  'Cardiac diet',
  'Low fat',
  'Low protein',
  'High protein',
  'Low potassium',
  'Low phosphorus',

  // Standard progression diets
  'Full liquids',
  'Regular diet',
  'BRAT diet', // Banana, Rice, Applesauce, Toast

  // Religious/cultural restrictions
  'Kosher',
  'Halal',
  'Hindu vegetarian',

  // Lifestyle dietary choices
  'Vegetarian',
  'Vegan',
  'Gluten free',
  'Lactose free',

  // Special considerations
  'Finger foods only',
  'No hot liquids',
  'Room temperature only',
  'Small frequent meals',
];

/// 🏥 Clinical Allergy Categories
///
/// Helper to categorize allergies for better organization in UI
enum AllergyCategory {
  drug,
  food,
  environmental,
  unknown,
}

/// 🧠 Helper functions for allergy management
class AllergyUtils {
  /// Determines the category of an allergy for UI organization
  static AllergyCategory categorizeAllergy(String allergy) {
    final lower = allergy.toLowerCase();

    // Drug allergies
    if (_drugAllergies.any((drug) => lower.contains(drug.toLowerCase()))) {
      return AllergyCategory.drug;
    }

    // Food allergies
    if (_foodAllergies.any((food) => lower.contains(food.toLowerCase()))) {
      return AllergyCategory.food;
    }

    // Environmental
    if (_environmentalAllergies
        .any((env) => lower.contains(env.toLowerCase()))) {
      return AllergyCategory.environmental;
    }

    return AllergyCategory.unknown;
  }

  /// Returns severity indicator for common high-risk allergies
  static bool isHighRiskAllergy(String allergy) {
    final lower = allergy.toLowerCase();
    return _highRiskAllergies.any((risk) => lower.contains(risk.toLowerCase()));
  }
}

// Private helper lists for categorization
const _drugAllergies = [
  'penicillin',
  'sulfa',
  'morphine',
  'codeine',
  'aspirin',
  'nsaids',
  'amoxicillin',
  'cephalexin',
  'erythromycin',
  'ciprofloxacin',
  'insulin',
  'heparin',
  'warfarin',
  'statins',
  'oxycodone'
];

const _foodAllergies = [
  'shellfish',
  'nuts',
  'peanuts',
  'eggs',
  'dairy',
  'milk',
  'soy',
  'wheat',
  'gluten'
];

const _environmentalAllergies = [
  'latex',
  'iodine',
  'contrast',
  'adhesive',
  'betadine',
  'chlorhexidine'
];

const _highRiskAllergies = [
  'penicillin',
  'sulfa',
  'latex',
  'shellfish',
  'nuts',
  'iodine',
  'contrast'
];

/// 🎯 Diet Category Classifications
enum DietCategory {
  restriction, // NPO, clear liquids
  texture, // Pureed, mechanical soft
  medical, // Diabetic, renal
  cultural, // Kosher, halal
  lifestyle, // Vegetarian, vegan
}

/// 🧠 Helper functions for dietary management
class DietUtils {
  /// Determines if a diet restriction is critical/safety related
  static bool isCriticalDietRestriction(String restriction) {
    final lower = restriction.toLowerCase();
    return _criticalRestrictions
        .any((crit) => lower.contains(crit.toLowerCase()));
  }

  /// Categorizes dietary restrictions for UI organization
  static DietCategory categorizeDiet(String restriction) {
    final lower = restriction.toLowerCase();

    if (_restrictionDiets.any((r) => lower.contains(r.toLowerCase()))) {
      return DietCategory.restriction;
    }
    if (_textureDiets.any((t) => lower.contains(t.toLowerCase()))) {
      return DietCategory.texture;
    }
    if (_medicalDiets.any((m) => lower.contains(m.toLowerCase()))) {
      return DietCategory.medical;
    }
    if (_culturalDiets.any((c) => lower.contains(c.toLowerCase()))) {
      return DietCategory.cultural;
    }

    return DietCategory.lifestyle;
  }
}

// Private helper lists for diet categorization
const _criticalRestrictions = ['npo', 'clear liquids', 'thickened'];

const _restrictionDiets = ['npo', 'clear liquids', 'full liquids'];

const _textureDiets = [
  'pureed',
  'mechanical soft',
  'minced',
  'thickened',
  'soft diet'
];

const _medicalDiets = ['diabetic', 'renal', 'cardiac', 'low sodium', 'low fat'];

const _culturalDiets = ['kosher', 'halal', 'hindu'];
