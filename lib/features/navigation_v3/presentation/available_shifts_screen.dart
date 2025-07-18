// 📁 lib/features/navigation_v3/presentation/available_shifts_screen.dart
// REFACTORED: Clean orchestrator using extracted components

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model_extensions.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/state/shift_pool_provider.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/state/shift_request_controller.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model.dart';
import 'package:nurseos_v3/features/agency/state/agency_context_provider.dart';
import 'package:nurseos_v3/shared/widgets/app_snackbar.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/widgets/shift_count_pills.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/widgets/shift_tab_content.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/utils/shift_display_helpers.dart';

/// Available Shifts Screen - Refactored with extracted components
///
/// ✅ REDUCED: From 1200+ lines to ~200 lines
/// ✅ CLEAN: Uses extracted components for all functionality
/// ✅ FOCUSED: Main screen only handles orchestration and user interactions
/// ✅ MAINTAINABLE: Each component has single responsibility
class AvailableShiftsScreen extends ConsumerStatefulWidget {
  const AvailableShiftsScreen({super.key});

  @override
  ConsumerState<AvailableShiftsScreen> createState() =>
      _AvailableShiftsScreenState();
}

class _AvailableShiftsScreenState extends ConsumerState<AvailableShiftsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.read(authControllerProvider).value;
    if (user != null) {
      _updateTabController(user);
    }
  }

  void _updateTabController(UserModel user) {
    final userAgencies =
        ref.read(userAgenciesFromMembershipProvider).value ?? [];

    final newTabCount = ShiftTabContent.calculateTabCount(user, userAgencies);

    if (_tabController.length != newTabCount) {
      _tabController.dispose();
      _tabController = TabController(length: newTabCount, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
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

    return Consumer(
      builder: (context, ref, child) {
        final agencies =
            ref.watch(userAgenciesFromMembershipProvider).value ?? [];

        return NurseScaffold(
          child: DefaultTabController(
            length: ShiftTabContent.calculateTabCount(user, agencies),
            child: Builder(
              builder: (context) {
                final tabController = DefaultTabController.of(context);

                return Scaffold(
                  backgroundColor: colors.background,
                  body: Column(
                    children: [
                      // Universal pill header
                      _buildPillHeader(user, agencies),

                      // Conditional tab bar
                      _buildConditionalTabBar(
                          colors, user, agencies, tabController),

                      // Tab content
                      Expanded(
                        child: ShiftTabContent(
                          user: user,
                          agencies: agencies,
                          tabController: tabController,
                          scrollController: _scrollController,
                          onNavigateToCreateShift: _navigateToCreateShift,
                          onShowShiftDetails: _showShiftDetails,
                          onRequestShift: _requestShift,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Build universal pill header using extracted component
  Widget _buildPillHeader(UserModel user, List<String> agencies) {
    final userAgenciesAsync = ref.watch(userAgenciesFromMembershipProvider);
    final agencyShiftsAsync = ref.watch(shiftPoolProvider);

    return userAgenciesAsync.when(
      loading: () => ShiftCountPills.buildPlaceholder(context),
      error: (_, __) => ShiftCountPills.buildPlaceholder(context),
      data: (agencyIds) {
        // For independent-only nurses with no agencies
        if (user.isIndependentNurse && agencyIds.isEmpty) {
          return ShiftCountPills(
            shifts: const [],
            user: user,
            hasAgencyAccess: false,
            onSectionTap: _scrollToSection,
          );
        }

        // For nurses with agency access
        return agencyShiftsAsync.when(
          loading: () => ShiftCountPills.buildPlaceholder(context),
          error: (_, __) => ShiftCountPills.buildPlaceholder(context),
          data: (shifts) {
            return ShiftCountPills(
              shifts: shifts,
              user: user,
              hasAgencyAccess: agencyIds.isNotEmpty,
              onSectionTap: _scrollToSection,
            );
          },
        );
      },
    );
  }

  /// Build conditional tab bar using extracted helper
  Widget _buildConditionalTabBar(AppColors colors, UserModel user,
      List<String> agencies, TabController tabController) {
    return ShiftTabContent.buildConditionalTabBar(
          context: context,
          user: user,
          agencies: agencies,
          tabController: tabController,
        ) ??
        const SizedBox.shrink();
  }

  // ===========================================================================
  // ACTION HANDLERS
  // ===========================================================================

  /// Handle shift requests with confirmation dialog
  Future<void> _requestShift(ShiftModel shift) async {
    final scaffoldContext = context;
    final user = ref.read(authControllerProvider).value;
    final controller = ref.read(shiftRequestControllerProvider);

    if (user == null) return;

    try {
      final confirmed = await _showRequestConfirmationDialog(shift);
      if (!confirmed || !mounted) return;

      AppSnackbar.loading(scaffoldContext, 'Sending shift request...');

      await controller.requestShift(shift.id, shift.agencyId!);

      if (mounted) {
        AppSnackbar.success(
          scaffoldContext,
          'Shift request sent! Admin will review and notify you.',
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(
          scaffoldContext,
          'Failed to send request: ${ShiftDisplayHelpers.getErrorMessage(e)}',
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _requestShift(shift),
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
                      shift.facilityDisplayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (shift.departmentDisplay != null) ...[
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        shift.departmentDisplay!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.subdued,
                        ),
                      ),
                    ],
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      ShiftDisplayHelpers.formatShiftDate(shift.startTime),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.subdued,
                      ),
                    ),
                    Text(
                      shift.timeRange,
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

  /// Handle scroll to section (pill tap)
  void _scrollToSection(int sectionIndex) {
    final sectionNames = ['Emergency', 'Coverage', 'Open Shifts'];
    if (sectionIndex < sectionNames.length) {
      AppSnackbar.info(
          context, 'Scrolling to ${sectionNames[sectionIndex]} section');
    }
  }

  /// Navigate to create shift screen
  void _navigateToCreateShift() {
    AppSnackbar.info(context, 'Opening Create Shift screen...');
  }

  /// Show shift details
  void _showShiftDetails(ShiftModel shift) {
    AppSnackbar.info(context, 'Showing details for ${shift.id}');
  }
}
