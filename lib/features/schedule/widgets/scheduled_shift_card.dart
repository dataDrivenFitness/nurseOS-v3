// 📁 lib/features/schedule/widgets/scheduled_shift_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model_extensions.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduledShiftCard extends StatelessWidget {
  final ScheduledShiftModel shift;
  final VoidCallback? onTap;
  final VoidCallback? onConfirm;
  final VoidCallback? onClockIn; // New parameter

  const ScheduledShiftCard({
    super.key,
    required this.shift,
    this.onTap,
    this.onConfirm,
    this.onClockIn, // New parameter
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isFacility = shift.locationType == 'facility';
    final formattedAddress = _formatFullAddress();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.sm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with location and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shift.locationDisplay, // Using extension method
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (formattedAddress.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            formattedAddress,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.subdued,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Map icon when we have an address
                  if (formattedAddress.isNotEmpty) ...[
                    const SizedBox(width: SpacingTokens.sm),
                    IconButton(
                      onPressed: () => _openMap(formattedAddress),
                      icon: Icon(
                        Icons.map,
                        color: colors.brandPrimary,
                        size: 24,
                      ),
                      tooltip: 'Open in Maps',
                    ),
                  ],
                  // Status indicator with ownership badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusChip(
                          shift.statusDisplay, shift.isConfirmed, colors),
                      if (shift.isUserCreated) ...[
                        const SizedBox(height: 4),
                        _buildOwnershipBadge(colors),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: SpacingTokens.md),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colors.brandPrimary,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(shift.startTime),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: SpacingTokens.sm),

              // Time and duration
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
                      _formatTimeRange(shift.startTime, shift.endTime),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    shift.formattedDuration, // Using extension method
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.subdued,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Location type indicator
              const SizedBox(height: SpacingTokens.sm),
              Row(
                children: [
                  Icon(
                    isFacility ? Icons.business : Icons.home,
                    size: 16,
                    color: colors.subdued,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(
                      _formatLocationType(shift.locationType),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.subdued,
                      ),
                    ),
                  ),
                  // Shift source indicator
                  Text(
                    shift.ownershipType, // Using extension method
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.subdued,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Assigned patients (if any)
              if (shift.hasPatients) ...[
                const SizedBox(height: SpacingTokens.sm),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: colors.subdued,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Text(
                      '${shift.patientCount} patient${shift.patientCount != 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.subdued,
                      ),
                    ),
                  ],
                ),
              ],

              // Action buttons section - MODIFIED
              if (shift.needsConfirmation && onConfirm != null ||
                  onClockIn != null) ...[
                const SizedBox(height: SpacingTokens.md),

                // Confirm button for unconfirmed shifts
                if (shift.needsConfirmation && onConfirm != null) ...[
                  PrimaryButton(
                    label: 'Confirm Shift',
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check, size: 18),
                  ),
                  if (onClockIn != null)
                    const SizedBox(height: SpacingTokens.sm),
                ],

                // Clock-in button - NEW
                if (onClockIn != null) ...[
                  PrimaryButton(
                    label: 'Clock In',
                    onPressed: onClockIn,
                    icon: const Icon(Icons.play_circle, size: 18),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Formats the full address using only the address field (for now)
  /// TODO: Update when structured address fields are added to the model
  String _formatFullAddress() {
    // Use the single address field that exists in the current model
    return shift.address ?? '';
  }

  Widget _buildStatusChip(String status, bool isConfirmed, AppColors colors) {
    final Color backgroundColor;
    final Color textColor;

    if (!isConfirmed) {
      backgroundColor = colors.warning.withOpacity(0.1);
      textColor = colors.warning;
    } else {
      switch (status.toLowerCase()) {
        case 'confirmed':
          backgroundColor = colors.success.withOpacity(0.1);
          textColor = colors.success;
          break;
        case 'scheduled':
          backgroundColor = colors.brandPrimary.withOpacity(0.1);
          textColor = colors.brandPrimary;
          break;
        case 'in progress':
          backgroundColor = colors.brandPrimary.withOpacity(0.1);
          textColor = colors.brandPrimary;
          break;
        case 'completed':
          backgroundColor = colors.subdued.withOpacity(0.1);
          textColor = colors.subdued;
          break;
        default:
          backgroundColor = colors.subdued.withOpacity(0.1);
          textColor = colors.subdued;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// Build ownership badge for user-created shifts
  Widget _buildOwnershipBadge(AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colors.brandAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Self-Created',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colors.brandAccent,
        ),
      ),
    );
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    final startTime = DateFormat('h:mm a').format(start);
    final endTime = DateFormat('h:mm a').format(end);
    return '$startTime - $endTime';
  }

  String _formatLocationType(String locationType) {
    switch (locationType.toLowerCase()) {
      case 'facility':
        return 'Healthcare Facility';
      case 'residence':
        return 'Patient Home';
      case 'hospital':
        return 'Hospital';
      case 'snf':
        return 'Skilled Nursing Facility';
      case 'rehab':
        return 'Rehabilitation Center';
      case 'other':
        return 'Other Location';
      default:
        return locationType;
    }
  }

  Future<void> _openMap(String address) async {
    if (address.isEmpty) return;

    final encodedAddress = Uri.encodeComponent(address);
    final url =
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening map: $e');
    }
  }
}
