// 📁 lib/features/profile/widgets/support_info_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';
import 'package:nurseos_v3/shared/widgets/app_divider.dart';

class SupportInfoCard extends StatelessWidget {
  const SupportInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Support & Information',
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with the app',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/help'),
          ),
          const AppDivider(),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/about'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        child: Row(
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
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.subdued,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
