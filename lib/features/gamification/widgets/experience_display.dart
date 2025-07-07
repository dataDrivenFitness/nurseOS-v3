// 📁 lib/features/gamification/widgets/experience_display.dart
// Alternative widget that shows years of experience instead of gamification

import 'package:flutter/material.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/models/user_model.dart';

class ExperienceDisplay extends StatelessWidget {
  final UserModel user;

  const ExperienceDisplay({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    if (user.hireDate != null) {
      final years = DateTime.now().difference(user.hireDate!).inDays ~/ 365;
      final months =
          (DateTime.now().difference(user.hireDate!).inDays % 365) ~/ 30;

      String experienceText;
      if (years > 0) {
        experienceText = '$years year${years != 1 ? 's' : ''} experience';
      } else if (months > 0) {
        experienceText = '$months month${months != 1 ? 's' : ''} experience';
      } else {
        experienceText = 'New nurse';
      }

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: colors.subdued.withAlpha(26),
          borderRadius: BorderRadius.circular(SpacingTokens.xs),
        ),
        child: Text(
          experienceText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.subdued,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // Fallback to gamification if no hire date
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
        'Level ${user.level} • ${user.xp} XP',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.brandPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
