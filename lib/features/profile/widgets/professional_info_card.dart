// 📁 lib/features/profile/widgets/professional_info_card.dart (UPDATED - NO WORK HISTORY)

import 'package:flutter/material.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';

class ProfessionalInfoCard extends StatelessWidget {
  final UserModel user;

  const ProfessionalInfoCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return FormCard(
      title: 'Professional Information',
      child: Column(
        children: [
          // License Information
          if (user.licenseNumber != null) ...[
            _buildInfoRow(
              context,
              icon: Icons.badge,
              label: 'License',
              value: _formatLicense(user),
              colors: colors,
              valueColor: _getLicenseStatusColor(user),
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],

          // Role
          _buildInfoRow(
            context,
            icon: Icons.medical_services,
            label: 'Role',
            value: user.role.name.toUpperCase(),
            colors: colors,
          ),
          const SizedBox(height: SpacingTokens.sm),

          // Specialty
          if (user.specialty != null) ...[
            _buildInfoRow(
              context,
              icon: Icons.local_hospital,
              label: 'Specialty',
              value: user.specialty!,
              colors: colors,
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],

          // Department/Unit (only for agency nurses)
          if (!user.isIndependentNurse &&
              (user.department != null || user.unit != null)) ...[
            _buildInfoRow(
              context,
              icon: Icons.business,
              label: 'Department',
              value: user.department ?? user.unit ?? 'Not assigned',
              colors: colors,
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],

          // Shift & Extension (only for agency nurses)
          if (!user.isIndependentNurse &&
              (user.shift != null || user.phoneExtension != null)) ...[
            _buildInfoRow(
              context,
              icon: Icons.schedule,
              label: 'Shift & Extension',
              value: _formatShiftAndExtension(user),
              colors: colors,
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],

          // Certifications
          if (user.certifications?.isNotEmpty == true) ...[
            _buildInfoRow(
              context,
              icon: Icons.verified,
              label: 'Certifications',
              value: user.certifications!.join(', '),
              colors: colors,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required AppColors colors,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    final row = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.brandPrimary.withAlpha(26),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 20, color: colors.brandPrimary),
        ),
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
        if (onTap != null) Icon(Icons.chevron_right, color: colors.subdued),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: row,
        ),
      );
    }

    return row;
  }

  String _formatLicense(UserModel user) {
    if (user.licenseNumber == null) return 'Not provided';

    String license = user.licenseNumber!;
    if (user.licenseExpiry != null) {
      final expiry = user.licenseExpiry!;
      final monthYear =
          '${expiry.month.toString().padLeft(2, '0')}/${expiry.year}';
      license += ' (Exp. $monthYear)';
    }

    return license;
  }

  String _formatShiftAndExtension(UserModel user) {
    final parts = <String>[];
    if (user.shift != null) parts.add(user.shift!);
    if (user.phoneExtension != null) parts.add('Ext. ${user.phoneExtension!}');
    return parts.join(' • ');
  }

  Color? _getLicenseStatusColor(UserModel user) {
    if (user.licenseExpiry == null) return null;

    final daysUntilExpiry =
        user.licenseExpiry!.difference(DateTime.now()).inDays;
    if (daysUntilExpiry < 30) return Colors.red;
    if (daysUntilExpiry < 90) return Colors.orange;

    return Colors.green;
  }
}
