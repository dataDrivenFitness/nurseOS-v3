// 📁 lib/features/patient/presentation/screens/select_medications_screen.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/medication_catalog.dart';
import 'package:nurseos_v3/features/patient/services/favorites_service.dart';
import 'package:nurseos_v3/shared/widgets/select_items_screen.dart';

class SelectMedicationsScreen extends StatefulWidget {
  final List<String> initialSelection;

  const SelectMedicationsScreen({super.key, required this.initialSelection});

  @override
  State<SelectMedicationsScreen> createState() =>
      _SelectMedicationsScreenState();
}

class _SelectMedicationsScreenState extends State<SelectMedicationsScreen> {
  List<String> favoriteMedications = [];
  List<String> recentMedications = [];
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
        FavoritesService.loadFavoriteMedications(),
        FavoritesService.loadRecentMedications(),
      ]);

      setState(() {
        favoriteMedications = results[0];
        recentMedications = results[1];
        _isLoading = false;
      });

      // 🔍 Enhanced debugging
      print(
          '🔍 LOADED ${favoriteMedications.length} favorite medications: $favoriteMedications');
      print(
          '🕒 LOADED ${recentMedications.length} recent medications: $recentMedications');
    } catch (e) {
      print('⚠️ Error loading medication data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Toggle a medication in favorites and update UI
  Future<void> _toggleFavoriteMedication(String medicationId) async {
    try {
      final wasInFavorites = favoriteMedications.contains(medicationId);
      final updatedFavorites =
          await FavoritesService.toggleFavoriteMedication(medicationId);

      setState(() {
        favoriteMedications = updatedFavorites;
      });

      // 🔍 Enhanced debugging
      print('🔄 ${wasInFavorites ? 'REMOVED' : 'ADDED'}: $medicationId');
      print('🔍 NEW FAVORITES LIST: $updatedFavorites');
    } catch (e) {
      print('⚠️ Error toggling favorite medication: $e');
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
            await FavoritesService.addRecentMedications(selectedItems);

        // Don't setState here since we're about to navigate away
        print('🕒 ADDED TO RECENT MEDICATIONS: $selectedItems');
        print('🕒 NEW RECENT MEDICATIONS LIST: $updatedRecent');
      } catch (e) {
        print('⚠️ Error updating recent medications: $e');
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
        appBar: AppBar(title: const Text('Select Medications')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Convert medication strings to SelectableItem with categorization
    final allItems = commonMedications
        .map((medication) => SelectableItem(
              id: medication, // Use medication name as ID
              label: medication,
              code: _getMedicationCode(
                  medication), // Optional: add codes for common meds
              category: _getCategoryDisplayName(
                  MedicationUtils.categorizeMedication(medication)),
              severity: _mapRiskToSelectableItem(
                  MedicationUtils.assessMedicationRisk(medication)),
              description: _getMedicationDescription(medication),
            ))
        .toList();

    return SelectItemsScreen(
      initialSelection: widget.initialSelection,
      allItems: allItems,
      recentItems: recentMedications,
      commonItems: const [], // Using favorites instead
      config: SelectItemsConfig(
        title: 'Select Medications',
        searchHint: 'Search medications...',
        noItemsMessage: 'No medications found',
        noSelectionMessage: 'No medications selected',
        noSelectionSubMessage: 'Select medications from the other tabs',
        itemTypeSingular: 'medication',
        itemTypePlural: 'medications',
        codeLabel: 'Class',
        showSeverityIndicator: true, // Show risk levels
        showCodeField: true, // Show therapeutic class
        showCategoryFilter: true,
        tabRecentIcon: Icons.access_time,
        tabSearchIcon: Icons.search,
        tabSelectedIcon: Icons.checklist,
        emptyStateIcon: Icons.medication,
        accentColor: colors.medicationPurple,
      ),
      favoriteItems: favoriteMedications,
      onToggleFavorite: _toggleFavoriteMedication,
      onDone: _handleDone,
    );
  }

  /// Convert MedicationRisk to SelectableItemSeverity
  SelectableItemSeverity _mapRiskToSelectableItem(MedicationRisk risk) {
    switch (risk) {
      case MedicationRisk.high:
        return SelectableItemSeverity.high;
      case MedicationRisk.medium:
        return SelectableItemSeverity.medium;
      case MedicationRisk.low:
        return SelectableItemSeverity.low;
      case MedicationRisk.unknown:
        return SelectableItemSeverity.unknown;
    }
  }

  /// Get user-friendly category display name
  String _getCategoryDisplayName(MedicationCategory category) {
    switch (category) {
      case MedicationCategory.cardiovascular:
        return 'Cardiovascular';
      case MedicationCategory.diabetes:
        return 'Diabetes';
      case MedicationCategory.pain:
        return 'Pain/Analgesic';
      case MedicationCategory.neurological:
        return 'Neurological';
      case MedicationCategory.respiratory:
        return 'Respiratory';
      case MedicationCategory.antimicrobial:
        return 'Antibiotic';
      case MedicationCategory.gastrointestinal:
        return 'Gastrointestinal';
      case MedicationCategory.hematologic:
        return 'Blood/Hematologic';
      case MedicationCategory.vitamins:
        return 'Vitamin/Supplement';
      case MedicationCategory.other:
        return 'Other';
    }
  }

  /// Get therapeutic class code for common medications
  String? _getMedicationCode(String medication) {
    final lower = medication.toLowerCase();

    // ACE Inhibitors
    if (['lisinopril', 'enalapril', 'captopril']
        .any((med) => lower.contains(med))) {
      return 'ACE-I';
    }
    // ARBs
    if (['losartan', 'valsartan', 'irbesartan']
        .any((med) => lower.contains(med))) {
      return 'ARB';
    }
    // Beta Blockers
    if (['metoprolol', 'atenolol', 'propranolol', 'carvedilol']
        .any((med) => lower.contains(med))) {
      return 'Beta-Blocker';
    }
    // Calcium Channel Blockers
    if (['amlodipine', 'nifedipine', 'diltiazem', 'verapamil']
        .any((med) => lower.contains(med))) {
      return 'CCB';
    }
    // Diuretics
    if (['hydrochlorothiazide', 'hctz', 'furosemide', 'lasix', 'spironolactone']
        .any((med) => lower.contains(med))) {
      return 'Diuretic';
    }
    // Statins
    if ([
      'atorvastatin',
      'simvastatin',
      'rosuvastatin',
      'lipitor',
      'zocor',
      'crestor'
    ].any((med) => lower.contains(med))) {
      return 'Statin';
    }
    // Insulin
    if (lower.contains('insulin')) {
      return 'Insulin';
    }
    // Opioids
    if ([
      'morphine',
      'oxycodone',
      'hydrocodone',
      'fentanyl',
      'tramadol',
      'codeine'
    ].any((med) => lower.contains(med))) {
      return 'Opioid';
    }
    // NSAIDs
    if (['ibuprofen', 'naproxen', 'advil', 'aleve', 'celecoxib', 'celebrex']
        .any((med) => lower.contains(med))) {
      return 'NSAID';
    }
    // Antibiotics
    if ([
      'amoxicillin',
      'azithromycin',
      'ciprofloxacin',
      'levofloxacin',
      'cephalexin',
      'doxycycline'
    ].any((med) => lower.contains(med))) {
      return 'Antibiotic';
    }
    // PPIs
    if ([
      'omeprazole',
      'pantoprazole',
      'esomeprazole',
      'prilosec',
      'protonix',
      'nexium'
    ].any((med) => lower.contains(med))) {
      return 'PPI';
    }

    return null; // No specific class identified
  }

  /// Get helpful description for high-risk medications
  String? _getMedicationDescription(String medication) {
    final lower = medication.toLowerCase();

    // High-alert medications get special descriptions
    if (lower.contains('insulin')) {
      return 'High-alert: Monitor blood glucose closely';
    }
    if (['morphine', 'oxycodone', 'hydrocodone', 'fentanyl']
        .any((med) => lower.contains(med))) {
      return 'High-alert: Monitor respiratory status';
    }
    if (['warfarin', 'coumadin'].any((med) => lower.contains(med))) {
      return 'High-alert: Monitor INR levels';
    }
    if (lower.contains('digoxin')) {
      return 'High-alert: Monitor digoxin levels';
    }
    if (lower.contains('vancomycin')) {
      return 'High-alert: Monitor kidney function';
    }

    return null; // No special description needed
  }
}
