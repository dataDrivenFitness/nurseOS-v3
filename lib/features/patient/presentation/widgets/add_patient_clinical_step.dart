// 📁 lib/features/patient/presentation/widgets/add_patient_clinical_step.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/typography.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';
import 'package:nurseos_v3/shared/widgets/info_pill.dart';

class AddPatientClinicalStep extends StatelessWidget {
  final TextEditingController mrnController;
  final List<String> primaryDiagnoses;
  final List<String> selectedAllergies;
  final List<String> selectedDietRestrictions;
  final bool mrnExists;
  final bool isValidatingMrn;
  final String? mrnError;
  final VoidCallback onSelectDiagnoses;
  final VoidCallback onSelectAllergies;
  final VoidCallback onSelectDietRestrictions;

  const AddPatientClinicalStep({
    super.key,
    required this.mrnController,
    required this.primaryDiagnoses,
    required this.selectedAllergies,
    required this.selectedDietRestrictions,
    required this.mrnExists,
    required this.isValidatingMrn,
    this.mrnError,
    required this.onSelectDiagnoses,
    required this.onSelectAllergies,
    required this.onSelectDietRestrictions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return FormCard(
      title: 'Clinical Information',
      child: Column(
        children: [
          // MRN Field
          TextFormField(
            controller: mrnController,
            decoration: InputDecoration(
              labelText: 'Medical Record Number (MRN)',
              hintText: 'Enter MRN if available',
              border: const OutlineInputBorder(),
              errorText: mrnError,
              suffixIcon: isValidatingMrn
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : mrnExists
                      ? Icon(Icons.error, color: colors.danger)
                      : mrnController.text.isNotEmpty && !mrnExists
                          ? Icon(Icons.check, color: colors.success)
                          : null,
            ),
            style: AppTypography.textTheme.bodyLarge,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: SpacingTokens.md),

          // Primary Diagnoses Selection
          _buildSelectionContainer(
            context: context,
            theme: theme,
            colors: colors,
            icon: Icons.medical_services,
            iconColor: colors.brandAccent,
            title: 'Primary Diagnoses',
            description: 'Current medical conditions',
            items: primaryDiagnoses,
            emptyText: 'Tap to add diagnoses',
            pillType: InfoPillType.diagnosisAccent,
            onTap: onSelectDiagnoses,
          ),
          const SizedBox(height: SpacingTokens.md),

          // Allergies Selection
          _buildSelectionContainer(
            context: context,
            theme: theme,
            colors: colors,
            icon: Icons.warning_amber_rounded,
            iconColor: colors.warning,
            title: 'Allergies',
            description: 'Known allergic reactions',
            items: selectedAllergies,
            emptyText: 'Tap to add allergies',
            pillType: InfoPillType.allergy,
            onTap: onSelectAllergies,
          ),
          const SizedBox(height: SpacingTokens.md),

          // Dietary Restrictions Selection
          _buildSelectionContainer(
            context: context,
            theme: theme,
            colors: colors,
            icon: Icons.restaurant_menu,
            iconColor: colors.success,
            title: 'Dietary Restrictions',
            description: 'Special dietary requirements',
            items: selectedDietRestrictions,
            emptyText: 'Tap to add dietary restrictions',
            pillType: InfoPillType.dietRestrictionGreen,
            onTap: onSelectDietRestrictions,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionContainer({
    required BuildContext context,
    required ThemeData theme,
    required AppColors colors,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> items,
    required String emptyText,
    required InfoPillType pillType,
    required VoidCallback onTap,
  }) {
    final hasItems = items.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: hasItems ? iconColor.withOpacity(0.05) : colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasItems
              ? iconColor.withOpacity(0.3)
              : colors.onSurface.withOpacity(0.2),
          width: hasItems ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon with persistent background (like risk step)
                  Container(
                    padding: const EdgeInsets.all(SpacingTokens.sm),
                    decoration: BoxDecoration(
                      color: hasItems
                          ? iconColor.withOpacity(0.15)
                          : colors.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(SpacingTokens.sm),
                    ),
                    child: Icon(
                      icon,
                      color: hasItems ? iconColor : colors.subdued,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: hasItems ? iconColor : colors.text,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          description,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: colors.subdued,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colors.subdued, size: 20),
                ],
              ),
              if (hasItems) ...[
                const SizedBox(height: SpacingTokens.md),
                Wrap(
                  spacing: SpacingTokens.sm,
                  runSpacing: SpacingTokens.xs,
                  children: items
                      .map((item) => InfoPill(
                            text: item,
                            type: pillType,
                          ))
                      .toList(),
                ),
              ] else ...[
                const SizedBox(height: SpacingTokens.md),
                Text(
                  emptyText,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: colors.subdued,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
