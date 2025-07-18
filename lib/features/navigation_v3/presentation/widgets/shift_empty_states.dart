// 📁 lib/features/navigation_v3/presentation/widgets/shift_empty_states.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';

/// Empty states and error handling for shift screens
///
/// ✅ Extracted from AvailableShiftsScreen for reusability
/// ✅ Handles various empty scenarios with contextual messaging
/// ✅ Consistent styling across all empty states
class ShiftEmptyStates {
  ShiftEmptyStates._();

  /// Build general empty state with icon, title, subtitle and optional action
  static Widget buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: colors.subdued,
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.subdued,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SpacingTokens.xl),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build error state with red styling and retry action
  static Widget buildErrorState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: colors.danger,
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.danger,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.subdued,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SpacingTokens.xl),
              PrimaryButton(
                label: actionLabel,
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build no agency access state with user-type specific messaging
  static Widget buildNoAgencyAccessState({
    required BuildContext context,
    required bool isIndependentNurse,
    VoidCallback? onCreateShift,
  }) {
    if (isIndependentNurse) {
      return buildEmptyState(
        context: context,
        icon: Icons.business_center,
        title: 'No Agency Partnerships',
        subtitle:
            'You\'re set up for independent practice.\nUse the "My Shifts" tab to create your own shifts.',
        actionLabel: 'Create My First Shift',
        onAction: onCreateShift,
      );
    } else {
      return buildEmptyState(
        context: context,
        icon: Icons.warning_amber,
        title: 'No Agency Access',
        subtitle: 'Contact your administrator to be assigned to an agency.',
      );
    }
  }

  /// Build no available shifts state
  static Widget buildNoAvailableShifts(BuildContext context) {
    return buildEmptyState(
      context: context,
      icon: Icons.work_off,
      title: 'No Available Shifts',
      subtitle:
          'Check back later for new opportunities\nfrom your affiliated agencies.',
    );
  }

  /// Build no personal shifts state for independent nurses
  static Widget buildNoPersonalShifts({
    required BuildContext context,
    VoidCallback? onCreateShift,
  }) {
    return buildEmptyState(
      context: context,
      icon: Icons.add_business,
      title: 'No Personal Shifts',
      subtitle:
          'Create your first shift to start\nmanaging your independent practice.',
      actionLabel: 'Create Shift',
      onAction: onCreateShift,
    );
  }
}
