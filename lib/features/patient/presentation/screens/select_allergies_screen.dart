// 📁 lib/features/patient/presentation/screens/select_allergy_screen.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/allergy_catalog.dart';
import 'package:nurseos_v3/shared/widgets/select_items_screen.dart';

class SelectAllergyScreen extends StatelessWidget {
  final List<String> initialSelection;

  const SelectAllergyScreen({super.key, required this.initialSelection});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    // Convert AllergyEntry to SelectableItem
    final allItems = allergyCatalog
        .map((entry) => SelectableItem(
              id: entry.label, // Use label as ID for allergies
              label: entry.label,
              code: null, // Allergies don't have codes in your catalog
              category: entry.category,
              severity: _mapSeverityToSelectableItem(entry.severity),
              description: entry.description,
            ))
        .toList();

    // Recent allergies (in real app, get from user preferences)
    final recentAllergies = [
      'Penicillin',
      'Latex',
      'Shellfish',
      'Tree Nuts',
      'Peanuts'
    ];

    // Get common allergies from catalog
    final commonAllergies =
        getCommonAllergies().map((entry) => entry.label).toList();

    return SelectItemsScreen(
      initialSelection: initialSelection,
      allItems: allItems,
      recentItems: recentAllergies,
      commonItems: commonAllergies,
      config: SelectItemsConfig(
        title: 'Select Allergies',
        searchHint: 'Search allergies...',
        noItemsMessage: 'No allergies found',
        noSelectionMessage: 'No allergies selected',
        noSelectionSubMessage: 'Select allergies from the other tabs',
        itemTypeSingular: 'allergy',
        itemTypePlural: 'allergies',
        codeLabel: 'Type', // Since no codes, we can use 'Type' or hide codes
        showSeverityIndicator: true, // Allergies have severity
        showCodeField: false, // No codes in your allergy catalog
        showCategoryFilter: true,
        tabRecentIcon: Icons.access_time,
        tabSearchIcon: Icons.search,
        tabSelectedIcon: Icons.checklist,
        emptyStateIcon: Icons.warning_amber,
        accentColor: colors.warning, // 🎨 Orange accent for allergies
      ),
    );
  }

  /// Convert allergy severity string to SelectableItemSeverity
  SelectableItemSeverity _mapSeverityToSelectableItem(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return SelectableItemSeverity.high;
      case 'moderate':
        return SelectableItemSeverity.medium;
      case 'mild':
        return SelectableItemSeverity.low;
      default:
        return SelectableItemSeverity.unknown;
    }
  }
}
