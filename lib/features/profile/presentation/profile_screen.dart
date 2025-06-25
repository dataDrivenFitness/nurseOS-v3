import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../features/auth/state/auth_controller.dart';
import '../../../shared/widgets/nurse_scaffold.dart';
import '../../../shared/widgets/settings_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final scaler = MediaQuery.textScalerOf(context);
    final textTheme = theme.textTheme;

    if (user == null) return const SizedBox.shrink();

    return NurseScaffold(
      child: ListView(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        children: [
          // ── Identity Block ────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: colors.brandPrimary,
                  child: ClipOval(
                    child: Image.network(
                      user.photoUrl ?? '',
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          '${user.firstName[0]}${user.lastName[0]}',
                          style: textTheme.titleLarge?.copyWith(
                            fontSize: 32 * scaler.scale(1),
                            color: colors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    Text(user.email,
                        style: textTheme.bodyLarge
                            ?.copyWith(color: colors.subdued)),
                    Text(
                      user.role.name,
                      style: textTheme.labelMedium
                          ?.copyWith(color: colors.subdued),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const EditProfileSheet(),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit profile'),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),

          // ── Preferences ──────────────────────────────────────────
          SettingsSection(
            title: 'Preferences',
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final isDark =
                      ref.watch(themeControllerProvider) == ThemeMode.dark;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      horizontalTitleGap: SpacingTokens.md,
                      leading: const Icon(Icons.brightness_6),
                      title: const Text('Dark mode'),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (val) => ref
                            .read(themeControllerProvider.notifier)
                            .toggleTheme(val),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: SpacingTokens.md,
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  trailing: const Text('English'),
                  enabled: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: SpacingTokens.md,
                  leading: const Icon(Icons.tune),
                  title: const Text('Display settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/display-settings'),
                ),
              ),
            ],
          ),

          const SizedBox(height: SpacingTokens.lg),

          // ── Logout Button ────────────────────────────────────────
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colors.brandPrimary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(
                vertical: SpacingTokens.md,
                horizontal: SpacingTokens.lg,
              ),
            ),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class EditProfileSheet extends StatelessWidget {
  const EditProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit profile', style: TextStyle(fontSize: 18)),
            const SizedBox(height: SpacingTokens.md),
            const Text('(Coming soon)'),
            const SizedBox(height: SpacingTokens.lg),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
