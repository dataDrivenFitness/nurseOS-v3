// 📁 lib/features/navigation_v3/presentation/widgets/enhanced_shift_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model_extensions.dart';
import 'package:nurseos_v3/shared/widgets/color_coded_card.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/shared/widgets/buttons/secondary_button.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/utils/shift_display_helpers.dart';

/// Enhanced shift card with color-coded urgency sidebar
///
/// ✅ Uses shared ColorCodedCard component with 8px sidebar
/// ✅ Smart patient load descriptions
/// ✅ Colleague empathy features
/// ✅ Financial transparency
enum ShiftCardType { emergency, coverage, regular }

class EnhancedShiftCard extends ConsumerWidget {
  final ShiftModel shift;
  final UserModel user;
  final ShiftCardType type;
  final VoidCallback? onRequestShift;
  final VoidCallback? onShowDetails;

  const EnhancedShiftCard({
    super.key,
    required this.shift,
    required this.user,
    required this.type,
    this.onRequestShift,
    this.onShowDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final hasRequested = shift.hasRequestedBy(user.uid);

    final urgencyColor = _getUrgencyColor(colors);

    return ColorCodedCard.shift(
      urgencyColor: urgencyColor,
      onTap: onShowDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with facility name and status chip
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.facilityDisplayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (shift.departmentDisplay != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        shift.departmentDisplay!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.subdued,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildStatusChip(context, hasRequested, urgencyColor, colors),
            ],
          ),

          const SizedBox(height: SpacingTokens.md),

          // Date and time information
          _buildShiftDateTimeInfo(context, colors),

          const SizedBox(height: SpacingTokens.sm),

          // Shift details (patients, compensation, requirements)
          _buildShiftDetails(context, colors),

          // Special information (coverage messages, requirements)
          if (shift.coverageContextMessage != null ||
              shift.specialRequirements != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            _buildSpecialInfo(context, urgencyColor),
          ],

          const SizedBox(height: SpacingTokens.md),

          // Action button
          SizedBox(
            width: double.infinity,
            child: hasRequested
                ? SecondaryButton(
                    label: 'Request Sent',
                    onPressed: null,
                    icon: const Icon(Icons.check, size: 18),
                  )
                : PrimaryButton(
                    label: shift.getCoverageButtonText(),
                    onPressed: onRequestShift,
                    icon: Icon(
                      _getActionIcon(),
                      size: 18,
                    ),
                    backgroundColor:
                        type != ShiftCardType.regular ? urgencyColor : null,
                  ),
          ),

          // Posted time
          if (shift.createdAt != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Posted ${ShiftDisplayHelpers.formatPostedTime(shift.createdAt!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.subdued,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getUrgencyColor(AppColors colors) {
    switch (type) {
      case ShiftCardType.emergency:
        return colors.danger;
      case ShiftCardType.coverage:
        return colors.warning;
      case ShiftCardType.regular:
        return colors.brandPrimary;
    }
  }

  IconData _getActionIcon() {
    switch (type) {
      case ShiftCardType.emergency:
        return Icons.local_hospital;
      case ShiftCardType.coverage:
        return Icons.people_alt;
      case ShiftCardType.regular:
        return Icons.add;
    }
  }

  Widget _buildStatusChip(BuildContext context, bool hasRequested,
      Color urgencyColor, AppColors colors) {
    final theme = Theme.of(context);

    if (hasRequested) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: colors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Requested',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    String statusText;
    Color statusBgColor;
    switch (type) {
      case ShiftCardType.emergency:
        statusText = 'URGENT';
        statusBgColor = colors.danger;
        break;
      case ShiftCardType.coverage:
        statusText = 'COVERAGE';
        statusBgColor = colors.warning;
        break;
      case ShiftCardType.regular:
        statusText = 'Available';
        statusBgColor = urgencyColor.withOpacity(0.1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: type == ShiftCardType.regular ? statusBgColor : statusBgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: type == ShiftCardType.regular ? urgencyColor : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildShiftDateTimeInfo(BuildContext context, AppColors colors) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: colors.brandPrimary,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Text(
              _formatShiftDate(shift.startTime),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (shift.isStartingSoon) ...[
              const SizedBox(width: SpacingTokens.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  shift.timeUntilStart,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: SpacingTokens.xs),
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: colors.brandPrimary,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                shift.timeRange,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              shift.durationText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.subdued,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShiftDetails(BuildContext context, AppColors colors) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (shift.hasAssignedPatients) ...[
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: colors.subdued,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  shift.generatePatientLoadDescription(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subdued,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
        ],
        if (shift.compensationDisplay != null) ...[
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 16,
                color: colors.success,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                shift.compensationDisplay!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (shift.hasFinancialIncentives &&
                  shift.incentiveText != null) ...[
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    shift.incentiveText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.success,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
        if (shift.hasCertificationRequirements) ...[
          const SizedBox(height: SpacingTokens.xs),
          Row(
            children: [
              Icon(
                Icons.verified,
                size: 16,
                color: colors.warning,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  shift.certificationsDisplay!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSpecialInfo(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);
    String? message;
    IconData icon = Icons.info_outline;

    if (shift.coverageContextMessage != null) {
      message = shift.coverageContextMessage!;
      icon = Icons.chat_bubble_outline;
    } else if (shift.specialRequirements != null) {
      message = shift.specialRequirements!;
      icon = Icons.info_outline;
    }

    if (message == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: accentColor,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatShiftDate(DateTime dateTime) {
    return ShiftDisplayHelpers.formatShiftDate(dateTime);
  }

  String _formatPostedTime(DateTime createdAt) {
    return ShiftDisplayHelpers.formatPostedTime(createdAt);
  }
}
