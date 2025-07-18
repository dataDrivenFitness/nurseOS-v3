// 📁 lib/features/navigation_v3/presentation/widgets/shift_tab_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model_extensions.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/state/shift_pool_provider.dart';
import 'package:nurseos_v3/features/agency/state/agency_context_provider.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/widgets/shift_empty_states.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/widgets/shift_section_header.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/widgets/enhanced_shift_card.dart';

/// Tab content management for agency and independent shifts
///
/// ✅ Extracted from AvailableShiftsScreen for reusability
/// ✅ Handles agency vs independent shift display logic
/// ✅ Manages refresh functionality and error states
class ShiftTabContent extends ConsumerWidget {
  final UserModel user;
  final List<String> agencies;
  final TabController tabController;
  final ScrollController scrollController;
  final VoidCallback? onNavigateToCreateShift;
  final Function(ShiftModel)? onShowShiftDetails;
  final Function(ShiftModel)? onRequestShift;

  const ShiftTabContent({
    super.key,
    required this.user,
    required this.agencies,
    required this.tabController,
    required this.scrollController,
    this.onNavigateToCreateShift,
    this.onShowShiftDetails,
    this.onRequestShift,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (user.isIndependentNurse) {
      if (agencies.isEmpty) {
        return _buildIndependentShiftsTab(context, ref);
      } else {
        return TabBarView(
          controller: tabController,
          children: [
            _buildAgencyShiftsTab(context, ref),
            _buildIndependentShiftsTab(context, ref),
          ],
        );
      }
    } else {
      return _buildAgencyShiftsTab(context, ref);
    }
  }

  /// Build agency shifts tab content
  Widget _buildAgencyShiftsTab(BuildContext context, WidgetRef ref) {
    final userAgenciesAsync = ref.watch(userAgenciesFromMembershipProvider);

    return userAgenciesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ShiftEmptyStates.buildErrorState(
        context: context,
        icon: Icons.error_outline,
        title: 'Unable to Load Agencies',
        subtitle: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(userAgenciesFromMembershipProvider),
      ),
      data: (agencyIds) {
        if (agencyIds.isEmpty) {
          return _buildNoAgencyAccessState(context);
        }
        return _buildAgencyShiftsList(context, ref);
      },
    );
  }

  /// Build no agency access state
  Widget _buildNoAgencyAccessState(BuildContext context) {
    return ShiftEmptyStates.buildNoAgencyAccessState(
      context: context,
      isIndependentNurse: user.isIndependentNurse,
      onCreateShift: onNavigateToCreateShift,
    );
  }

  /// Build agency shifts list with categorized sections
  Widget _buildAgencyShiftsList(BuildContext context, WidgetRef ref) {
    final agencyShiftsAsync = ref.watch(shiftPoolProvider);

    return agencyShiftsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ShiftEmptyStates.buildErrorState(
        context: context,
        icon: Icons.error_outline,
        title: 'Unable to Load Shifts',
        subtitle: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(shiftPoolProvider),
      ),
      data: (shifts) {
        final availableShifts = shifts
            .where((shift) =>
                shift.status == 'available' &&
                (shift.assignedTo == null || shift.assignedTo!.isEmpty))
            .toList();

        if (availableShifts.isEmpty) {
          return ShiftEmptyStates.buildNoAvailableShifts(context);
        }

        // Categorize shifts
        final emergencyShifts =
            availableShifts.where((s) => s.isEmergencyShift).toList();
        final coverageShifts =
            availableShifts.where((s) => s.isCoverageRequest).toList();
        final regularShifts =
            availableShifts.where((s) => s.isRegularShift).toList();

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(shiftPoolProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emergency Coverage Section
                if (emergencyShifts.isNotEmpty) ...[
                  ShiftSectionHeader(
                    title: '🚨 Emergency Coverage',
                    subtitle:
                        'Critical staffing needs requiring immediate response',
                    count: emergencyShifts.length,
                    accentColor: Colors.red,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  ...emergencyShifts.map((shift) => EnhancedShiftCard(
                        shift: shift,
                        user: user,
                        type: ShiftCardType.emergency,
                        onShowDetails: () => onShowShiftDetails?.call(shift),
                        onRequestShift: () => onRequestShift?.call(shift),
                      )),
                  const SizedBox(height: SpacingTokens.xl),
                ],

                // Coverage Requests Section
                if (coverageShifts.isNotEmpty) ...[
                  ShiftSectionHeader(
                    title: '🆘 Coverage Requests',
                    subtitle:
                        'Colleagues need help with their scheduled shifts',
                    count: coverageShifts.length,
                    accentColor: Colors.orange,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  ...coverageShifts.map((shift) => EnhancedShiftCard(
                        shift: shift,
                        user: user,
                        type: ShiftCardType.coverage,
                        onShowDetails: () => onShowShiftDetails?.call(shift),
                        onRequestShift: () => onRequestShift?.call(shift),
                      )),
                  const SizedBox(height: SpacingTokens.xl),
                ],

                // Open Shifts Section
                if (regularShifts.isNotEmpty) ...[
                  ShiftSectionHeader(
                    title: '📅 Open Shifts',
                    subtitle: 'Available shifts for pickup',
                    count: regularShifts.length,
                    accentColor: Colors.blue,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  ...regularShifts.map((shift) => EnhancedShiftCard(
                        shift: shift,
                        user: user,
                        type: ShiftCardType.regular,
                        onShowDetails: () => onShowShiftDetails?.call(shift),
                        onRequestShift: () => onRequestShift?.call(shift),
                      )),
                ],

                // Bottom padding for scroll clearance
                const SizedBox(height: SpacingTokens.xxl * 2),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build independent shifts tab content
  Widget _buildIndependentShiftsTab(BuildContext context, WidgetRef ref) {
    return _buildUserCreatedShifts(context);
  }

  /// Build user-created shifts (placeholder for future implementation)
  Widget _buildUserCreatedShifts(BuildContext context) {
    return ShiftEmptyStates.buildNoPersonalShifts(
      context: context,
      onCreateShift: onNavigateToCreateShift,
    );
  }

  /// Calculate tab count based on user type and agencies
  static int calculateTabCount(UserModel? user, List<String> agencies) {
    if (user?.isIndependentNurse == true) {
      if (agencies.isEmpty) {
        return 1; // Independent only
      } else {
        return 2; // Agency + Independent
      }
    } else {
      return 1; // Agency only
    }
  }

  /// Build conditional tab bar based on user type
  static Widget? buildConditionalTabBar({
    required BuildContext context,
    required UserModel user,
    required List<String> agencies,
    required TabController tabController,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    bool showAgencyTab = false;
    bool showMyShiftsTab = false;

    if (user.isIndependentNurse) {
      if (agencies.isEmpty) {
        showMyShiftsTab = true;
      } else {
        showAgencyTab = true;
        showMyShiftsTab = true;
      }
    } else {
      showAgencyTab = true;
    }

    final tabs = <Tab>[];
    if (showAgencyTab) {
      tabs.add(const Tab(
        icon: Icon(Icons.business, size: 20),
        text: 'Agency Shifts',
      ));
    }
    if (showMyShiftsTab) {
      tabs.add(const Tab(
        icon: Icon(Icons.person_add, size: 20),
        text: 'My Shifts',
      ));
    }

    if (tabs.length > 1) {
      return Container(
        color: colors.surface,
        child: TabBar(
          controller: tabController,
          labelColor: colors.brandPrimary,
          unselectedLabelColor: colors.subdued,
          indicatorColor: colors.brandPrimary,
          tabs: tabs,
        ),
      );
    }

    return null; // No tab bar needed
  }
}
