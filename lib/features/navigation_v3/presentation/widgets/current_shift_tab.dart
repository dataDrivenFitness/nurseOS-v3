// lib/features/navigation_v3/presentation/widgets/current_shift_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/text_styles.dart';
import 'package:nurseos_v3/shared/widgets/app_snackbar.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/shared/widgets/buttons/secondary_button.dart';
import 'package:nurseos_v3/features/work_history/state/work_history_controller.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/profile/service/duty_status_service.dart';

class CurrentShiftTab extends ConsumerStatefulWidget {
  const CurrentShiftTab({super.key});

  @override
  ConsumerState<CurrentShiftTab> createState() => _CurrentShiftTabState();
}

class _CurrentShiftTabState extends ConsumerState<CurrentShiftTab>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 2 tabs: Patients | Tasks
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkSession = ref.watch(currentWorkSessionStreamProvider);

    return currentWorkSession.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(context, error.toString(), ref),
      data: (workSession) {
        if (workSession == null) {
          // Not clocked in - show clock in interface
          return _buildClockInInterface(context, ref);
        } else {
          // Clocked in - show 2-tab patient/task interface
          return _buildClockedInInterface(context, workSession, ref);
        }
      },
    );
  }

  /// Clock In Interface - Shown when nurse is off duty
  Widget _buildClockInInterface(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;
    final user = ref.watch(authControllerProvider).value;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(currentWorkSessionStreamProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          children: [
            const SizedBox(height: SpacingTokens.xl),

            // Clock In Card
            FormCard(
              child: Column(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 64,
                    color: colors.brandPrimary,
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Text(
                    'Ready to Start Your Shift?',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'Clock in to access your patient list and start managing care tasks.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.subdued,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.xl),

                  // Clock In Button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Clock In',
                      onPressed: () => _handleClockIn(context, ref),
                      icon: const Icon(Icons.play_circle, size: 20),
                    ),
                  ),

                  // Independent nurse options
                  if (user?.isIndependentNurse == true) ...[
                    const SizedBox(height: SpacingTokens.md),
                    SizedBox(
                      width: double.infinity,
                      child: SecondaryButton(
                        label: 'Create Shift First',
                        onPressed: () => _showCreateShiftDialog(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Quick Info Card
            const SizedBox(height: SpacingTokens.lg),
            FormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colors.brandPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      Text(
                        'After Clock In',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  _buildQuickInfoItem(
                    context,
                    icon: Icons.people,
                    title: 'Patient List',
                    subtitle: 'View and manage your assigned patients',
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  _buildQuickInfoItem(
                    context,
                    icon: Icons.assignment,
                    title: 'Tasks & Care Plans',
                    subtitle: 'Complete tasks and earn progress rewards',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Clocked In Interface - 2-tab system (Patients | Tasks)
  Widget _buildClockedInInterface(
      BuildContext context, dynamic workSession, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    return Column(
      children: [
        // Active Shift Header
        Container(
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
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'On Duty',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      workSession.timeRange,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.subdued,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                workSession.formattedDuration,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              IconButton(
                onPressed: () => _handleClockOut(context, workSession, ref),
                icon: Icon(
                  Icons.logout,
                  color: colors.danger,
                ),
                tooltip: 'Clock Out',
              ),
            ],
          ),
        ),

        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              bottom: BorderSide(
                color: colors.subdued.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: colors.brandPrimary,
            unselectedLabelColor: colors.subdued,
            indicatorColor: colors.brandPrimary,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.people, size: 20),
                text: 'Patients',
              ),
              Tab(
                icon: Icon(Icons.assignment, size: 20),
                text: 'Tasks',
              ),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPatientListTab(context, workSession, ref),
              _buildTasksTab(context, workSession, ref),
            ],
          ),
        ),
      ],
    );
  }

  /// Patient List Tab - Shows patients from current shift
  Widget _buildPatientListTab(
      BuildContext context, dynamic workSession, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    // TODO: Replace with actual patient provider that queries from current shift
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh patient list from current shift
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          children: [
            // Patient list will be implemented here
            // This should query patients from scheduledShift.assignedPatientIds
            FormCard(
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: colors.subdued,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'Patient List Implementation',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'This will show the real patient list from your current shift assignments.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.subdued,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.lg),
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
                          'Next Implementation:',
                          style: textTheme.labelLarge?.copyWith(
                            color: colors.brandPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          '• Query patients from scheduledShift.assignedPatientIds\n• Display patient cards with tap navigation\n• Connect to existing patient detail screens',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.brandPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tasks Tab - Task management with gamification
  Widget _buildTasksTab(
      BuildContext context, dynamic workSession, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh tasks and gamification data
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          children: [
            // Tasks and gamification will be implemented here
            FormCard(
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 48,
                    color: colors.subdued,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'Tasks & Gamification',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'Task management system with XP rewards and progress tracking.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.subdued,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Container(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    decoration: BoxDecoration(
                      color: colors.brandAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coming Features:',
                          style: textTheme.labelLarge?.copyWith(
                            color: colors.brandAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          '• Task list with patient context\n• XP rewards for completed tasks\n• Progress tracking and badges\n• Care plan management',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.brandAccent,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colors.brandPrimary,
        ),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.subdued,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(SpacingTokens.xl),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    return Center(
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
              'Error Loading Shift Status',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.text,
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
                ref.invalidate(currentWorkSessionStreamProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Action handlers
  void _handleClockIn(BuildContext context, WidgetRef ref) {
    final dutyService = ref.read(dutyStatusServiceProvider);
    final user = ref.read(authControllerProvider).value;

    if (user != null) {
      dutyService.startShift(context: context, user: user);
    }
  }

  void _handleClockOut(
      BuildContext context, dynamic workSession, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clock Out'),
        content: const Text(
            'Are you sure you want to clock out? Make sure you\'ve completed all your tasks.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performClockOut(context, ref, workSession);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Clock Out'),
          ),
        ],
      ),
    );
  }

  void _performClockOut(
      BuildContext context, WidgetRef ref, dynamic workSession) {
    final dutyService = ref.read(dutyStatusServiceProvider);
    dutyService.endShift(context: context, currentSession: workSession);
  }

  void _showCreateShiftDialog(BuildContext context) {
    AppSnackbar.info(context, 'Create shift dialog - Coming soon');
  }
}
