// 📁 lib/features/profile/widgets/profile_header.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with XP stack
          Column(
            children: [
              Stack(
                children: [
                  ProfileAvatar(
                    photoUrl: user.photoUrl,
                    fallbackName: '${user.firstName} ${user.lastName}',
                    radius: 32,
                    showBorder: true,
                  ),
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
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                'Level ${user.level}',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${user.xp} XP',
                style: textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(width: SpacingTokens.md),

          // Main identity block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _buildNameWithCredentials(),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (_buildProfessionalContext().isNotEmpty)
                  Text(
                    _buildProfessionalContext(),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 2),
                if (user.certifications != null &&
                    user.certifications!.isNotEmpty)
                  Text(
                    'Certs: ${user.certifications!.join(', ')}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (user.licenseNumber != null)
                  _buildLicenseAndExpiry(context, textTheme),
                if (user.hireDate != null) _buildExperience(context, textTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseAndExpiry(BuildContext context, TextTheme textTheme) {
    final expiry = user.licenseExpiry;
    final license = user.licenseNumber ?? '';
    Color color = Colors.green;
    String formatted = license;

    if (expiry != null) {
      final daysUntilExpiry = expiry.difference(DateTime.now()).inDays;
      final expiryString =
          ' (Exp. ${expiry.month.toString().padLeft(2, '0')}/${expiry.year})';

      if (daysUntilExpiry < 30) {
        color = Colors.red;
      } else if (daysUntilExpiry < 90) {
        color = Colors.orange;
      }

      formatted += expiryString;
    }

    return Text(
      formatted,
      style: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  Widget _buildExperience(BuildContext context, TextTheme textTheme) {
    final years = DateTime.now().difference(user.hireDate!).inDays ~/ 365;
    return Text(
      '$years years experience',
      style: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _buildNameWithCredentials() {
    final credentials = <String>[];
    if (user.role.name == 'nurse') credentials.add('RN');
    if (user.certifications?.contains('ACLS') == true) credentials.add('ACLS');
    if (user.certifications?.contains('CCRN') == true) credentials.add('CCRN');
    final suffix = credentials.isNotEmpty ? ', ${credentials.join(', ')}' : '';
    return '${user.firstName} ${user.lastName}$suffix';
  }

  String _buildProfessionalContext() {
    final parts = <String>[];
    if (user.specialty != null) parts.add(user.specialty!);
    if (user.shift != null) parts.add('${user.shift!} Shift');
    if (user.phoneExtension != null) parts.add('Ext. ${user.phoneExtension!}');
    return parts.join(' • ');
  }

  Color _getDutyStatusColor() {
    if (user.isOnDuty == null) return Colors.grey;
    return user.isOnDuty! ? Colors.green : Colors.grey;
  }
}
