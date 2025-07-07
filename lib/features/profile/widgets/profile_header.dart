// 📁 lib/features/profile/widgets/profile_header.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/work_history/models/work_session.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/shared/widgets/profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final WorkSession? currentSession;

  const ProfileHeader({
    super.key,
    required this.user,
    this.currentSession,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Row(
        children: [
          // Avatar with Status Indicator
          _buildAvatarWithStatus(theme),
          const SizedBox(width: SpacingTokens.md),

          // Professional Identity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name with Credentials
                Text(
                  _buildNameWithCredentials(),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 2),

                // Professional Context
                if (_buildProfessionalContext().isNotEmpty)
                  Text(
                    _buildProfessionalContext(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.brandPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 2),

                // Session Status or Experience
                _buildStatusOrExperience(context, colors),
                const SizedBox(height: 2),

                // Email
                Text(
                  user.email,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.subdued,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithStatus(ThemeData theme) {
    return Stack(
      children: [
        ProfileAvatar(
          photoUrl: user.photoUrl,
          fallbackName: '${user.firstName} ${user.lastName}',
          radius: 32,
          showBorder: true,
        ),

        // Duty Status Indicator
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _getDutyStatusColor(),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.scaffoldBackgroundColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOrExperience(BuildContext context, AppColors colors) {
    // Show current session info if active
    if (currentSession != null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(26),
          borderRadius: BorderRadius.circular(SpacingTokens.xs),
        ),
        child: Text(
          'On duty • ${currentSession!.formattedDuration}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
    }

    // Show experience if available
    if (user.hireDate != null) {
      final years = DateTime.now().difference(user.hireDate!).inDays ~/ 365;
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
          '$years years experience',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.subdued,
                fontWeight: FontWeight.w500,
              ),
        ),
      );
    }

    // Fallback to gamification display
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
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.brandPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  String _buildNameWithCredentials() {
    final credentials = <String>[];

    // Add role-based credentials
    if (user.role.name == 'nurse') {
      credentials.add('RN');
    }

    // Add major certifications
    if (user.certifications?.contains('ACLS') == true) {
      credentials.add('ACLS');
    }
    if (user.certifications?.contains('CCRN') == true) {
      credentials.add('CCRN');
    }

    final credentialSuffix =
        credentials.isNotEmpty ? ', ${credentials.join(', ')}' : '';
    return '${user.firstName} ${user.lastName}$credentialSuffix';
  }

  String _buildProfessionalContext() {
    final parts = <String>[];

    if (user.department != null) parts.add(user.department!);
    if (user.shift != null) parts.add('${user.shift!} Shift');
    if (user.phoneExtension != null) parts.add('Ext. ${user.phoneExtension!}');

    return parts.join(' • ');
  }

  Color _getDutyStatusColor() {
    if (user.isOnDuty == null) return Colors.grey;
    return user.isOnDuty! ? Colors.green : Colors.grey;
  }
}
