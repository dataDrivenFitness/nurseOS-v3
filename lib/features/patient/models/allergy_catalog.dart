// 📁 lib/features/patient/models/allergy_catalog.dart

/// 🚨 Single allergy definition
class AllergyEntry {
  final String label;
  final String severity; // Mild, Moderate, Severe
  final String category;
  final String? description;

  const AllergyEntry({
    required this.label,
    required this.severity,
    required this.category,
    this.description,
  });
}

/// 📚 Central catalog of allergies organized by category and severity
const List<AllergyEntry> allergyCatalog = [
  // ═══════════════════════════════════════════════════════════════
  // 💊 MEDICATIONS - Severe
  // ═══════════════════════════════════════════════════════════════
  AllergyEntry(
    label: 'Penicillin',
    severity: 'Severe',
    category: 'Medications',
    description: 'Can cause anaphylaxis, rash, breathing difficulties',
  ),
  AllergyEntry(
    label: 'Sulfa',
    severity: 'Severe',
    category: 'Medications',
    description: 'Stevens-Johnson syndrome, severe skin reactions',
  ),
  AllergyEntry(
    label: 'Aspirin',
    severity: 'Moderate',
    category: 'Medications',
    description: 'GI bleeding, bronchospasm',
  ),
  AllergyEntry(
    label: 'Codeine',
    severity: 'Moderate',
    category: 'Medications',
    description: 'Respiratory depression, nausea, vomiting',
  ),
  AllergyEntry(
    label: 'Morphine',
    severity: 'Moderate',
    category: 'Medications',
    description: 'Respiratory depression, severe itching',
  ),
  AllergyEntry(
    label: 'Iodine',
    severity: 'Severe',
    category: 'Medications',
    description: 'Contrast dye reactions, anaphylaxis',
  ),
  AllergyEntry(
    label: 'Contrast Dye',
    severity: 'Severe',
    category: 'Medications',
    description: 'Anaphylaxis, kidney damage',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🦞 FOOD ALLERGIES - Severe
  // ═══════════════════════════════════════════════════════════════
  AllergyEntry(
    label: 'Shellfish',
    severity: 'Severe',
    category: 'Food',
    description: 'Anaphylaxis, severe breathing difficulties',
  ),
  AllergyEntry(
    label: 'Tree Nuts',
    severity: 'Severe',
    category: 'Food',
    description: 'Anaphylaxis, swelling, breathing problems',
  ),
  AllergyEntry(
    label: 'Peanuts',
    severity: 'Severe',
    category: 'Food',
    description: 'Anaphylaxis, cross-contamination risk',
  ),
  AllergyEntry(
    label: 'Eggs',
    severity: 'Moderate',
    category: 'Food',
    description: 'Digestive upset, skin reactions',
  ),
  AllergyEntry(
    label: 'Dairy/Milk',
    severity: 'Moderate',
    category: 'Food',
    description: 'Digestive issues, different from lactose intolerance',
  ),
  AllergyEntry(
    label: 'Soy',
    severity: 'Moderate',
    category: 'Food',
    description: 'Digestive upset, skin reactions',
  ),
  AllergyEntry(
    label: 'Wheat/Gluten',
    severity: 'Moderate',
    category: 'Food',
    description: 'Celiac disease, severe digestive issues',
  ),
  AllergyEntry(
    label: 'Fish',
    severity: 'Moderate',
    category: 'Food',
    description: 'Respiratory and skin reactions',
  ),
  AllergyEntry(
    label: 'Sesame',
    severity: 'Moderate',
    category: 'Food',
    description: 'Growing concern, can be severe',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🏥 ENVIRONMENTAL/MEDICAL - Various
  // ═══════════════════════════════════════════════════════════════
  AllergyEntry(
    label: 'Latex',
    severity: 'Severe',
    category: 'Environmental',
    description: 'Anaphylaxis, contact dermatitis, airborne particles',
  ),
  AllergyEntry(
    label: 'Adhesive/Tape',
    severity: 'Mild',
    category: 'Environmental',
    description: 'Contact dermatitis, skin breakdown',
  ),
  AllergyEntry(
    label: 'Bee Stings',
    severity: 'Severe',
    category: 'Environmental',
    description: 'Anaphylaxis, severe local reactions',
  ),
  AllergyEntry(
    label: 'Wasp Stings',
    severity: 'Severe',
    category: 'Environmental',
    description: 'Anaphylaxis, severe swelling',
  ),
  AllergyEntry(
    label: 'Fire Ant Stings',
    severity: 'Moderate',
    category: 'Environmental',
    description: 'Severe local reactions, pustules',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🌿 ENVIRONMENTAL ALLERGENS - Mild to Moderate
  // ═══════════════════════════════════════════════════════════════
  AllergyEntry(
    label: 'Dust Mites',
    severity: 'Moderate',
    category: 'Environmental',
    description: 'Respiratory symptoms, asthma triggers',
  ),
  AllergyEntry(
    label: 'Pollen',
    severity: 'Moderate',
    category: 'Environmental',
    description: 'Seasonal allergies, respiratory symptoms',
  ),
  AllergyEntry(
    label: 'Pet Dander',
    severity: 'Moderate',
    category: 'Environmental',
    description: 'Cats and dogs, respiratory and skin reactions',
  ),
  AllergyEntry(
    label: 'Mold',
    severity: 'Moderate',
    category: 'Environmental',
    description: 'Respiratory symptoms, especially in damp environments',
  ),
  AllergyEntry(
    label: 'Grass Pollen',
    severity: 'Mild',
    category: 'Environmental',
    description: 'Seasonal hay fever symptoms',
  ),
  AllergyEntry(
    label: 'Tree Pollen',
    severity: 'Mild',
    category: 'Environmental',
    description: 'Spring allergies, respiratory symptoms',
  ),
  AllergyEntry(
    label: 'Ragweed',
    severity: 'Moderate',
    category: 'Environmental',
    description: 'Fall allergies, very common',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🧴 CHEMICALS/MATERIALS - Mild to Moderate
  // ═══════════════════════════════════════════════════════════════
  AllergyEntry(
    label: 'Nickel',
    severity: 'Mild',
    category: 'Materials',
    description: 'Contact dermatitis from jewelry, medical devices',
  ),
  AllergyEntry(
    label: 'Fragrance',
    severity: 'Mild',
    category: 'Materials',
    description: 'Skin irritation, respiratory symptoms',
  ),
  AllergyEntry(
    label: 'Chlorhexidine',
    severity: 'Moderate',
    category: 'Materials',
    description: 'Common antiseptic, can cause severe reactions',
  ),
  AllergyEntry(
    label: 'Formaldehyde',
    severity: 'Moderate',
    category: 'Materials',
    description: 'Found in some medical products, building materials',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🌸 PLANT ALLERGIES - Mild to Moderate
  // ═══════════════════════════════════════════════════════════════
  AllergyEntry(
    label: 'Poison Ivy',
    severity: 'Moderate',
    category: 'Plants',
    description: 'Contact dermatitis, severe itching and blistering',
  ),
  AllergyEntry(
    label: 'Poison Oak',
    severity: 'Moderate',
    category: 'Plants',
    description: 'Contact dermatitis, regional variations',
  ),
  AllergyEntry(
    label: 'Poison Sumac',
    severity: 'Moderate',
    category: 'Plants',
    description: 'Severe contact dermatitis, wetland areas',
  ),
];

/// 🔍 Lookup helper
String getSeverityForAllergy(String allergy) {
  return allergyCatalog
      .firstWhere(
        (a) => a.label.toLowerCase() == allergy.toLowerCase().trim(),
        orElse: () => const AllergyEntry(
          label: 'Unknown',
          severity: 'Unknown',
          category: 'Other',
        ),
      )
      .severity;
}

/// 📊 Get allergies by category
List<AllergyEntry> getAllergiesByCategory(String category) {
  return allergyCatalog
      .where((a) => a.category.toLowerCase() == category.toLowerCase())
      .toList();
}

/// 📈 Get allergies by severity
List<AllergyEntry> getAllergiesBySeverity(String severity) {
  return allergyCatalog
      .where((a) => a.severity.toLowerCase() == severity.toLowerCase())
      .toList();
}

/// 🔤 Get all available categories
List<String> getAllergyCategories() {
  return allergyCatalog.map((a) => a.category).toSet().toList()..sort();
}

/// ⭐ Get most common allergies (top 15 most frequently documented)
List<AllergyEntry> getCommonAllergies() {
  return [
    allergyCatalog.firstWhere((a) => a.label == 'Penicillin'),
    allergyCatalog.firstWhere((a) => a.label == 'Latex'),
    allergyCatalog.firstWhere((a) => a.label == 'Shellfish'),
    allergyCatalog.firstWhere((a) => a.label == 'Tree Nuts'),
    allergyCatalog.firstWhere((a) => a.label == 'Peanuts'),
    allergyCatalog.firstWhere((a) => a.label == 'Eggs'),
    allergyCatalog.firstWhere((a) => a.label == 'Dairy/Milk'),
    allergyCatalog.firstWhere((a) => a.label == 'Iodine'),
    allergyCatalog.firstWhere((a) => a.label == 'Aspirin'),
    allergyCatalog.firstWhere((a) => a.label == 'Sulfa'),
    allergyCatalog.firstWhere((a) => a.label == 'Codeine'),
    allergyCatalog.firstWhere((a) => a.label == 'Contrast Dye'),
    allergyCatalog.firstWhere((a) => a.label == 'Adhesive/Tape'),
    allergyCatalog.firstWhere((a) => a.label == 'Bee Stings'),
    allergyCatalog.firstWhere((a) => a.label == 'Dust Mites'),
  ];
}
