// 📁 lib/features/profile/presentation/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/l10n/l10n.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/widgets/nurse_scaffold.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../auth/state/auth_controller.dart';
import '../../preferences/controllers/locale_controller.dart';
import '../../profile/state/user_profile_controller.dart';
import '../../work_history/state/work_history_controller.dart';

// Import profile widgets (these should already exist based on your previous conversation)
import '../widgets/profile_header.dart';
import '../widgets/profile_action_buttons.dart';
import '../widgets/current_session_card.dart';
import '../widgets/professional_info_card.dart';
import '../widgets/app_settings_card.dart';
import '../widgets/support_info_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    final user = ref.watch(userProfileStreamProvider).value;
    final locale =
        ref.watch(localeStreamProvider).valueOrNull ?? const Locale('en');
    final themeAsync = ref.watch(themeModeStreamProvider);
    final isDark = themeAsync.valueOrNull == ThemeMode.dark;
    final currentSessionAsync = ref.watch(currentWorkSessionStreamProvider);

    if (user == null) return const SizedBox.shrink();

    return NurseScaffold(
      child: CustomScrollView(
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: ProfileHeader(
              user: user,
              currentSession: currentSessionAsync.valueOrNull,
            ),
          ),

          // Action Buttons (Edit Profile & Duty Toggle)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: ProfileActionButtons(
                user: user,
                currentSession: currentSessionAsync.valueOrNull,
                onEditProfile: () => context.push('/edit-profile'),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.lg)),

          // Current Session Card (if active)
          currentSessionAsync.when(
            data: (session) => session != null
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.lg),
                      child: CurrentSessionCard(session: session),
                    ),
                  )
                : const SliverToBoxAdapter(child: SizedBox.shrink()),
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Add spacing if session card is shown
          currentSessionAsync.when(
            data: (session) => session != null
                ? const SliverToBoxAdapter(
                    child: SizedBox(height: SpacingTokens.lg))
                : const SliverToBoxAdapter(child: SizedBox.shrink()),
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Professional Information Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: ProfessionalInfoCard(user: user),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.lg)),

          // App Settings Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: AppSettingsCard(
                locale: locale,
                isDark: isDark,
                canToggleTheme: themeAsync.hasValue,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.lg)),

          // Support & Information Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: const SupportInfoCard(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: SpacingTokens.lg)),

          // Logout Button
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

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to log out? Make sure you\'ve completed all your tasks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
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
