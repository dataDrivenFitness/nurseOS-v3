// 📁 lib/features/gamification/widgets/gamification_summary.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_colors.dart';

// TODO: Replace with actual gamification controller once implemented
// For now, this is a placeholder that reads from UserModel
import '../../auth/state/auth_controller.dart';

class GamificationSummary extends ConsumerWidget {
  final bool showProgress;

  const GamificationSummary({
    super.key,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    final user = ref.watch(authControllerProvider).value;
    if (user == null) return const SizedBox.shrink();

    if (showProgress) {
      return _buildWithProgress(context, colors, user.level, user.xp);
    } else {
      return _buildCompact(context, colors, user.level, user.xp);
    }
  }

  Widget _buildCompact(
      BuildContext context, AppColors colors, int level, int xp) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: colors.brandPrimary.withAlpha(26),
        borderRadius: BorderRadius.circular(SpacingTokens.xs),
      ),
      child: Text(
        'Level $level • $xp XP',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.brandPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildWithProgress(
      BuildContext context, AppColors colors, int level, int xp) {
    final xpForCurrentLevel = (level - 1) * 100;
    final xpForNextLevel = level * 100;
    final xpProgress = xp - xpForCurrentLevel;
    final progressPercent = (xpProgress / 100.0).clamp(0.0, 1.0);

    return Column(
      children: [
        _buildCompact(context, colors, level, xp),
        const SizedBox(height: SpacingTokens.xs),
        LinearProgressIndicator(
          value: progressPercent,
          backgroundColor: colors.subdued.withAlpha(26),
          valueColor: AlwaysStoppedAnimation<Color>(colors.brandPrimary),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          '$xpProgress/100 XP to next level',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.subdued,
              ),
        ),
      ],
    );
  }
}
