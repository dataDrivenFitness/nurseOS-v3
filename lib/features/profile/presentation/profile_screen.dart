import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';

import '../../../features/auth/state/auth_controller.dart';
import '../../../features/gamification/state/xp_repository.dart';
import '../../../features/preferences/presentation/display_settings_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final xpRepo = ref.watch(xpRepositoryProvider);
    final textScaler = MediaQuery.textScalerOf(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<AppColors>()!;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: colors.brandPrimary,
                  backgroundImage: (user.photoUrl?.isNotEmpty ?? false)
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                      ? Text(
                          '${user.firstName[0]}${user.lastName[0]}',
                          style: textTheme.titleLarge?.copyWith(
                            fontSize: textScaler.scale(32),
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(user.email, style: textTheme.bodyLarge),
                Text(
                  user.role.name,
                  style: textTheme.labelMedium?.copyWith(color: colors.subdued),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          FutureBuilder<int>(
            future: xpRepo.getXp(user.uid),
            builder: (context, snapshot) {
              final xp = snapshot.data ?? 0;
              final level = (xp / 100).floor() + 1;
              return ExpansionTile(
                title: const Text("My Achievements"),
                children: [
                  ListTile(title: Text("XP: $xp", style: textTheme.bodyMedium)),
                  ListTile(
                      title:
                          Text("Level: $level", style: textTheme.bodyMedium)),
                  if (user.badges.isNotEmpty)
                    ListTile(
                      title: Text("Badges: ${user.badges.join(', ')}",
                          style: textTheme.bodyMedium),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: SpacingTokens.md),
          const DisplaySettingsSection(),
          const SizedBox(height: SpacingTokens.lg),
          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text("Log out"),
          ),
        ],
      ),
    );
  }
}
