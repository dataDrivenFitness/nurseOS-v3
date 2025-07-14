// lib/features/navigation_v3/presentation/widgets/shift_history_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/text_styles.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';
import 'package:nurseos_v3/shared/widgets/buttons/secondary_button.dart';

class ShiftHistoryTab extends ConsumerWidget {
  const ShiftHistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh shift history
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          children: [
            const SizedBox(height: SpacingTokens.xl),

            // Coming Soon Card
            FormCard(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: colors.subdued,
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Text(
                    'Shift History',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'View your completed shifts, hours worked, and shift performance metrics.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.subdued,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.xl),
                  Container(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    decoration: BoxDecoration(
                      color: colors.brandPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colors.brandPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Expanded(
                          child: Text(
                            'Coming Soon',
                            style: textTheme.labelLarge?.copyWith(
                              color: colors.brandPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  SecondaryButton(
                    label: 'View Work History',
                    onPressed: () => _navigateToWorkHistory(context),
                  ),
                ],
              ),
            ),

            // Feature Preview Card
            const SizedBox(height: SpacingTokens.lg),
            FormCard(
              title: 'Coming Features',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem(
                    context,
                    icon: Icons.analytics,
                    title: 'Shift Analytics',
                    description: 'Performance metrics and insights',
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  _buildFeatureItem(
                    context,
                    icon: Icons.schedule,
                    title: 'Hours Tracking',
                    description: 'Weekly and monthly hour summaries',
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  _buildFeatureItem(
                    context,
                    icon: Icons.star,
                    title: 'Shift Ratings',
                    description: 'Feedback and quality scores',
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  _buildFeatureItem(
                    context,
                    icon: Icons.assignment_turned_in,
                    title: 'Completion Reports',
                    description: 'Detailed shift completion summaries',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.brandPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colors.brandPrimary,
          ),
        ),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.subdued,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToWorkHistory(BuildContext context) {
    // TODO: Navigate to existing work history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Work history navigation - Coming soon')),
    );
  }
}
