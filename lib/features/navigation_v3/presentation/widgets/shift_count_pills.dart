// 📁 lib/features/navigation_v3/presentation/widgets/shift_count_pills.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model_extensions.dart';

/// Universal pill header system for shift counts
///
/// ✅ Extracted from AvailableShiftsScreen for reusability
/// ✅ Shows interactive count pills for Emergency, Coverage, Regular shifts
/// ✅ Handles different user types and empty states
class ShiftCountPills extends ConsumerWidget {
  final List<ShiftModel> shifts;
  final UserModel user;
  final bool hasAgencyAccess;
  final Function(int)? onSectionTap;

  const ShiftCountPills({
    super.key,
    required this.shifts,
    required this.user,
    required this.hasAgencyAccess,
    this.onSectionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;

    // For independent-only nurses with no agency access
    if (user.isIndependentNurse && !hasAgencyAccess) {
      return _buildIndependentOnlyHeader(context, colors);
    }

    // Calculate shift counts
    final availableShifts = shifts
        .where((shift) =>
            shift.status == 'available' &&
            (shift.assignedTo == null || shift.assignedTo!.isEmpty))
        .toList();

    final emergencyCount =
        availableShifts.where((s) => s.isEmergencyShift).length;
    final coverageCount =
        availableShifts.where((s) => s.isCoverageRequest).length;
    final regularCount = availableShifts.where((s) => s.isRegularShift).length;

    return _buildCountPills(
        context, emergencyCount, coverageCount, regularCount, colors);
  }

  /// Build pill header for independent-only nurses
  Widget _buildIndependentOnlyHeader(BuildContext context, AppColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Text(
            'No agency shifts • Create your own shifts below',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.subdued,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }

  /// Build count pills with contextual messaging
  Widget _buildCountPills(BuildContext context, int emergencyCount,
      int coverageCount, int regularCount, AppColors colors) {
    final pillsToShow = <Widget>[];

    if (emergencyCount > 0) {
      pillsToShow.add(
        _buildCountPill(
          context,
          '🚨 $emergencyCount Emergency',
          colors.danger,
          true,
          () => onSectionTap?.call(0),
        ),
      );
    }

    if (coverageCount > 0) {
      pillsToShow.add(
        _buildCountPill(
          context,
          '🆘 $coverageCount Coverage',
          colors.warning,
          true,
          () => onSectionTap?.call(1),
        ),
      );
    }

    if (regularCount > 0) {
      pillsToShow.add(
        _buildCountPill(
          context,
          '📅 $regularCount Open',
          colors.brandPrimary,
          true,
          () => onSectionTap?.call(2),
        ),
      );
    }

    // If no pills to show, show contextual empty state
    if (pillsToShow.isEmpty) {
      return _buildEmptyPillsHeader(context, colors);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _buildPillSlot(pillsToShow.isNotEmpty ? pillsToShow[0] : null),
            const SizedBox(width: SpacingTokens.sm),
            _buildPillSlot(pillsToShow.length > 1 ? pillsToShow[1] : null),
            const SizedBox(width: SpacingTokens.sm),
            _buildPillSlot(pillsToShow.length > 2 ? pillsToShow[2] : null),
          ],
        ),
      ),
    );
  }

  /// Build empty pills header when no shifts available
  Widget _buildEmptyPillsHeader(BuildContext context, AppColors colors) {
    String message = 'No shifts available';

    if (user.isIndependentNurse) {
      message = hasAgencyAccess
          ? 'No agency shifts available • Check back later'
          : 'No agency shifts • Create your own shifts below';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.subdued,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }

  /// Build individual pill slot (can be empty)
  Widget _buildPillSlot(Widget? pill) {
    return Expanded(
      child: pill ?? const SizedBox.shrink(),
    );
  }

  /// Build individual count pill
  Widget _buildCountPill(BuildContext context, String text, Color color,
      bool hasShifts, VoidCallback onTap) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: hasShifts ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: hasShifts
              ? color.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasShifts
                ? color.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: hasShifts ? color : Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// Build placeholder pills for loading state
  static Widget buildPlaceholder(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    final pillsToShow = <Widget>[
      _buildPlaceholderPill(
          context, '🚨 - Emergency', colors.danger.withOpacity(0.5)),
      _buildPlaceholderPill(
          context, '🆘 - Coverage', colors.warning.withOpacity(0.5)),
      _buildPlaceholderPill(
          context, '📅 - Open', colors.brandPrimary.withOpacity(0.5)),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(child: pillsToShow[0]),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(child: pillsToShow[1]),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(child: pillsToShow[2]),
          ],
        ),
      ),
    );
  }

  /// Build placeholder pill for loading state
  static Widget _buildPlaceholderPill(
      BuildContext context, String text, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
