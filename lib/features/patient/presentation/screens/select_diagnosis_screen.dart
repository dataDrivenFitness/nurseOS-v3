// 📁 lib/features/patient/presentation/screens/select_diagnosis_screen.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/diagnosis_catalog.dart';
import 'package:nurseos_v3/features/patient/models/patient_risk.dart';
import 'package:nurseos_v3/shared/widgets/select_items_screen.dart';

class SelectDiagnosisScreen extends StatelessWidget {
  final List<String> initialSelection;

  const SelectDiagnosisScreen({super.key, required this.initialSelection});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    // Convert DiagnosisEntry to SelectableItem
    final allItems = diagnosisCatalog
        .map((entry) => SelectableItem(
              id: entry.label, // Use label as ID for diagnoses
              label: entry.label,
              code: entry.code,
              category: entry.category,
              severity: _mapRiskToSeverity(entry.severity),
            ))
        .toList();

    // Mock recent diagnoses (in real app, get from user preferences)
    final recentDiagnoses = [
      'Myocardial Infarction',
      'Pneumonia',
      'Type 2 Diabetes',
      'Hypertension',
      'COPD Exacerbation'
    ];

    // Get common diagnoses from catalog
    final commonDiagnoses =
        getCommonDiagnoses().map((entry) => entry.label).toList();

    return SelectItemsScreen(
      initialSelection: initialSelection,
      allItems: allItems,
      recentItems: recentDiagnoses,
      commonItems: commonDiagnoses,
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
        accentColor: colors.brandAccent, // 🎨 Blue accent for diagnoses
      ),
    );
  }

  /// Convert RiskLevel to SelectableItemSeverity
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
