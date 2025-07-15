// 📁 lib/features/navigation_v3/presentation/available_shifts_screen.dart
// UPDATED: Real data integration replacing mock generators

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model_extensions.dart';
import 'package:nurseos_v3/features/schedule/widgets/scheduled_shift_card.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/state/shift_pool_provider.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/state/shift_request_controller.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model.dart';
import 'package:nurseos_v3/features/agency/state/agency_context_provider.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/shared/widgets/buttons/secondary_button.dart';

/// Available Shifts Screen - First tab of new navigation system
///
/// UPDATED: Now connects to real Firestore data via existing providers
///
/// Displays shifts available for nurses to request or create:
/// - Agency nurses: Available shifts from affiliated agencies (via shiftPoolProvider)
/// - Independent nurses: Can create custom shifts + see agency opportunities
/// - Dual-mode nurses: Both agency shifts and self-creation options
class AvailableShiftsScreen extends ConsumerStatefulWidget {
  const AvailableShiftsScreen({super.key});

  @override
  ConsumerState<AvailableShiftsScreen> createState() =>
      _AvailableShiftsScreenState();
}

class _AvailableShiftsScreenState extends ConsumerState<AvailableShiftsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Two tabs: Agency Shifts and My Shifts (for independent nurses)
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final user = ref.watch(authControllerProvider).value;

    if (user == null) {
      return const NurseScaffold(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return NurseScaffold(
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: const Text('Available Shifts'),
          backgroundColor: colors.surface,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: colors.brandPrimary,
            unselectedLabelColor: colors.subdued,
            indicatorColor: colors.brandPrimary,
            tabs: [
              Tab(
                icon: const Icon(Icons.business, size: 20),
                text: 'Agency Shifts',
              ),
              Tab(
                icon: const Icon(Icons.person_add, size: 20),
                text: user.isIndependentNurse ? 'My Shifts' : 'Create Shift',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAgencyShiftsTab(user),
            _buildIndependentShiftsTab(user),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(user, colors),
      ),
    );
  }

  /// Tab 1: Agency Shifts - UPDATED: Real data from shiftPoolProvider
  Widget _buildAgencyShiftsTab(UserModel user) {
    final agencyShiftsAsync = ref.watch(shiftPoolProvider);
    final currentAgencyId = ref.watch(currentAgencyIdProvider);

    return agencyShiftsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(
        icon: Icons.error_outline,
        title: 'Unable to Load Shifts',
        subtitle: currentAgencyId == null
            ? 'No agency selected. Please contact admin to assign you to an agency.'
            : 'Check your connection and try again.',
        actionLabel: currentAgencyId != null ? 'Retry' : null,
        onAction: currentAgencyId != null
            ? () {
                // Trigger refresh by invalidating the provider
                ref.invalidate(shiftPoolProvider);
              }
            : null,
      ),
      data: (shifts) {
        // Filter only available shifts that aren't assigned
        final availableShifts = shifts
            .where((shift) =>
                shift.status == 'available' &&
                (shift.assignedTo == null || shift.assignedTo!.isEmpty))
            .toList();

        if (availableShifts.isEmpty) {
          return _buildEmptyState(
            icon: Icons.work_off,
            title: 'No Available Shifts',
            subtitle: currentAgencyId == null
                ? 'No agency context available.\nContact admin to assign you to an agency.'
                : 'Check back later for new opportunities\nfrom your affiliated agencies.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(shiftPoolProvider);
            // Wait a bit for the provider to refresh
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
            itemCount: availableShifts.length,
            itemBuilder: (context, index) {
              final shift = availableShifts[index];
              return _buildAgencyShiftCard(shift, user);
            },
          ),
        );
      },
    );
  }

  /// Build agency shift card with real request functionality
  Widget _buildAgencyShiftCard(ShiftModel shift, UserModel user) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final controller = ref.read(shiftRequestControllerProvider);

    // Check if user has already requested this shift
    final hasRequested = shift.requestedBy?.contains(user.uid) ?? false;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.sm,
      ),
      child: InkWell(
        onTap: () => _showShiftDetails(shift),
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
                          shift.facilityName ?? shift.location,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (shift.department != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            shift.department!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.subdued,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (_buildAddressDisplay(shift).isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            _buildAddressDisplay(shift),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.subdued,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Status indicator
                  _buildShiftStatusChip(hasRequested, colors),
                ],
              ),

              const SizedBox(height: SpacingTokens.md),

              // Date and time
              _buildShiftDateTime(shift, colors),

              // Special requirements or patient info
              if (shift.specialRequirements != null ||
                  shift.patientName != null) ...[
                const SizedBox(height: SpacingTokens.sm),
                _buildShiftExtras(shift, colors),
              ],

              // Request button
              const SizedBox(height: SpacingTokens.md),
              SizedBox(
                width: double.infinity,
                child: hasRequested
                    ? SecondaryButton(
                        label: 'Request Sent',
                        onPressed: null, // Disabled
                        icon: const Icon(Icons.check, size: 18),
                      )
                    : PrimaryButton(
                        label: 'Request Shift',
                        onPressed: () => _requestShift(shift, controller, user),
                        icon: const Icon(Icons.add, size: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build address display from shift data
  String _buildAddressDisplay(ShiftModel shift) {
    final parts = <String>[];
    if (shift.addressLine1 != null) parts.add(shift.addressLine1!);
    if (shift.city != null) parts.add(shift.city!);
    if (shift.state != null) parts.add(shift.state!);
    return parts.join(', ');
  }

  /// Build status chip for shift request state
  Widget _buildShiftStatusChip(bool hasRequested, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: hasRequested
            ? colors.success.withOpacity(0.1)
            : colors.brandPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        hasRequested ? 'Requested' : 'Available',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: hasRequested ? colors.success : colors.brandPrimary,
        ),
      ),
    );
  }

  /// Build date and time display for shift
  Widget _buildShiftDateTime(ShiftModel shift, AppColors colors) {
    final theme = Theme.of(context);

    return Column(
      children: [
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
              _formatShiftDate(shift.startTime),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.xs),
        // Time
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
                _formatShiftTime(shift.startTime, shift.endTime),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              _formatShiftDuration(shift.startTime, shift.endTime),
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

  /// Build extra info (special requirements, patient name)
  Widget _buildShiftExtras(ShiftModel shift, AppColors colors) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (shift.patientName != null) ...[
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: colors.subdued,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                'Patient: ${shift.patientName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.subdued,
                ),
              ),
            ],
          ),
        ],
        if (shift.specialRequirements != null) ...[
          if (shift.patientName != null)
            const SizedBox(height: SpacingTokens.xs),
          Row(
            children: [
              Icon(
                Icons.info,
                size: 16,
                color: colors.warning,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  shift.specialRequirements!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (shift.assignedPatientIds?.isNotEmpty == true) ...[
          const SizedBox(height: SpacingTokens.xs),
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: colors.subdued,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                '${shift.assignedPatientIds!.length} patient${shift.assignedPatientIds!.length != 1 ? 's' : ''} assigned',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.subdued,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Tab 2: Independent/Create Shifts - TODO: Connect to real user-created shifts
  Widget _buildIndependentShiftsTab(UserModel user) {
    if (user.isIndependentNurse) {
      // TODO: Replace with real user-created shifts provider
      return _buildUserCreatedShifts(user);
    } else {
      // Show shift creation interface for agency-only nurses
      return _buildShiftCreationInterface();
    }
  }

  /// User-created shifts for independent nurses - TODO: Real provider integration
  Widget _buildUserCreatedShifts(UserModel user) {
    // TODO: Create and connect to userCreatedShiftsProvider
    // For now, show placeholder with action to create first shift
    return _buildEmptyState(
      icon: Icons.add_business,
      title: 'No Personal Shifts',
      subtitle:
          'Create your first shift to start\nmanaging your independent practice.',
      actionLabel: 'Create Shift',
      onAction: () => _showCreateShiftDialog(),
    );
  }

  /// Shift creation interface for agency-only nurses
  Widget _buildShiftCreationInterface() {
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 80,
            color: Theme.of(context).extension<AppColors>()!.subdued,
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            'Create Your Own Shift',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            'Independent nurses can create their own shifts\nand manage their patient roster.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).extension<AppColors>()!.subdued,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.xl),
          FilledButton.icon(
            onPressed: () => _showIndependentNurseInfo(),
            icon: const Icon(Icons.info_outline),
            label: const Text('Learn About Independent Practice'),
          ),
        ],
      ),
    );
  }

  /// Empty state widget for various scenarios
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: colors.subdued,
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.subdued,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SpacingTokens.xl),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Error state widget
  Widget _buildErrorState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: colors.danger,
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.danger,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.subdued,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SpacingTokens.xl),
              PrimaryButton(
                label: actionLabel,
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Floating action button for shift creation
  Widget? _buildFloatingActionButton(UserModel user, AppColors colors) {
    // Show FAB on independent shifts tab for independent nurses
    if (_tabController.index == 1 && user.isIndependentNurse) {
      return FloatingActionButton.extended(
        onPressed: () => _showCreateShiftDialog(),
        backgroundColor: colors.brandPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Create Shift'),
      );
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════
  // ACTION HANDLERS - UPDATED: Real functionality
  // ═══════════════════════════════════════════════════════════════════

  /// Request a shift using the real controller
  Future<void> _requestShift(
    ShiftModel shift,
    ShiftRequestController controller,
    UserModel user,
  ) async {
    try {
      // Show confirmation dialog
      final confirmed = await _showRequestConfirmationDialog(shift);
      if (!confirmed) return;

      // Show loading state
      _showLoadingSnackBar('Sending shift request...');

      // Use the real shift request controller
      await controller.requestShift(shift.id, user.uid);

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: SpacingTokens.sm),
                const Expanded(
                  child: Text(
                    'Shift request sent! Admin will review and notify you.',
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).extension<AppColors>()!.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text('Failed to send request: ${_getErrorMessage(e)}'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).extension<AppColors>()!.danger,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _requestShift(shift, controller, user),
            ),
          ),
        );
      }
    }
  }

  /// Show shift request confirmation dialog
  Future<bool> _showRequestConfirmationDialog(ShiftModel shift) async {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Request Shift'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send a request for this shift?',
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
                      shift.facilityName ?? shift.location,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (shift.department != null) ...[
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        shift.department!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.subdued,
                        ),
                      ),
                    ],
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      _formatShiftDate(shift.startTime),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.subdued,
                      ),
                    ),
                    Text(
                      _formatShiftTime(shift.startTime, shift.endTime),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                'Your request will be sent to the scheduling team for approval. You\'ll be notified when a decision is made.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.subdued,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              label: 'Send Request',
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  /// Show loading snack bar
  void _showLoadingSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 30), // Long duration for loading
      ),
    );
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission')) {
      return 'Permission denied. Please contact admin.';
    } else if (errorString.contains('network')) {
      return 'Network error. Check your connection.';
    } else if (errorString.contains('agency')) {
      return 'Agency context missing. Please contact admin.';
    } else {
      return 'Please try again.';
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // PLACEHOLDERS - TODO: Implement actual functionality
  // ═══════════════════════════════════════════════════════════════════

  void _showShiftDetails(ShiftModel shift) {
    // TODO: Navigate to shift details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Showing details for ${shift.id}')),
    );
  }

  void _showCreateShiftDialog() {
    // TODO: Show create shift dialog or navigate to creation screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Shift'),
        content: const Text('Shift creation dialog will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shift creation coming soon!')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showIndependentNurseInfo() {
    // TODO: Show information about becoming an independent nurse
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Independent Nursing'),
        content: const Text(
          'Independent nurses can create their own shifts, manage patients, '
          'and set their own schedules. Contact admin to enable independent '
          'nursing features for your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to contact admin or settings
            },
            child: const Text('Contact Admin'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // FORMATTING HELPERS
  // ═══════════════════════════════════════════════════════════════════

  String _formatShiftDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final shiftDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (shiftDate == today) {
      return 'Today';
    } else if (shiftDate == tomorrow) {
      return 'Tomorrow';
    } else {
      // Format as "Mon, Jan 15"
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];

      final dayName = days[dateTime.weekday - 1];
      final monthName = months[dateTime.month - 1];

      return '$dayName, $monthName ${dateTime.day}';
    }
  }

  String _formatShiftTime(DateTime startTime, DateTime endTime) {
    String formatTime(DateTime time) {
      final hour = time.hour;
      final minute = time.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$displayHour:$minuteStr $period';
    }

    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }

  String _formatShiftDuration(DateTime startTime, DateTime endTime) {
    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }
}
