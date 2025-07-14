// 📁 lib/features/navigation_v3/presentation/available_shifts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model_extensions.dart';
import 'package:nurseos_v3/features/schedule/widgets/scheduled_shift_card.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';

/// Available Shifts Screen - First tab of new navigation system
///
/// Displays shifts available for nurses to request or create:
/// - Agency nurses: Available shifts from affiliated agencies
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

  /// Tab 1: Agency Shifts - Available shifts from affiliated agencies
  Widget _buildAgencyShiftsTab(dynamic user) {
    // TODO: Replace with actual agency shifts provider
    return _buildMockAgencyShifts();
  }

  /// Tab 2: Independent/Create Shifts - User-created shifts or creation interface
  Widget _buildIndependentShiftsTab(dynamic user) {
    if (user.isIndependentNurse) {
      // Show user's created shifts for independent nurses
      return _buildUserCreatedShifts(user);
    } else {
      // Show shift creation interface for agency-only nurses
      return _buildShiftCreationInterface();
    }
  }

  /// Mock agency shifts (temporary until real provider is ready)
  Widget _buildMockAgencyShifts() {
    final mockAgencyShifts = _generateMockAgencyShifts();

    if (mockAgencyShifts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.work_off,
        title: 'No Available Shifts',
        subtitle:
            'Check back later for new opportunities\nfrom your affiliated agencies.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh agency shifts
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
        itemCount: mockAgencyShifts.length,
        itemBuilder: (context, index) {
          final shift = mockAgencyShifts[index];
          return ScheduledShiftCard(
            shift: shift,
            onTap: () => _showShiftDetails(shift),
            onConfirm:
                shift.needsConfirmation ? () => _requestShift(shift) : null,
          );
        },
      ),
    );
  }

  /// User-created shifts for independent nurses
  Widget _buildUserCreatedShifts(dynamic user) {
    final mockUserShifts = _generateMockUserShifts(user.uid);

    if (mockUserShifts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.add_business,
        title: 'No Personal Shifts',
        subtitle:
            'Create your first shift to start\nmanaging your independent practice.',
        actionLabel: 'Create Shift',
        onAction: () => _showCreateShiftDialog(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh user shifts
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
        itemCount: mockUserShifts.length,
        itemBuilder: (context, index) {
          final shift = mockUserShifts[index];
          return ScheduledShiftCard(
            shift: shift,
            onTap: () => _showShiftDetails(shift),
            onConfirm: shift.isEditableByNurse ? () => _editShift(shift) : null,
          );
        },
      ),
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

  /// Floating action button for shift creation
  Widget? _buildFloatingActionButton(dynamic user, AppColors colors) {
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

  /// Generate mock agency shifts for demo
  List<ScheduledShiftModel> _generateMockAgencyShifts() {
    final now = DateTime.now();
    return [
      ScheduledShiftModel(
        id: 'agency_shift_1',
        agencyId: 'metro_hospital',
        assignedTo: '', // Not assigned yet
        status: 'available',
        isConfirmed: false,
        startTime: now.add(const Duration(days: 1, hours: 8)),
        endTime: now.add(const Duration(days: 1, hours: 16)),
        locationType: 'facility',
        facilityName: 'Metro General Hospital',
        address: '123 Medical Center Dr, Healthcare City, CA',
        assignedPatientIds: ['patient_1', 'patient_2', 'patient_3'],
        isUserCreated: false,
        createdBy: 'admin_metro',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      ScheduledShiftModel(
        id: 'agency_shift_2',
        agencyId: 'sunrise_care',
        assignedTo: '',
        status: 'available',
        isConfirmed: false,
        startTime: now.add(const Duration(days: 2, hours: 7)),
        endTime: now.add(const Duration(days: 2, hours: 19)),
        locationType: 'residence',
        facilityName: null,
        address: '456 Oak Street, Hometown, CA',
        assignedPatientIds: ['patient_4'],
        isUserCreated: false,
        createdBy: 'admin_sunrise',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Generate mock user-created shifts
  List<ScheduledShiftModel> _generateMockUserShifts(String userId) {
    final now = DateTime.now();
    return [
      ScheduledShiftModel(
        id: 'user_shift_1',
        agencyId: null, // Independent shift
        assignedTo: userId,
        status: 'scheduled',
        isConfirmed: true,
        startTime: now.add(const Duration(days: 3, hours: 9)),
        endTime: now.add(const Duration(days: 3, hours: 17)),
        locationType: 'residence',
        facilityName: null,
        address: '789 Elm Street, Independent Care, CA',
        assignedPatientIds: ['patient_5', 'patient_6'],
        isUserCreated: true,
        createdBy: userId,
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }

  /// Action handlers (TODO: Implement actual functionality)
  void _showShiftDetails(ScheduledShiftModel shift) {
    // TODO: Navigate to shift details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Showing details for ${shift.id}')),
    );
  }

  void _requestShift(ScheduledShiftModel shift) {
    // TODO: Implement shift request functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shift request submitted!')),
    );
  }

  void _editShift(ScheduledShiftModel shift) {
    // TODO: Navigate to edit shift screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing shift ${shift.id}')),
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
}
