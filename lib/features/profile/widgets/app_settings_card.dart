// 📁 lib/features/profile/widgets/app_settings_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/theme_controller.dart';
import 'package:nurseos_v3/features/preferences/controllers/locale_controller.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';
import 'package:nurseos_v3/shared/widgets/app_divider.dart';
import 'package:nurseos_v3/features/preferences/widgets/font_size_modal.dart';
import 'package:nurseos_v3/l10n/l10n.dart';

class AppSettingsCard extends ConsumerWidget {
  final Locale locale;
  final bool isDark;
  final bool canToggleTheme;

  const AppSettingsCard({
    super.key,
    required this.locale,
    required this.isDark,
    required this.canToggleTheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColors>()!;

    return FormCard(
      title: 'App Settings',
      child: Column(
        children: [
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingsTile(
            context,
            icon: Icons.brightness_6,
            title: l10n.darkMode,
            subtitle: 'Adjust app appearance',
            trailing: Switch(
              value: isDark,
              onChanged: canToggleTheme
                  ? (val) => ref
                      .read(themeControllerProvider.notifier)
                      .toggleTheme(val)
                  : null,
            ),
          ),
          const AppDivider(),
          _buildSettingsTile(
            context,
            icon: Icons.text_fields,
            title: 'Text Size',
            subtitle: 'Adjust font scale',
            trailing: Icon(Icons.tune, color: colors.text),
            onTap: () => showTextSizeModal(context, ref),
          ),

          const SizedBox(height: SpacingTokens.md),

          // Language Section
          _buildSectionHeader(context, 'Language'),
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: l10n.language,
            subtitle: 'App language preference',
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: locale.languageCode,
                onChanged: (code) async {
                  if (code == null) return;
                  await ref
                      .read(localeControllerProvider.notifier)
                      .updateLocale(Locale(code));
                },
                items: const [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: 'es',
                    child: Text('Español'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.brandPrimary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
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
