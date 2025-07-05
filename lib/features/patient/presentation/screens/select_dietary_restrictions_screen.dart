// 📁 lib/features/patient/presentation/screens/select_dietary_restriction_screen.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/dietary_catalog.dart';
import 'package:nurseos_v3/features/patient/services/favorites_service.dart';
import 'package:nurseos_v3/shared/widgets/select_items_screen.dart';

class SelectDietaryRestrictionScreen extends StatefulWidget {
  final List<String> initialSelection;

  const SelectDietaryRestrictionScreen(
      {super.key, required this.initialSelection});

  @override
  State<SelectDietaryRestrictionScreen> createState() =>
      _SelectDietaryRestrictionScreenState();
}

class _SelectDietaryRestrictionScreenState
    extends State<SelectDietaryRestrictionScreen> {
  List<String> favoriteDietaryRestrictions = [];
  List<String> recentDietaryRestrictions = [];
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
        FavoritesService.loadFavoriteDietaryRestrictions(),
        FavoritesService.loadRecentDietaryRestrictions(),
      ]);

      setState(() {
        favoriteDietaryRestrictions = results[0];
        recentDietaryRestrictions = results[1];
        _isLoading = false;
      });

      // 🔍 Enhanced debugging
      print(
          '🔍 LOADED ${favoriteDietaryRestrictions.length} favorite dietary restrictions: $favoriteDietaryRestrictions');
      print(
          '🕒 LOADED ${recentDietaryRestrictions.length} recent dietary restrictions: $recentDietaryRestrictions');
    } catch (e) {
      print('⚠️ Error loading dietary restriction data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Toggle a dietary restriction in favorites and update UI
  Future<void> _toggleFavoriteDietaryRestriction(String restrictionId) async {
    try {
      final wasInFavorites =
          favoriteDietaryRestrictions.contains(restrictionId);
      final updatedFavorites =
          await FavoritesService.toggleFavoriteDietaryRestriction(
              restrictionId);

      setState(() {
        favoriteDietaryRestrictions = updatedFavorites;
      });

      // 🔍 Enhanced debugging
      print('🔄 ${wasInFavorites ? 'REMOVED' : 'ADDED'}: $restrictionId');
      print('🔍 NEW FAVORITES LIST: $updatedFavorites');
    } catch (e) {
      print('⚠️ Error toggling favorite dietary restriction: $e');
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
            await FavoritesService.addRecentDietaryRestrictions(selectedItems);

        // Don't setState here since we're about to navigate away
        print('🕒 ADDED TO RECENT DIETARY: $selectedItems');
        print('🕒 NEW RECENT DIETARY LIST: $updatedRecent');
      } catch (e) {
        print('⚠️ Error updating recent dietary restrictions: $e');
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
        appBar: AppBar(title: const Text('Select Diet Restrictions')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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

    return SelectItemsScreen(
      initialSelection: widget.initialSelection,
      allItems: allItems,
      recentItems: recentDietaryRestrictions, // 🆕 Now using real recent data
      commonItems: const [], // 🆕 Empty - using favorites instead
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
      // 🆕 Enable favorites functionality
      favoriteItems: favoriteDietaryRestrictions,
      onToggleFavorite: _toggleFavoriteDietaryRestriction,
      onDone: _handleDone, // 🆕 Handle when user hits Done
    );
  }
}
