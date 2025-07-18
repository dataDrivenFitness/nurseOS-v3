// 📁 lib/features/navigation_v3/presentation/widgets/enhanced_shift_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model_extensions.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/services/patient_analysis_service.dart';
import 'package:nurseos_v3/shared/widgets/color_coded_card.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/shared/widgets/buttons/secondary_button.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/utils/shift_display_helpers.dart';

/// Enhanced shift card with color-coded urgency sidebar
///
/// ✅ REFACTORED: Clean, working implementation
/// ✅ Smart patient load descriptions with proper loading states
/// ✅ Colleague empathy features working correctly
/// ✅ Broken down into focused sub-components
enum ShiftCardType { emergency, coverage, regular }

class EnhancedShiftCard extends ConsumerStatefulWidget {
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
  ConsumerState<EnhancedShiftCard> createState() => _EnhancedShiftCardState();
}

class _EnhancedShiftCardState extends ConsumerState<EnhancedShiftCard> {
  String? _smartPatientDescription;
  bool _loadingDescription = false;

  @override
  void initState() {
    super.initState();
    _loadSmartPatientDescription();
  }

  @override
  void didUpdateWidget(EnhancedShiftCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shift.assignedPatientIds != widget.shift.assignedPatientIds) {
      _loadSmartPatientDescription();
    }
  }

  Future<void> _loadSmartPatientDescription() async {
    if (!widget.shift.hasAssignedPatients) return;

    setState(() {
      _loadingDescription = true;
    });

    try {
      final analysisService = ref.read(patientAnalysisServiceProvider);
      String description;

      if (analysisService != null) {
        description = await analysisService.generatePatientLoadDescription(
          widget.shift.assignedPatientIds,
        );
      } else {
        description = widget.shift.generatePatientLoadDescription();
      }

      if (mounted) {
        setState(() {
          _smartPatientDescription = description;
          _loadingDescription = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _smartPatientDescription =
              widget.shift.generatePatientLoadDescription();
          _loadingDescription = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final hasRequested = widget.shift.hasRequestedBy(widget.user.uid);
    final urgencyColor = _getUrgencyColor(colors);

    return ColorCodedCard.shift(
      urgencyColor: urgencyColor,
      onTap: widget.onShowDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with facility name and status
          _ShiftCardHeader(
            shift: widget.shift,
            hasRequested: hasRequested,
            urgencyColor: urgencyColor,
            type: widget.type,
          ),

          const SizedBox(height: SpacingTokens.md),

          // Date and time information
          _ShiftCardDateTime(shift: widget.shift),

          const SizedBox(height: SpacingTokens.sm),

          // Shift details (patients, compensation, requirements)
          _ShiftCardDetails(
            shift: widget.shift,
            smartPatientDescription: _smartPatientDescription,
            loadingDescription: _loadingDescription,
          ),

          // Special information (coverage messages, requirements)
          if (widget.shift.coverageContextMessage != null ||
              widget.shift.specialRequirements != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            _ShiftCardSpecialInfo(
              shift: widget.shift,
              accentColor: urgencyColor,
            ),
          ],

          const SizedBox(height: SpacingTokens.md),

          // Action button
          _ShiftCardActionButton(
            shift: widget.shift,
            user: widget.user,
            type: widget.type,
            hasRequested: hasRequested,
            urgencyColor: urgencyColor,
            onRequestShift: widget.onRequestShift,
          ),

          // Posted time
          if (widget.shift.createdAt != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            _ShiftCardPostedTime(createdAt: widget.shift.createdAt!),
          ],
        ],
      ),
    );
  }

  Color _getUrgencyColor(AppColors colors) {
    switch (widget.type) {
      case ShiftCardType.emergency:
        return colors.danger;
      case ShiftCardType.coverage:
        return colors.warning;
      case ShiftCardType.regular:
        return colors.brandPrimary;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// SUB-COMPONENTS: Focused, reusable widgets
// ═══════════════════════════════════════════════════════════════════

/// Header section with facility name and status chip
class _ShiftCardHeader extends StatelessWidget {
  final ShiftModel shift;
  final bool hasRequested;
  final Color urgencyColor;
  final ShiftCardType type;

  const _ShiftCardHeader({
    required this.shift,
    required this.hasRequested,
    required this.urgencyColor,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Row(
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
        _ShiftStatusChip(
          hasRequested: hasRequested,
          urgencyColor: urgencyColor,
          type: type,
        ),
      ],
    );
  }
}

/// Status chip showing request status or urgency
class _ShiftStatusChip extends StatelessWidget {
  final bool hasRequested;
  final Color urgencyColor;
  final ShiftCardType type;

  const _ShiftStatusChip({
    required this.hasRequested,
    required this.urgencyColor,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

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

    final (statusText, statusBgColor, textColor) = switch (type) {
      ShiftCardType.emergency => ('URGENT', colors.danger, Colors.white),
      ShiftCardType.coverage => ('COVERAGE', colors.warning, Colors.white),
      ShiftCardType.regular => (
          'Available',
          urgencyColor.withOpacity(0.1),
          urgencyColor
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Date and time information section
class _ShiftCardDateTime extends StatelessWidget {
  final ShiftModel shift;

  const _ShiftCardDateTime({required this.shift});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

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
              ShiftDisplayHelpers.formatShiftDate(shift.startTime),
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
}

/// Shift details section (patients, compensation, requirements)
class _ShiftCardDetails extends StatelessWidget {
  final ShiftModel shift;
  final String? smartPatientDescription;
  final bool loadingDescription;

  const _ShiftCardDetails({
    required this.shift,
    required this.smartPatientDescription,
    required this.loadingDescription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Column(
      children: [
        // Smart patient descriptions
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
                child: loadingDescription
                    ? Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(colors.subdued),
                            ),
                          ),
                          const SizedBox(width: SpacingTokens.xs),
                          Text(
                            'Loading patient info...',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.subdued,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        smartPatientDescription ??
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

        // Compensation information
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
          const SizedBox(height: SpacingTokens.xs),
        ],

        // Certification requirements
        if (shift.hasCertificationRequirements) ...[
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
}

/// Special information section (coverage messages, requirements)
class _ShiftCardSpecialInfo extends StatelessWidget {
  final ShiftModel shift;
  final Color accentColor;

  const _ShiftCardSpecialInfo({
    required this.shift,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
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
}

/// Action button section
class _ShiftCardActionButton extends StatelessWidget {
  final ShiftModel shift;
  final UserModel user;
  final ShiftCardType type;
  final bool hasRequested;
  final Color urgencyColor;
  final VoidCallback? onRequestShift;

  const _ShiftCardActionButton({
    required this.shift,
    required this.user,
    required this.type,
    required this.hasRequested,
    required this.urgencyColor,
    this.onRequestShift,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }

  IconData _getActionIcon() {
    return switch (type) {
      ShiftCardType.emergency => Icons.local_hospital,
      ShiftCardType.coverage => Icons.people_alt,
      ShiftCardType.regular => Icons.add,
    };
  }
}

/// Posted time section
class _ShiftCardPostedTime extends StatelessWidget {
  final DateTime createdAt;

  const _ShiftCardPostedTime({required this.createdAt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Text(
      'Posted ${ShiftDisplayHelpers.formatPostedTime(createdAt)}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: colors.subdued,
        fontSize: 11,
      ),
    );
  }
}
