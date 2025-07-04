// 📁 lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/l10n/l10n.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/widgets/nurse_scaffold.dart';
import '../../../shared/widgets/form_card.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../auth/state/auth_controller.dart';
import '../../preferences/controllers/locale_controller.dart';
import '../../profile/state/user_profile_controller.dart';
import '../../../shared/widgets/app_divider.dart';
import 'package:nurseos_v3/features/preferences/widgets/font_size_modal.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textTheme = theme.textTheme;

    final user = ref.watch(userProfileStreamProvider).value;
    final locale =
        ref.watch(localeStreamProvider).valueOrNull ?? const Locale('en');
    final themeAsync = ref.watch(themeModeStreamProvider);
    final isDark = themeAsync.valueOrNull == ThemeMode.dark;

    if (user == null) return const SizedBox.shrink();

    return NurseScaffold(
      child: CustomScrollView(
        slivers: [
          // Avatar + Profile Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.brandPrimary.withOpacity(0.05),
                    colors.brandPrimary.withOpacity(0.02),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      ProfileAvatar(
                        photoUrl: user.photoUrl,
                        fallbackName: '${user.firstName} ${user.lastName}',
                        radius: 50,
                        showBorder: true,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.brandPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.verified,
                            color: colors.onPrimary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.sm,
                      vertical: SpacingTokens.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.brandPrimary.withAlpha(26),
                      borderRadius: BorderRadius.circular(SpacingTokens.sm),
                    ),
                    child: Text(
                      user.role.name.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.brandPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    user.email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.subdued,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  SizedBox(
                    width: double.infinity,
                    child: SecondaryButton(
                      label: l10n.editProfile,
                      onPressed: () => context.push('/edit-profile'),
                      icon: const Icon(Icons.edit, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Professional Info Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: FormCard(
                title: 'Professional Information',
                child: Column(
                  children: [
                    _buildInfoRow(context,
                        icon: Icons.medical_services,
                        label: 'Role',
                        value: user.role.name,
                        colors: colors),
                    const SizedBox(height: SpacingTokens.sm),
                    _buildInfoRow(context,
                        icon: Icons.email,
                        label: 'Email',
                        value: user.email,
                        colors: colors),
                    const SizedBox(height: SpacingTokens.sm),
                    _buildInfoRow(context,
                        icon: Icons.schedule,
                        label: 'Status',
                        value: 'Active',
                        colors: colors,
                        valueColor: Colors.green),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.lg)),

          // Preferences
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: FormCard(
                title: l10n.preferences,
                child: Column(
                  children: [
                    _buildSettingsTile(
                      context,
                      icon: Icons.brightness_6,
                      title: l10n.darkMode,
                      subtitle: 'Adjust app appearance',
                      trailing: Switch(
                        value: isDark,
                        onChanged: themeAsync.hasValue
                            ? (val) => ref
                                .read(themeControllerProvider.notifier)
                                .toggleTheme(val)
                            : null,
                      ),
                    ),
                    const AppDivider(),
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
                                value: 'en', child: Text('English')),
                            DropdownMenuItem(
                                value: 'es', child: Text('Español')),
                          ],
                        ),
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
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.lg)),

          // Support & Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: FormCard(
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
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.lg)),

          // Logout
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: PrimaryButton(
                label: l10n.logOut,
                onPressed: () => _showLogoutConfirmation(context, ref),
                icon: const Icon(Icons.logout),
                backgroundColor: colors.brandPrimary,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.xl)),
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
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colors.brandPrimary),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.subdued, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: valueColor ?? colors.text,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
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
                  Text(title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500, color: colors.text)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colors.subdued)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(
            'Are you sure you want to log out? Make sure you\'ve completed all your tasks.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
