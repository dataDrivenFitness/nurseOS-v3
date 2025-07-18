// 📁 lib/features/navigation_v3/presentation/available_shifts_screen.dart
// FIXED: Universal pill display for ALL nurse types

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/state/shift_pool_provider.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/state/shift_request_controller.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model_extensions.dart';
import 'package:nurseos_v3/features/agency/state/agency_context_provider.dart';
import 'package:nurseos_v3/shared/widgets/app_snackbar.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
import 'package:nurseos_v3/shared/widgets/animated_extended_fab.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/shared/widgets/buttons/secondary_button.dart';

/// Available Shifts Screen - Enhanced with universal pill display
///
/// ✅ FIXED: Pill display now works for ALL nurse types
/// - Interactive count pills header (shows for everyone)
/// - 🚨 Emergency Coverage (Red) - Critical staffing needs
/// - 🆘 Coverage Requests (Orange) - Colleague help requests
/// - 📅 Open Shifts (Blue) - Regular available shifts
/// - Color-coded 8px sidebar pattern from patient cards
/// - Animated FAB for independent nurses ONLY
/// - Contextual empty states based on nurse type
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

    int newTabCount = 1;

    if (user.isIndependentNurse) {
      if (userAgencies.isEmpty) {
        newTabCount = 1;
      } else {
        newTabCount = 2;
      }
    } else {
      newTabCount = 1;
    }

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

  int _calculateTabCount(UserModel? user, List<String> agencies) {
    if (user?.isIndependentNurse == true) {
      if (agencies.isEmpty) {
        return 1;
      } else {
        return 2;
      }
    } else {
      return 1;
    }
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
        final tabCount = _calculateTabCount(user, agencies);

        return NurseScaffold(
          child: DefaultTabController(
            length: tabCount,
            child: Builder(
              builder: (context) {
                final tabController = DefaultTabController.of(context);

                return Scaffold(
                  backgroundColor: colors.background,
                  body: Column(
                    children: [
                      // ✅ FIXED: Universal pill header - shows for ALL nurses
                      _buildUniversalPillHeader(colors, user),

                      // Tab bar (conditional based on user type)
                      _buildConditionalTabBar(
                          colors, user, agencies, tabController),

                      // Tab content
                      Expanded(
                        child: _buildTabContent(user, agencies, tabController),
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

  /// ✅ FIXED: Universal pill header that shows for ALL nurse types
  Widget _buildUniversalPillHeader(AppColors colors, UserModel user) {
    // For independent-only nurses, check if they have agency access first
    final userAgenciesAsync = ref.watch(userAgenciesFromMembershipProvider);

    return userAgenciesAsync.when(
      loading: () => _buildCountPillsPlaceholder(colors),
      error: (_, __) => _buildCountPillsPlaceholder(colors),
      data: (agencies) {
        // If independent nurse with no agencies, show appropriate empty state
        if (user.isIndependentNurse && agencies.isEmpty) {
          return _buildIndependentOnlyPillHeader(colors);
        }

        // Otherwise, show agency shifts
        final agencyShiftsAsync = ref.watch(shiftPoolProvider);

        return agencyShiftsAsync.when(
          loading: () => _buildCountPillsPlaceholder(colors),
          error: (_, __) => _buildCountPillsPlaceholder(colors),
          data: (shifts) {
            final availableShifts = shifts
                .where((shift) =>
                    shift.status == 'available' &&
                    (shift.assignedTo == null || shift.assignedTo!.isEmpty))
                .toList();

            final emergencyCount =
                availableShifts.where((s) => s.isEmergencyShift).length;
            final coverageCount =
                availableShifts.where((s) => s.isCoverageRequest).length;
            final regularCount =
                availableShifts.where((s) => s.isRegularShift).length;

            return _buildCountPills(
                emergencyCount, coverageCount, regularCount, colors, user);
          },
        );
      },
    );
  }

  /// Build pill header specifically for independent-only nurses
  Widget _buildIndependentOnlyPillHeader(AppColors colors) {
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

  /// Build count pills with contextual messaging for all nurse types
  Widget _buildCountPills(int emergencyCount, int coverageCount,
      int regularCount, AppColors colors, UserModel user) {
    final pillsToShow = <Widget>[];

    if (emergencyCount > 0) {
      pillsToShow.add(
        _buildCountPill(
          '🚨 $emergencyCount Emergency',
          colors.danger,
          true,
          () => _scrollToSection(0),
        ),
      );
    }

    if (coverageCount > 0) {
      pillsToShow.add(
        _buildCountPill(
          '🆘 $coverageCount Coverage',
          colors.warning,
          true,
          () => _scrollToSection(1),
        ),
      );
    }

    if (regularCount > 0) {
      pillsToShow.add(
        _buildCountPill(
          '📅 $regularCount Open',
          colors.brandPrimary,
          true,
          () => _scrollToSection(2),
        ),
      );
    }

    // If no pills to show, show contextual empty state
    if (pillsToShow.isEmpty) {
      String message = 'No shifts available';

      if (user.isIndependentNurse) {
        final agencies =
            ref.read(userAgenciesFromMembershipProvider).value ?? [];
        message = agencies.isEmpty
            ? 'No agency shifts • Create your own shifts below'
            : 'No agency shifts available • Check back later';
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

  Widget _buildPillSlot(Widget? pill) {
    return Expanded(
      child: pill ?? const SizedBox.shrink(),
    );
  }

  Widget _buildCountPill(
      String text, Color color, bool hasShifts, VoidCallback onTap) {
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

  Widget _buildCountPillsPlaceholder(AppColors colors) {
    final pillsToShow = <Widget>[
      _buildCountPill(
          '🚨 - Emergency', colors.danger.withOpacity(0.5), false, () {}),
      _buildCountPill(
          '🆘 - Coverage', colors.warning.withOpacity(0.5), false, () {}),
      _buildCountPill(
          '📅 - Open', colors.brandPrimary.withOpacity(0.5), false, () {}),
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

  Widget _buildConditionalTabBar(AppColors colors, UserModel user,
      List<String> agencies, TabController tabController) {
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

    return const SizedBox.shrink();
  }

  Widget _buildTabContent(
      UserModel user, List<String> agencies, TabController tabController) {
    if (user.isIndependentNurse) {
      if (agencies.isEmpty) {
        return _buildIndependentShiftsTab(user);
      } else {
        return TabBarView(
          controller: tabController,
          children: [
            _buildAgencyShiftsTab(user),
            _buildIndependentShiftsTab(user),
          ],
        );
      }
    } else {
      return _buildAgencyShiftsTab(user);
    }
  }

  Widget _buildAgencyShiftsTab(UserModel user) {
    final userAgenciesAsync = ref.watch(userAgenciesFromMembershipProvider);

    return userAgenciesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(
        icon: Icons.error_outline,
        title: 'Unable to Load Agencies',
        subtitle: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(userAgenciesFromMembershipProvider),
      ),
      data: (agencyIds) {
        if (agencyIds.isEmpty) {
          return _buildNoAgencyAccessState(user);
        }
        return _buildAgencyShiftsList(user);
      },
    );
  }

  Widget _buildNoAgencyAccessState(UserModel user) {
    if (user.isIndependentNurse) {
      return _buildEmptyState(
        icon: Icons.business_center,
        title: 'No Agency Partnerships',
        subtitle:
            'You\'re set up for independent practice.\nUse the "My Shifts" tab to create your own shifts.',
        actionLabel: 'Create My First Shift',
        onAction: () => _navigateToCreateShift(),
      );
    } else {
      return _buildEmptyState(
        icon: Icons.warning_amber,
        title: 'No Agency Access',
        subtitle: 'Contact your administrator to be assigned to an agency.',
      );
    }
  }

  Widget _buildAgencyShiftsList(UserModel user) {
    final agencyShiftsAsync = ref.watch(shiftPoolProvider);

    return agencyShiftsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(
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
          return _buildEmptyState(
            icon: Icons.work_off,
            title: 'No Available Shifts',
            subtitle:
                'Check back later for new opportunities\nfrom your affiliated agencies.',
          );
        }

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
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (emergencyShifts.isNotEmpty) ...[
                  _buildSectionHeader(
                    '🚨 Emergency Coverage',
                    'Critical staffing needs requiring immediate response',
                    emergencyShifts.length,
                    Colors.red,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  ...emergencyShifts.map((shift) => _buildEnhancedShiftCard(
                      shift, user, _ShiftCardType.emergency)),
                  const SizedBox(height: SpacingTokens.xl),
                ],
                if (coverageShifts.isNotEmpty) ...[
                  _buildSectionHeader(
                    '🆘 Coverage Requests',
                    'Colleagues need help with their scheduled shifts',
                    coverageShifts.length,
                    Colors.orange,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  ...coverageShifts.map((shift) => _buildEnhancedShiftCard(
                      shift, user, _ShiftCardType.coverage)),
                  const SizedBox(height: SpacingTokens.xl),
                ],
                if (regularShifts.isNotEmpty) ...[
                  _buildSectionHeader(
                    '📅 Open Shifts',
                    'Available shifts for pickup',
                    regularShifts.length,
                    Colors.blue,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  ...regularShifts.map((shift) => _buildEnhancedShiftCard(
                      shift, user, _ShiftCardType.regular)),
                ],
                const SizedBox(height: SpacingTokens.xxl * 2),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndependentShiftsTab(UserModel user) {
    return _buildUserCreatedShifts(user);
  }

  Widget _buildUserCreatedShifts(UserModel user) {
    return _buildEmptyState(
      icon: Icons.add_business,
      title: 'No Personal Shifts',
      subtitle:
          'Create your first shift to start\nmanaging your independent practice.',
      actionLabel: 'Create Shift',
      onAction: () => _navigateToCreateShift(),
    );
  }

  Widget _buildSectionHeader(
      String title, String subtitle, int count, Color accentColor) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.sm,
                  vertical: SpacingTokens.xs,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
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

  Widget _buildEnhancedShiftCard(
      ShiftModel shift, UserModel user, _ShiftCardType type) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final controller = ref.read(shiftRequestControllerProvider);
    final hasRequested = shift.hasRequestedBy(user.uid);

    Color sidebarColor;
    Color accentColor;
    switch (type) {
      case _ShiftCardType.emergency:
        sidebarColor = colors.danger;
        accentColor = colors.danger;
        break;
      case _ShiftCardType.coverage:
        sidebarColor = colors.warning;
        accentColor = colors.warning;
        break;
      case _ShiftCardType.regular:
        sidebarColor = colors.brandPrimary;
        accentColor = colors.brandPrimary;
        break;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: SpacingTokens.md),
      color: colors.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showShiftDetails(shift),
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 8,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: sidebarColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          _buildStatusChip(
                              hasRequested, shift, accentColor, colors),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      _buildShiftDateTimeInfo(shift, colors),
                      const SizedBox(height: SpacingTokens.sm),
                      _buildShiftDetails(shift, colors),
                      if (shift.coverageContextMessage != null ||
                          shift.specialRequirements != null) ...[
                        const SizedBox(height: SpacingTokens.sm),
                        _buildSpecialInfo(shift, type, accentColor),
                      ],
                      const SizedBox(height: SpacingTokens.md),
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
                                onPressed: () =>
                                    _requestShift(shift, controller, user),
                                icon: Icon(
                                  type == _ShiftCardType.emergency
                                      ? Icons.local_hospital
                                      : type == _ShiftCardType.coverage
                                          ? Icons.people_alt
                                          : Icons.add,
                                  size: 18,
                                ),
                                backgroundColor: type != _ShiftCardType.regular
                                    ? accentColor
                                    : null,
                              ),
                      ),
                      if (shift.createdAt != null) ...[
                        const SizedBox(height: SpacingTokens.sm),
                        Text(
                          'Posted ${_formatPostedTime(shift.createdAt!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.subdued,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool hasRequested, ShiftModel shift,
      Color accentColor, AppColors colors) {
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

    if (shift.isEmergencyShift) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: colors.danger,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'URGENT',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      );
    }

    if (shift.isCoverageRequest) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: colors.warning,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'COVERAGE',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Available',
        style: theme.textTheme.bodySmall?.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildShiftDateTimeInfo(ShiftModel shift, AppColors colors) {
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

  Widget _buildShiftDetails(ShiftModel shift, AppColors colors) {
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

  Widget _buildSpecialInfo(
      ShiftModel shift, _ShiftCardType type, Color accentColor) {
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

  // ACTION HANDLERS

  Future<void> _requestShift(
    ShiftModel shift,
    ShiftRequestController controller,
    UserModel user,
  ) async {
    final scaffoldContext = context;

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
          'Failed to send request: ${_getErrorMessage(e)}',
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _requestShift(shift, controller, user),
          ),
        );
      }
    }
  }

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

  void _scrollToSection(int sectionIndex) {
    final sectionNames = ['Emergency', 'Coverage', 'Open Shifts'];
    if (sectionIndex < sectionNames.length) {
      AppSnackbar.info(
          context, 'Scrolling to ${sectionNames[sectionIndex]} section');
    }
  }

  // NAVIGATION HANDLERS

  void _navigateToCreateShift() {
    AppSnackbar.info(context, 'Opening Create Shift screen...');
  }

  void _showShiftDetails(ShiftModel shift) {
    AppSnackbar.info(context, 'Showing details for ${shift.id}');
  }

  // FORMATTING HELPERS

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

  String _formatPostedTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      final days = difference.inDays;
      return '$days day${days != 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      return '$hours hour${hours != 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes != 1 ? 's' : ''} ago';
    } else {
      return 'Just posted';
    }
  }
}

/// Enum for shift card types to determine styling
enum _ShiftCardType { emergency, coverage, regular }
