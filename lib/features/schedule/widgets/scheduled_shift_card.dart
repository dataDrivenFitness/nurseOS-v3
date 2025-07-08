// lib/features/schedule/widgets/scheduled_shift_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduledShiftCard extends StatelessWidget {
  final ScheduledShiftModel shift;
  final VoidCallback? onTap;
  final VoidCallback? onConfirm;

  const ScheduledShiftCard({
    super.key,
    required this.shift,
    this.onTap,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isFacility = shift.locationType == 'facility';

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
                          shift.facilityName ?? 'Unknown Location',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (shift.address != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            shift.address!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.subdued,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Map icon for non-facility locations
                  if (!isFacility && shift.address != null) ...[
                    const SizedBox(width: SpacingTokens.sm),
                    IconButton(
                      onPressed: () => _openMap(shift.address!),
                      icon: Icon(
                        Icons.map,
                        color: colors.brandPrimary,
                        size: 24,
                      ),
                      tooltip: 'Open in Maps',
                    ),
                  ],
                  // Status indicator
                  _buildStatusChip(shift.status, shift.isConfirmed, colors),
                ],
              ),

              const SizedBox(height: SpacingTokens.md),

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
                    _formatDuration(shift.startTime, shift.endTime),
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
                  Text(
                    _formatLocationType(shift.locationType),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.subdued,
                    ),
                  ),
                ],
              ),

              // Assigned patients (if any)
              if (shift.assignedPatientIds?.isNotEmpty == true) ...[
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
                      '${shift.assignedPatientIds!.length} patient${shift.assignedPatientIds!.length != 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.subdued,
                      ),
                    ),
                  ],
                ),
              ],

              // Confirm button for unconfirmed shifts
              if (!shift.isConfirmed && onConfirm != null) ...[
                const SizedBox(height: SpacingTokens.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Confirm Shift'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.brandPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isConfirmed, AppColors colors) {
    final String displayText;
    final Color backgroundColor;
    final Color textColor;

    if (!isConfirmed) {
      displayText = 'Pending';
      backgroundColor = colors.warning.withOpacity(0.1);
      textColor = colors.warning;
    } else {
      switch (status.toLowerCase()) {
        case 'accepted':
          displayText = 'Confirmed';
          backgroundColor = colors.success.withOpacity(0.1);
          textColor = colors.success;
          break;
        case 'scheduled':
          displayText = 'Scheduled';
          backgroundColor = colors.brandPrimary.withOpacity(0.1);
          textColor = colors.brandPrimary;
          break;
        default:
          displayText = status;
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
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    final startTime = DateFormat('h:mm a').format(start);
    final endTime = DateFormat('h:mm a').format(end);
    return '$startTime - $endTime';
  }

  String _formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatLocationType(String locationType) {
    switch (locationType.toLowerCase()) {
      case 'facility':
        return 'Healthcare Facility';
      case 'residence':
        return 'Patient Home';
      case 'other':
        return 'Other Location';
      default:
        return locationType;
    }
  }

  Future<void> _openMap(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url = 'https://maps.google.com/search/?api=1&query=$encodedAddress';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening map: $e');
    }
  }
}
