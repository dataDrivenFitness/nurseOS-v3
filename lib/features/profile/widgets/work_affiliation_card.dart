// 📁 lib/features/profile/widgets/work_affiliation_card.dart (FIXED - SHIFT-CENTRIC)

import 'package:flutter/material.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';

class WorkAffiliationCard extends StatelessWidget {
  final UserModel user;

  const WorkAffiliationCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return FormCard(
      title: 'Work Affiliation',
      child: Column(
        children: [
          // Independent Nurse Status
          if (user.isIndependentNurse) ...[
            _buildStatusRow(
              context,
              icon: Icons.person_outline,
              label: 'Practice Type',
              value: 'Independent Nurse',
              colors: colors,
              statusColor: Colors.green,
            ),

            // Business Name (if provided)
            if (user.businessName?.isNotEmpty == true) ...[
              const SizedBox(height: SpacingTokens.sm),
              _buildInfoRow(
                context,
                icon: Icons.business_center,
                label: 'Business Name',
                value: user.businessName!,
                colors: colors,
              ),
            ],

            const SizedBox(height: SpacingTokens.sm),
          ] else ...[
            // Agency Nurse Status
            _buildStatusRow(
              context,
              icon: Icons.business,
              label: 'Practice Type',
              value: 'Agency Nurse',
              colors: colors,
              statusColor: colors.brandPrimary,
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],

          // Department/Unit Information
          if (user.department != null || user.unit != null) ...[
            _buildInfoRow(
              context,
              icon: Icons.domain,
              label: 'Department',
              value: user.department ?? user.unit ?? 'Not specified',
              colors: colors,
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],

          // Shift Information
          if (user.shift != null) ...[
            _buildInfoRow(
              context,
              icon: Icons.schedule,
              label: 'Shift',
              value: '${user.shift} Shift',
              colors: colors,
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],

          // Note about agency relationships
          if (!user.isIndependentNurse) ...[
            Container(
              padding: const EdgeInsets.all(SpacingTokens.sm),
              decoration: BoxDecoration(
                color: colors.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colors.brandPrimary,
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: Text(
                      'Agency relationships are managed through shift assignments',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.brandPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required AppColors colors,
    required Color statusColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colors.brandPrimary),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.subdued,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required AppColors colors,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colors.brandPrimary),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.subdued,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: valueColor ?? colors.text,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
