// 📁 lib/features/patient/models/dietary_catalog.dart

/// 🥗 Single dietary restriction definition
class DietaryEntry {
  final String label;
  final String type; // Medical, Texture, Cultural, Personal
  final String category;
  final String? description;

  const DietaryEntry({
    required this.label,
    required this.type,
    required this.category,
    this.description,
  });
}

/// 📚 Central catalog of dietary restrictions organized by type and category
const List<DietaryEntry> dietaryCatalog = [
  // ═══════════════════════════════════════════════════════════════
  // 🏥 MEDICAL DIETS - Critical for patient safety
  // ═══════════════════════════════════════════════════════════════
  DietaryEntry(
    label: 'NPO (Nothing by Mouth)',
    type: 'Medical',
    category: 'Restricted',
    description: 'No food or fluids - pre-surgery or medical condition',
  ),
  DietaryEntry(
    label: 'Clear Liquids Only',
    type: 'Medical',
    category: 'Restricted',
    description: 'Water, clear broths, plain gelatin, clear juices',
  ),
  DietaryEntry(
    label: 'Full Liquids',
    type: 'Medical',
    category: 'Restricted',
    description: 'All liquids including milk, smoothies, creamed soups',
  ),
  DietaryEntry(
    label: 'Diabetic Diet',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'Controlled carbohydrates, consistent timing',
  ),
  DietaryEntry(
    label: 'Low Sodium',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'Less than 2000mg sodium daily for heart/kidney health',
  ),
  DietaryEntry(
    label: 'Heart Healthy',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'Low saturated fat, high fiber, reduced cholesterol',
  ),
  DietaryEntry(
    label: 'Renal Diet',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'Restricted protein, phosphorus, potassium',
  ),
  DietaryEntry(
    label: 'Low Fat',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'For gallbladder, pancreas, or digestive issues',
  ),
  DietaryEntry(
    label: 'Low Cholesterol',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'Less than 200mg cholesterol daily',
  ),
  DietaryEntry(
    label: 'High Protein',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'For wound healing, muscle building, recovery',
  ),
  DietaryEntry(
    label: 'Low Protein',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'For kidney or liver disease',
  ),
  DietaryEntry(
    label: 'Low Fiber',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'For bowel rest, diverticulitis, IBD flares',
  ),
  DietaryEntry(
    label: 'High Fiber',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'For constipation, diabetes, heart health',
  ),
  DietaryEntry(
    label: 'BRAT Diet',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'Bananas, Rice, Applesauce, Toast for GI recovery',
  ),
  DietaryEntry(
    label: 'Bland Diet',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'Low spice, no acidic foods for GI sensitivity',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🍽️ TEXTURE MODIFICATIONS - Swallowing safety
  // ═══════════════════════════════════════════════════════════════
  DietaryEntry(
    label: 'Pureed Diet',
    type: 'Texture',
    category: 'Swallowing',
    description: 'Smooth, pudding-like consistency for dysphagia',
  ),
  DietaryEntry(
    label: 'Soft Diet',
    type: 'Texture',
    category: 'Swallowing',
    description: 'Easy to chew, no tough or hard foods',
  ),
  DietaryEntry(
    label: 'Mechanical Soft',
    type: 'Texture',
    category: 'Swallowing',
    description: 'Chopped, ground, or mashed to aid chewing',
  ),
  DietaryEntry(
    label: 'Minced and Moist',
    type: 'Texture',
    category: 'Swallowing',
    description: 'Finely chopped with sauce or gravy added',
  ),
  DietaryEntry(
    label: 'Thickened Liquids',
    type: 'Texture',
    category: 'Swallowing',
    description: 'Honey or nectar consistency for aspiration risk',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🌾 FOOD ALLERGIES/INTOLERANCES - Safety critical
  // ═══════════════════════════════════════════════════════════════
  DietaryEntry(
    label: 'Gluten Free',
    type: 'Medical',
    category: 'Allergy',
    description: 'No wheat, barley, rye - for celiac disease',
  ),
  DietaryEntry(
    label: 'Lactose Free',
    type: 'Medical',
    category: 'Intolerance',
    description: 'No dairy products with lactose',
  ),
  DietaryEntry(
    label: 'Nut Free',
    type: 'Medical',
    category: 'Allergy',
    description: 'No tree nuts or peanuts - severe allergy risk',
  ),
  DietaryEntry(
    label: 'Shellfish Free',
    type: 'Medical',
    category: 'Allergy',
    description: 'No crustaceans or mollusks - anaphylaxis risk',
  ),
  DietaryEntry(
    label: 'Egg Free',
    type: 'Medical',
    category: 'Allergy',
    description: 'No eggs or egg products',
  ),
  DietaryEntry(
    label: 'Soy Free',
    type: 'Medical',
    category: 'Allergy',
    description: 'No soy products or soy-derived ingredients',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🕌 CULTURAL/RELIGIOUS - Respect for beliefs
  // ═══════════════════════════════════════════════════════════════
  DietaryEntry(
    label: 'Kosher',
    type: 'Cultural',
    category: 'Religious',
    description: 'Jewish dietary laws - no pork, no meat with dairy',
  ),
  DietaryEntry(
    label: 'Halal',
    type: 'Cultural',
    category: 'Religious',
    description: 'Islamic dietary laws - no pork, no alcohol',
  ),
  DietaryEntry(
    label: 'Hindu Vegetarian',
    type: 'Cultural',
    category: 'Religious',
    description: 'No meat, often no beef specifically',
  ),
  DietaryEntry(
    label: 'Jain Vegetarian',
    type: 'Cultural',
    category: 'Religious',
    description: 'No meat, no root vegetables',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🌱 PERSONAL CHOICE - Lifestyle preferences
  // ═══════════════════════════════════════════════════════════════
  DietaryEntry(
    label: 'Vegetarian',
    type: 'Personal',
    category: 'Lifestyle',
    description: 'No meat, poultry, or fish',
  ),
  DietaryEntry(
    label: 'Vegan',
    type: 'Personal',
    category: 'Lifestyle',
    description: 'No animal products including dairy and eggs',
  ),
  DietaryEntry(
    label: 'Pescatarian',
    type: 'Personal',
    category: 'Lifestyle',
    description: 'No meat or poultry, but fish is allowed',
  ),
  DietaryEntry(
    label: 'Keto/Low Carb',
    type: 'Personal',
    category: 'Lifestyle',
    description: 'Very low carbohydrate, high fat diet',
  ),
  DietaryEntry(
    label: 'Paleo',
    type: 'Personal',
    category: 'Lifestyle',
    description: 'No grains, legumes, dairy, processed foods',
  ),

  // ═══════════════════════════════════════════════════════════════
  // 🍽️ STANDARD HOSPITAL DIETS
  // ═══════════════════════════════════════════════════════════════
  DietaryEntry(
    label: 'Regular Diet',
    type: 'Standard',
    category: 'Normal',
    description: 'No restrictions - standard hospital meals',
  ),
  DietaryEntry(
    label: 'ADA Diet',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'American Diabetes Association guidelines',
  ),
  DietaryEntry(
    label: 'Cardiac Diet',
    type: 'Medical',
    category: 'Therapeutic',
    description: 'Low sodium, low saturated fat, portion controlled',
  ),
];

/// 🔍 Lookup helper
String getTypeForDietaryRestriction(String restriction) {
  return dietaryCatalog
      .firstWhere(
        (d) => d.label.toLowerCase() == restriction.toLowerCase().trim(),
        orElse: () => const DietaryEntry(
          label: 'Unknown',
          type: 'Unknown',
          category: 'Other',
        ),
      )
      .type;
}

/// 📊 Get dietary restrictions by category
List<DietaryEntry> getDietaryByCategory(String category) {
  return dietaryCatalog
      .where((d) => d.category.toLowerCase() == category.toLowerCase())
      .toList();
}

/// 📈 Get dietary restrictions by type
List<DietaryEntry> getDietaryByType(String type) {
  return dietaryCatalog
      .where((d) => d.type.toLowerCase() == type.toLowerCase())
      .toList();
}

/// 🔤 Get all available categories
List<String> getDietaryCategories() {
  return dietaryCatalog.map((d) => d.category).toSet().toList()..sort();
}

/// 🔤 Get all available types
List<String> getDietaryTypes() {
  return dietaryCatalog.map((d) => d.type).toSet().toList()..sort();
}

/// ⭐ Get most common dietary restrictions (top 15 most frequently used)
List<DietaryEntry> getCommonDietaryRestrictions() {
  return [
    dietaryCatalog.firstWhere((d) => d.label == 'Regular Diet'),
    dietaryCatalog.firstWhere((d) => d.label == 'Diabetic Diet'),
    dietaryCatalog.firstWhere((d) => d.label == 'Low Sodium'),
    dietaryCatalog.firstWhere((d) => d.label == 'Heart Healthy'),
    dietaryCatalog.firstWhere((d) => d.label == 'Soft Diet'),
    dietaryCatalog.firstWhere((d) => d.label == 'Pureed Diet'),
    dietaryCatalog.firstWhere((d) => d.label == 'Mechanical Soft'),
    dietaryCatalog.firstWhere((d) => d.label == 'NPO (Nothing by Mouth)'),
    dietaryCatalog.firstWhere((d) => d.label == 'Clear Liquids Only'),
    dietaryCatalog.firstWhere((d) => d.label == 'Gluten Free'),
    dietaryCatalog.firstWhere((d) => d.label == 'Lactose Free'),
    dietaryCatalog.firstWhere((d) => d.label == 'Vegetarian'),
    dietaryCatalog.firstWhere((d) => d.label == 'Renal Diet'),
    dietaryCatalog.firstWhere((d) => d.label == 'Low Fat'),
    dietaryCatalog.firstWhere((d) => d.label == 'Kosher'),
  ];
}
