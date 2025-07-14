// lib/features/navigation_v3/presentation/widgets/upcoming_shifts_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/text_styles.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/shared/widgets/buttons/secondary_button.dart';
import 'package:nurseos_v3/features/schedule/widgets/scheduled_shift_card.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import '../providers/enhanced_upcoming_shifts_provider.dart';

class UpcomingShiftsTab extends ConsumerStatefulWidget {
  const UpcomingShiftsTab({super.key});

  @override
  ConsumerState<UpcomingShiftsTab> createState() => _UpcomingShiftsTabState();
}

class _UpcomingShiftsTabState extends ConsumerState<UpcomingShiftsTab> {
  ShiftFilter _currentFilter = const ShiftFilter(status: ShiftStatusFilter.all);
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;
    final user = ref.watch(authControllerProvider).value;
    final capabilities = ref.watch(shiftCreationCapabilitiesProvider);

    // Watch filtered shifts based on current filter
    final shiftsAsync =
        ref.watch(filteredUpcomingShiftsProvider(_currentFilter));
    final groupedShiftsAsync = ref.watch(groupedUpcomingShiftsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(enhancedUpcomingShiftsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Filter Bar
            SliverToBoxAdapter(
              child: _buildFilterBar(context, user, capabilities),
            ),

            // Shifts Content
            shiftsAsync.when(
              loading: () => _buildLoadingSliver(),
              error: (error, stack) =>
                  _buildErrorSliver(context, error.toString()),
              data: (shifts) {
                if (shifts.isEmpty) {
                  return _buildEmptySliver(context, capabilities);
                }

                return groupedShiftsAsync.when(
                  data: (grouped) =>
                      _buildGroupedShiftsSliver(context, grouped),
                  loading: () => _buildShiftsListSliver(shifts),
                  error: (_, __) => _buildShiftsListSliver(shifts),
                );
              },
            ),
          ],
        ),
      ),

      // FAB for independent nurses
      floatingActionButton: capabilities.canCreateIndependentShifts
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateShiftDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Shift'),
              backgroundColor: colors.brandPrimary,
            )
          : null,
    );
  }

  Widget _buildFilterBar(BuildContext context, dynamic user,
      ShiftCreationCapabilities capabilities) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.subdued.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Filter Toggle and Quick Actions
          Row(
            children: [
              // Filter Toggle
              InkWell(
                onTap: () => setState(() => _showFilters = !_showFilters),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.sm,
                    vertical: SpacingTokens.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showFilters
                            ? Icons.filter_list_off
                            : Icons.filter_list,
                        size: 20,
                        color: colors.brandPrimary,
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      Text(
                        'Filter',
                        style: textTheme.labelLarge?.copyWith(
                          color: colors.brandPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Quick Agency Switch (for dual-mode nurses)
              if (capabilities.canWorkWithMultipleAgencies) ...[
                _buildQuickAgencySwitch(context, capabilities),
              ],
            ],
          ),

          // Expanded Filter Options
          if (_showFilters) ...[
            const SizedBox(height: SpacingTokens.md),
            _buildExpandedFilters(context, user, capabilities),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAgencySwitch(
      BuildContext context, ShiftCreationCapabilities capabilities) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: colors.subdued.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getAgencyDisplayName(_currentFilter.agencyId),
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: SpacingTokens.xs),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: colors.subdued,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: null,
          child: const Text('All Shifts'),
        ),
        if (capabilities.canCreateIndependentShifts)
          const PopupMenuItem(
            value: 'independent',
            child: Text('Independent Only'),
          ),
        ...capabilities.availableAgencies.map(
          (agencyId) => PopupMenuItem(
            value: agencyId,
            child: Text(_getAgencyDisplayName(agencyId)),
          ),
        ),
      ],
      onSelected: (agencyId) {
        setState(() {
          _currentFilter = _currentFilter.copyWith(agencyId: agencyId);
        });
      },
    );
  }

  Widget _buildExpandedFilters(BuildContext context, dynamic user,
      ShiftCreationCapabilities capabilities) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    return FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Options',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: SpacingTokens.md),

          // Status Filter
          Text(
            'Status',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Wrap(
            spacing: SpacingTokens.sm,
            children: ShiftStatusFilter.values.map((status) {
              final isSelected = _currentFilter.status == status;
              return FilterChip(
                label: Text(_getStatusDisplayName(status)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _currentFilter = _currentFilter.copyWith(
                      status: selected ? status : ShiftStatusFilter.all,
                    );
                  });
                },
                selectedColor: colors.brandPrimary.withOpacity(0.2),
                checkmarkColor: colors.brandPrimary,
              );
            }).toList(),
          ),

          const SizedBox(height: SpacingTokens.lg),

          // Agency Filter (full options)
          Text(
            'Shift Source',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Wrap(
            spacing: SpacingTokens.sm,
            children: [
              FilterChip(
                label: const Text('All Sources'),
                selected: _currentFilter.agencyId == null,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _currentFilter = _currentFilter.copyWith(agencyId: null);
                    });
                  }
                },
                selectedColor: colors.brandPrimary.withOpacity(0.2),
              ),
              if (capabilities.canCreateIndependentShifts)
                FilterChip(
                  label: const Text('Independent'),
                  selected: _currentFilter.agencyId == 'independent',
                  onSelected: (selected) {
                    setState(() {
                      _currentFilter = _currentFilter.copyWith(
                        agencyId: selected ? 'independent' : null,
                      );
                    });
                  },
                  selectedColor: colors.brandAccent.withOpacity(0.2),
                ),
              ...capabilities.availableAgencies.map(
                (agencyId) => FilterChip(
                  label: Text(_getAgencyDisplayName(agencyId)),
                  selected: _currentFilter.agencyId == agencyId,
                  onSelected: (selected) {
                    setState(() {
                      _currentFilter = _currentFilter.copyWith(
                        agencyId: selected ? agencyId : null,
                      );
                    });
                  },
                  selectedColor: colors.brandPrimary.withOpacity(0.2),
                ),
              ),
            ],
          ),

          const SizedBox(height: SpacingTokens.lg),

          // Clear Filters Button
          SizedBox(
            width: double.infinity,
            child: SecondaryButton(
              label: 'Clear All Filters',
              onPressed: () {
                setState(() {
                  _currentFilter =
                      const ShiftFilter(status: ShiftStatusFilter.all);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSliver() {
    return const SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorSliver(BuildContext context, String error) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: colors.danger,
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                'Error Loading Shifts',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                error,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.subdued,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.lg),
              SecondaryButton(
                label: 'Retry',
                onPressed: () {
                  ref.invalidate(enhancedUpcomingShiftsProvider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySliver(
      BuildContext context, ShiftCreationCapabilities capabilities) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                size: 64,
                color: colors.subdued,
              ),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                'No Upcoming Shifts',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                _getEmptyStateMessage(),
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.subdued,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.xl),

              // Action buttons based on capabilities
              if (capabilities.canCreateIndependentShifts) ...[
                PrimaryButton(
                  label: 'Create Your First Shift',
                  onPressed: () => _showCreateShiftDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                ),
                const SizedBox(height: SpacingTokens.md),
              ],

              if (capabilities.canRequestAgencyShifts) ...[
                SecondaryButton(
                  label: 'Browse Available Shifts',
                  onPressed: () => _navigateToAvailableShifts(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedShiftsSliver(
      BuildContext context, GroupedShifts grouped) {
    return SliverList(
      delegate: SliverChildListDelegate([
        if (grouped.hasToday) ...[
          _buildSectionHeader(context, 'Today', grouped.today.length),
          ...grouped.today.map((shift) => _buildShiftCard(shift)),
          const SizedBox(height: SpacingTokens.lg),
        ],
        if (grouped.hasTomorrow) ...[
          _buildSectionHeader(context, 'Tomorrow', grouped.tomorrow.length),
          ...grouped.tomorrow.map((shift) => _buildShiftCard(shift)),
          const SizedBox(height: SpacingTokens.lg),
        ],
        if (grouped.hasThisWeek) ...[
          _buildSectionHeader(context, 'This Week', grouped.thisWeek.length),
          ...grouped.thisWeek.map((shift) => _buildShiftCard(shift)),
          const SizedBox(height: SpacingTokens.lg),
        ],
        if (grouped.hasLater) ...[
          _buildSectionHeader(context, 'Later', grouped.later.length),
          ...grouped.later.map((shift) => _buildShiftCard(shift)),
          const SizedBox(height: SpacingTokens.lg),
        ],
      ]),
    );
  }

  Widget _buildShiftsListSliver(List<dynamic> shifts) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildShiftCard(shifts[index]),
        childCount: shifts.length,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.lg,
        SpacingTokens.md,
        SpacingTokens.lg,
        SpacingTokens.sm,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: colors.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: textTheme.labelSmall?.copyWith(
                color: colors.brandPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(dynamic shift) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: ScheduledShiftCard(
        shift: shift,
        onTap: () => _showShiftDetails(shift),
        onConfirm:
            (!shift.isConfirmed) // Use isConfirmed instead of needsConfirmation
                ? () => _confirmShift(shift)
                : null,
      ),
    );
  }

  // Helper methods for display names and messages
  String _getAgencyDisplayName(String? agencyId) {
    if (agencyId == null) return 'All Shifts';
    if (agencyId == 'independent') return 'Independent';

    // TODO: Replace with actual agency name lookup
    switch (agencyId) {
      case 'metro_hospital':
        return 'Metro Hospital';
      case 'sunrise_care':
        return 'Sunrise Home Care';
      case 'city_medical':
        return 'City Medical Center';
      default:
        return 'Agency ${agencyId.substring(0, 8)}...';
    }
  }

  String _getStatusDisplayName(ShiftStatusFilter status) {
    switch (status) {
      case ShiftStatusFilter.all:
        return 'All';
      case ShiftStatusFilter.confirmed:
        return 'Confirmed';
      case ShiftStatusFilter.pending:
        return 'Pending';
    }
  }

  String _getEmptyStateMessage() {
    if (_currentFilter.agencyId == 'independent') {
      return 'You haven\'t created any independent shifts yet. Create your first shift to start managing your own schedule.';
    } else if (_currentFilter.agencyId != null) {
      return 'No upcoming shifts from ${_getAgencyDisplayName(_currentFilter.agencyId)}. Check with your agency or browse available shifts.';
    } else if (_currentFilter.status == ShiftStatusFilter.pending) {
      return 'All your shifts are confirmed! No pending confirmations at this time.';
    } else {
      return 'You don\'t have any scheduled shifts coming up. Create your own shift or browse available agency shifts.';
    }
  }

  // Action handlers
  void _showCreateShiftDialog(BuildContext context) {
    // TODO: Implement shift creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create shift dialog - Coming soon')),
    );
  }

  void _navigateToAvailableShifts(BuildContext context) {
    // TODO: Navigate to available shifts screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Available shifts screen - Coming soon')),
    );
  }

  void _showShiftDetails(dynamic shift) {
    // TODO: Navigate to shift details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shift details for ${shift.id} - Coming soon')),
    );
  }

  void _confirmShift(dynamic shift) {
    // TODO: Implement shift confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Confirming shift ${shift.id} - Coming soon')),
    );
  }
}
