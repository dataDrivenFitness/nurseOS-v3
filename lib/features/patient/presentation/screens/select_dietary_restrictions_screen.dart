// 📁 lib/features/patient/presentation/screens/select_dietary_restriction_screen.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/dietary_catalog.dart';
import 'package:nurseos_v3/shared/widgets/select_items_screen.dart';

class SelectDietaryRestrictionScreen extends StatelessWidget {
  final List<String> initialSelection;

  const SelectDietaryRestrictionScreen(
      {super.key, required this.initialSelection});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    // Convert DietaryEntry to SelectableItem
    final allItems = dietaryCatalog
        .map((entry) => SelectableItem(
              id: entry.label, // Use label as ID for dietary restrictions
              label: entry.label,
              code: entry
                  .type, // Use 'type' as the code field (Medical, Cultural, etc.)
              category: entry.category,
              severity: SelectableItemSeverity
                  .unknown, // Diet restrictions don't have severity
              description: entry.description,
            ))
        .toList();

    // Recent dietary restrictions (in real app, get from user preferences)
    final recentDietaryRestrictions = [
      'Regular Diet',
      'Diabetic Diet',
      'Low Sodium',
      'Soft Diet',
      'NPO (Nothing by Mouth)'
    ];

    // Get common dietary restrictions from catalog
    final commonDietaryRestrictions =
        getCommonDietaryRestrictions().map((entry) => entry.label).toList();

    return SelectItemsScreen(
      initialSelection: initialSelection,
      allItems: allItems,
      recentItems: recentDietaryRestrictions,
      commonItems: commonDietaryRestrictions,
      config: SelectItemsConfig(
        title: 'Select Diet Restrictions',
        searchHint: 'Search diet restrictions...',
        noItemsMessage: 'No diet restrictions found',
        noSelectionMessage: 'No diet restrictions selected',
        noSelectionSubMessage: 'Select restrictions from the other tabs',
        itemTypeSingular: 'diet restriction',
        itemTypePlural: 'diet restrictions',
        codeLabel: 'Type', // Shows Medical, Cultural, Personal, etc.
        showSeverityIndicator: false, // Diet restrictions don't have severity
        showCodeField: true, // Show the 'type' field (Medical, Cultural, etc.)
        showCategoryFilter: true,
        tabRecentIcon: Icons.access_time,
        tabSearchIcon: Icons.search,
        tabSelectedIcon: Icons.checklist,
        emptyStateIcon: Icons.restaurant_menu,
        accentColor: colors.success, // 🎨 Green accent for dietary restrictions
      ),
    );
  }
}
