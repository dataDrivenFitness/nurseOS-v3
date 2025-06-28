// 📁 lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/l10n/l10n.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/widgets/nurse_scaffold.dart';
import '../../../shared/widgets/settings_section.dart';
import '../../auth/state/auth_controller.dart';
import '../../preferences/controllers/locale_controller.dart';
import '../../profile/state/user_profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    /* 🔄 live Firestore providers */
    final user = ref.watch(userProfileStreamProvider).value; // ← live
    final locale = ref.watch(localeStreamProvider).valueOrNull ??
        const Locale('en'); // ← live
    final themeAsync = ref.watch(themeModeStreamProvider); // ← live
    final isDark = themeAsync.valueOrNull == ThemeMode.dark;

    if (user == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final scaler = MediaQuery.textScalerOf(context);
    final textTheme = theme.textTheme;

    return NurseScaffold(
      child: ListView(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        children: [
          // ─── User Info ──────────────────────────────
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.dividerColor, width: 1.5),
                ),
                child: CircleAvatar(
                  backgroundColor: colors.brandPrimary,
                  radius: 40,
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
                    Text('${user.firstName} ${user.lastName}',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.text,
                        )),
                    Text(user.email,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.subdued,
                        )),
                    Text(user.role.name,
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.subdued,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),

          // ─── Edit Profile ───────────────────────────
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.push('/edit-profile'),
              icon: const Icon(Icons.edit),
              label: Text(l10n.editProfile),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),

          // ─── Preferences ────────────────────────────
          SettingsSection(
            title: l10n.preferences,
            children: [
              // 🔄 Dark Mode Toggle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: SpacingTokens.md,
                  leading: const Icon(Icons.brightness_6),
                  title: Text(l10n.darkMode),
                  trailing: Switch(
                    value: isDark,
                    onChanged: themeAsync.hasValue
                        ? (val) => ref
                            .read(themeControllerProvider.notifier)
                            .toggleTheme(val)
                        : null,
                  ),
                ),
              ),

              // 🖥️ Display Settings
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: SpacingTokens.md,
                  leading: const Icon(Icons.tune),
                  title: Text(l10n.displaySettings),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/display-settings'),
                ),
              ),

              // ♿ Accessibility Settings
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: SpacingTokens.md,
                  leading: const Icon(Icons.text_fields),
                  title: Text(l10n.accessibility),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/accessibility'),
                ),
              ),

              // 🌐 Language Selector
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: SpacingTokens.md,
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: locale.languageCode, // auto-updated
                      onChanged: (code) async {
                        if (code == null) return;
                        await ref
                            .read(localeControllerProvider.notifier)
                            .updateLocale(Locale(code)); // still writes
                      },
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'es', child: Text('Español')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),

          // 🚪 Logout
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
            label: Text(l10n.logOut),
          ),
        ],
      ),
    );
  }
}
