// 📁 lib/features/patient/presentation/screens/select_allergy_screen.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/allergy_catalog.dart';
import 'package:nurseos_v3/features/patient/services/favorites_service.dart';
import 'package:nurseos_v3/shared/widgets/select_items_screen.dart';

class SelectAllergyScreen extends StatefulWidget {
  final List<String> initialSelection;

  const SelectAllergyScreen({super.key, required this.initialSelection});

  @override
  State<SelectAllergyScreen> createState() => _SelectAllergyScreenState();
}

class _SelectAllergyScreenState extends State<SelectAllergyScreen> {
  List<String> favoriteAllergies = [];
  List<String> recentAllergies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load both favorites and recent items from storage
  Future<void> _loadData() async {
    try {
      // Load both favorites and recent items in parallel
      final results = await Future.wait([
        FavoritesService.loadFavoriteAllergies(),
        FavoritesService.loadRecentAllergies(),
      ]);

      setState(() {
        favoriteAllergies = results[0];
        recentAllergies = results[1];
        _isLoading = false;
      });

      // 🔍 Enhanced debugging
      print(
          '🔍 LOADED ${favoriteAllergies.length} favorite allergies: $favoriteAllergies');
      print(
          '🕒 LOADED ${recentAllergies.length} recent allergies: $recentAllergies');
    } catch (e) {
      print('⚠️ Error loading allergy data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Toggle an allergy in favorites and update UI
  Future<void> _toggleFavoriteAllergy(String allergyId) async {
    try {
      final wasInFavorites = favoriteAllergies.contains(allergyId);
      final updatedFavorites =
          await FavoritesService.toggleFavoriteAllergy(allergyId);

      setState(() {
        favoriteAllergies = updatedFavorites;
      });

      // 🔍 Enhanced debugging
      print('🔄 ${wasInFavorites ? 'REMOVED' : 'ADDED'}: $allergyId');
      print('🔍 NEW FAVORITES LIST: $updatedFavorites');
    } catch (e) {
      print('⚠️ Error toggling favorite allergy: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update favorites'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle when user hits "Done" - track selected items as recently used
  Future<void> _handleDone(List<String> selectedItems) async {
    if (selectedItems.isNotEmpty) {
      try {
        // Track the selected items as recently used
        final updatedRecent =
            await FavoritesService.addRecentAllergies(selectedItems);

        // Don't setState here since we're about to navigate away
        print('🕒 ADDED TO RECENT ALLERGIES: $selectedItems');
        print('🕒 NEW RECENT ALLERGIES LIST: $updatedRecent');
      } catch (e) {
        print('⚠️ Error updating recent allergies: $e');
      }
    }

    // Return the selected items (original functionality)
    if (mounted) {
      Navigator.pop(context, selectedItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    // Show loading while data loads
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Allergies')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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

    return SelectItemsScreen(
      initialSelection: widget.initialSelection,
      allItems: allItems,
      recentItems: recentAllergies, // 🆕 Now using real recent data
      commonItems: const [], // 🆕 Empty - using favorites instead
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
      // 🆕 Enable favorites functionality
      favoriteItems: favoriteAllergies,
      onToggleFavorite: _toggleFavoriteAllergy,
      onDone: _handleDone, // 🆕 Handle when user hits Done
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
