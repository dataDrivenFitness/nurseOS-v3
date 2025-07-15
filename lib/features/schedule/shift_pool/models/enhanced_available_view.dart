// lib/features/schedule/presentation/enhanced_available_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/state/shift_pool_provider.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/state/shift_request_controller.dart';
import 'package:nurseos_v3/shared/widgets/app_loader.dart';
import 'package:nurseos_v3/shared/widgets/app_snackbar.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/shared/widgets/buttons/secondary_button.dart';

/// Enhanced scheduling UX with healthcare-specific priority layout
///
/// Three-section design for better nurse workflow:
/// 1. 🚨 Emergency Coverage (red) - Critical staffing needs
/// 2. 🆘 Regular Coverage (orange) - Colleague requests for help
/// 3. 📅 Open Shifts (blue) - Normal available shifts
class EnhancedAvailableView extends ConsumerStatefulWidget {
  const EnhancedAvailableView({super.key});

  @override
  ConsumerState<EnhancedAvailableView> createState() =>
      _EnhancedAvailableViewState();
}

class _EnhancedAvailableViewState extends ConsumerState<EnhancedAvailableView> {
  @override
  Widget build(BuildContext context) {
    final shifts = ref.watch(shiftPoolProvider);
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return shifts.when(
      data: (data) => _buildAvailableContent(context, ref, data, colors),
      loading: () => const Center(child: AppLoader()),
      error: (e, st) => _buildErrorState(context, e, colors),
    );
  }

  /// Get display name for shift - facilityName for facilities, address for residence
  String _getShiftDisplayName(dynamic shift) {
    if (shift.location == 'residence') {
      // For home care, show address
      final address = shift.addressLine1 ?? 'Home Care';
      final patientName = shift.patientName;
      return patientName != null ? '$address - $patientName' : address;
    } else {
      // For facilities, show facilityName with department if available
      final facilityName = shift.facilityName ?? 'Medical Facility';
      final department = shift.department;
      return department != null ? '$facilityName - $department' : facilityName;
    }
  }

  Widget _buildAvailableContent(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> shifts,
    AppColors colors,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Emergency Coverage (Red Priority)
          _buildSectionHeader(
            context,
            '🚨 Emergency Coverage',
            'Critical staffing needs requiring immediate response',
            colors.danger,
            colors,
          ),
          const SizedBox(height: SpacingTokens.sm),
          _buildEmergencyCoverageSection(context, colors),

          const SizedBox(height: SpacingTokens.xl),

          // Section 2: Regular Coverage (Orange Priority)
          _buildSectionHeader(
            context,
            '🆘 Regular Coverage',
            'Colleague requests for help with scheduled shifts',
            colors.warning,
            colors,
          ),
          const SizedBox(height: SpacingTokens.sm),
          _buildRegularCoverageSection(context, colors),

          const SizedBox(height: SpacingTokens.xl),

          // Section 3: Open Shifts (Blue Priority)
          _buildSectionHeader(
            context,
            '📅 Open Shifts',
            'Available shifts for pickup',
            colors.brandPrimary,
            colors,
          ),
          const SizedBox(height: SpacingTokens.sm),
          _buildOpenShiftsSection(context, ref, shifts, colors),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
    Color accentColor,
    AppColors colors,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.subdued,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCoverageSection(
      BuildContext context, AppColors colors) {
    return _buildPlaceholderCard(
      context,
      'Emergency coverage requests will appear here',
      'When colleagues mark shifts as urgent coverage needed',
      colors.danger,
      colors,
      Icons.local_hospital,
    );
  }

  Widget _buildRegularCoverageSection(BuildContext context, AppColors colors) {
    return _buildPlaceholderCard(
      context,
      'Coverage requests will appear here',
      'When colleagues need help with their scheduled shifts',
      colors.warning,
      colors,
      Icons.people_alt,
    );
  }

  Widget _buildOpenShiftsSection(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> shifts,
    AppColors colors,
  ) {
    if (shifts.isEmpty) {
      return _buildPlaceholderCard(
        context,
        'No open shifts available',
        'Check back later for new opportunities',
        colors.brandPrimary,
        colors,
        Icons.event_available,
      );
    }

    return Column(
      children: shifts
          .map((shift) => _buildShiftCard(context, ref, shift, colors))
          .toList(),
    );
  }

  Widget _buildPlaceholderCard(
    BuildContext context,
    String title,
    String subtitle,
    Color accentColor,
    AppColors colors,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      color: colors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: accentColor.withOpacity(0.6),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.subdued,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCard(
    BuildContext context,
    WidgetRef ref,
    dynamic shift,
    AppColors colors,
  ) {
    final theme = Theme.of(context);
    final controller = ref.read(shiftRequestControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final currentUserId = auth.value?.uid ?? 'mockUser';
    final isRequested = shift.requestedBy?.contains(currentUserId) ?? false;

    return Card(
      elevation: 2,
      color: colors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with location and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getShiftDisplayName(shift),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.sm,
                    vertical: SpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isRequested
                        ? colors.success.withOpacity(0.1)
                        : colors.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isRequested ? 'Requested' : 'Available',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isRequested ? colors.success : colors.brandPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: SpacingTokens.md),

            // Time range
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: colors.brandPrimary,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: SpacingTokens.sm),

            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: colors.subdued,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  DateFormat('EEEE, MMM d').format(shift.startTime),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.subdued,
                  ),
                ),
              ],
            ),

            const SizedBox(height: SpacingTokens.md),

            // Request button using existing controller
            isRequested
                ? SecondaryButton(
                    label: 'Request Sent',
                    onPressed: null, // Disabled state
                    icon: const Icon(Icons.check, size: 18),
                  )
                : PrimaryButton(
                    label: 'Request Shift',
                    onPressed: () => _showRequestConfirmation(
                        context, ref, shift, controller),
                    icon: const Icon(Icons.add, size: 18),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRequestConfirmation(
    BuildContext context,
    WidgetRef ref,
    dynamic shift,
    dynamic controller,
  ) async {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request Shift'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to request this shift?',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: SpacingTokens.md),
              Container(
                padding: const EdgeInsets.all(SpacingTokens.md),
                decoration: BoxDecoration(
                  color: colors.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.location,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      '${DateFormat('EEEE, MMM d').format(shift.startTime)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.subdued,
                      ),
                    ),
                    Text(
                      '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                'Your request will be sent to the scheduling team for approval.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.subdued,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              label: 'Send Request',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        final auth = ref.read(authControllerProvider);
        final currentUserId = auth.value?.uid ?? 'mockUser';
        await controller.requestShift(shift.id, currentUserId);

        AppSnackbar.success(context, 'Shift request sent successfully');
      } catch (error) {
        AppSnackbar.error(context, 'Failed to send request. Please try again.');
      }
    }
  }

  Widget _buildErrorState(
      BuildContext context, Object error, AppColors colors) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colors.danger,
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              'Unable to load shifts',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Please check your connection and try again',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.subdued,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.lg),
            PrimaryButton(
              label: 'Retry',
              onPressed: () {
                // Trigger a refresh - the provider will handle this
              },
              icon: const Icon(Icons.refresh, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
