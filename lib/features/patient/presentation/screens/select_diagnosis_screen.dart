// 📁 lib/features/patient/presentation/screens/select_diagnosis_screen.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/diagnosis_catalog.dart';
import 'package:nurseos_v3/features/patient/models/patient_risk.dart';
import 'package:nurseos_v3/features/patient/services/favorites_service.dart';
import 'package:nurseos_v3/shared/widgets/select_items_screen.dart';

class SelectDiagnosisScreen extends StatefulWidget {
  final List<String> initialSelection;

  const SelectDiagnosisScreen({super.key, required this.initialSelection});

  @override
  State<SelectDiagnosisScreen> createState() => _SelectDiagnosisScreenState();
}

class _SelectDiagnosisScreenState extends State<SelectDiagnosisScreen> {
  List<String> favoriteDiagnoses = [];
  List<String> recentDiagnoses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load both favorites and recent items from storage
  Future<void> _loadData() async {
    print('🔍 DEBUG: _loadData() called!');
    try {
      // Load both favorites and recent items in parallel
      final results = await Future.wait([
        FavoritesService.loadFavoriteDiagnoses(),
        FavoritesService.loadRecentDiagnoses(),
      ]);

      setState(() {
        favoriteDiagnoses = results[0];
        recentDiagnoses = results[1];
        _isLoading = false;
      });

      // 🔍 Enhanced debugging
      print(
          '🔍 LOADED ${favoriteDiagnoses.length} favorites: $favoriteDiagnoses');
      print('🕒 LOADED ${recentDiagnoses.length} recent: $recentDiagnoses');
    } catch (e) {
      print('⚠️ Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Toggle a diagnosis in favorites and update UI
  Future<void> _toggleFavoriteDiagnosis(String diagnosisId) async {
    try {
      final wasInFavorites = favoriteDiagnoses.contains(diagnosisId);
      final updatedFavorites =
          await FavoritesService.toggleFavoriteDiagnosis(diagnosisId);

      setState(() {
        favoriteDiagnoses = updatedFavorites;
      });

      // 🔍 Enhanced debugging
      print('🔄 ${wasInFavorites ? 'REMOVED' : 'ADDED'}: $diagnosisId');
      print('🔍 NEW FAVORITES LIST: $updatedFavorites');
    } catch (e) {
      print('⚠️ Error toggling favorite diagnosis: $e');
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
            await FavoritesService.addRecentDiagnoses(selectedItems);

        // Don't setState here since we're about to navigate away
        print('🕒 ADDED TO RECENT: $selectedItems');
        print('🕒 NEW RECENT LIST: $updatedRecent');
      } catch (e) {
        print('⚠️ Error updating recent diagnoses: $e');
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
        appBar: AppBar(title: const Text('Select Diagnoses')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Convert DiagnosisEntry to SelectableItem
    final allItems = diagnosisCatalog
        .map((entry) => SelectableItem(
              id: entry.label,
              label: entry.label,
              code: entry.code,
              category: entry.category,
              severity: _mapRiskToSeverity(entry.severity),
            ))
        .toList();

    return SelectItemsScreen(
      initialSelection: widget.initialSelection,
      allItems: allItems,
      recentItems: recentDiagnoses, // 🆕 Now using real recent data
      commonItems: const [],
      config: SelectItemsConfig(
        title: 'Select Diagnoses',
        searchHint: 'Search diagnoses or ICD codes...',
        noItemsMessage: 'No diagnoses found',
        noSelectionMessage: 'No diagnoses selected',
        noSelectionSubMessage: 'Select diagnoses from the other tabs',
        itemTypeSingular: 'diagnosis',
        itemTypePlural: 'diagnoses',
        codeLabel: 'ICD',
        showSeverityIndicator: true,
        showCodeField: true,
        showCategoryFilter: true,
        tabRecentIcon: Icons.access_time,
        tabSearchIcon: Icons.search,
        tabSelectedIcon: Icons.checklist,
        emptyStateIcon: Icons.checklist,
        accentColor: colors.brandAccent,
      ),
      favoriteItems: favoriteDiagnoses,
      onToggleFavorite: _toggleFavoriteDiagnosis,
      onDone: _handleDone, // 🆕 Handle when user hits Done
    );
  }

  SelectableItemSeverity _mapRiskToSeverity(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.high:
        return SelectableItemSeverity.high;
      case RiskLevel.medium:
        return SelectableItemSeverity.medium;
      case RiskLevel.low:
        return SelectableItemSeverity.low;
      case RiskLevel.unknown:
        return SelectableItemSeverity.unknown;
    }
  }
}
