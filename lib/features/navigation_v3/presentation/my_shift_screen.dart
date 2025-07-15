// lib/features/navigation_v3/presentation/my_shift_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/text_styles.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/widgets/current_shift_tab.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/work_history/state/work_history_controller.dart';
import 'package:nurseos_v3/features/schedule/state/upcoming_shifts_provider.dart';
import 'package:nurseos_v3/features/schedule/widgets/scheduled_shift_card.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model_extensions.dart';
import 'package:nurseos_v3/features/profile/service/duty_status_service.dart';

/// My Shift Screen - Shows clock-in interface and patient/task management
///
/// Architecture:
/// - Off Duty: Shows approved shifts with clock-in options
/// - On Duty: 2-tab system (Patients | Tasks) within CurrentShiftTab
class MyShiftScreen extends ConsumerWidget {
  const MyShiftScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);

    // Check duty status using existing providers
    final user = ref.watch(authControllerProvider).value;
    final currentSession = ref.watch(currentWorkSessionStreamProvider).value;
    final isOnDuty = currentSession != null;

    if (user == null) {
      return NurseScaffold(
        child: Scaffold(
          backgroundColor: colors.background,
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return NurseScaffold(
      child: Scaffold(
        backgroundColor: colors.background,
        body: isOnDuty
            ? const CurrentShiftTab() // Existing on-duty interface
            : _buildApprovedShiftsList(context, ref, user.uid, colors,
                theme), // Show approved shifts when off duty
      ),
    );
  }

  /// Show approved shifts when nurse is off duty
  Widget _buildApprovedShiftsList(BuildContext context, WidgetRef ref,
      String userId, AppColors colors, ThemeData theme) {
    final upcomingShiftsAsync = ref.watch(upcomingShiftsProvider(userId));

    return upcomingShiftsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: SpacingTokens.md),
              Text('Error Loading Shifts', style: theme.textTheme.titleMedium),
              const SizedBox(height: SpacingTokens.lg),
              ElevatedButton(
                onPressed: () => ref.invalidate(upcomingShiftsProvider(userId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (shifts) {
        if (kDebugMode) {
          print('🔍 Debug: Found ${shifts.length} shifts from provider');
          for (final shift in shifts) {
            print(
                '  - Shift ${shift.id}: status="${shift.status}", isConfirmed=${shift.isConfirmed}');
          }
        }

        // Show ALL shifts from provider (provider already filters for accepted)
        // Or show shifts that are confirmed, regardless of status
        final approvedShifts = shifts
            .where((shift) =>
                shift.isConfirmed || shift.status.toLowerCase() == 'accepted')
            .toList();

        if (kDebugMode) {
          print(
              '🔍 Debug: ${approvedShifts.length} approved shifts after filtering');
        }

        if (approvedShifts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 64, color: colors.subdued),
                  const SizedBox(height: SpacingTokens.lg),
                  Text('No Approved Shifts', style: theme.textTheme.titleLarge),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'You don\'t have any approved shifts. Contact your supervisor for assignments.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colors.subdued),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  ElevatedButton(
                    onPressed: () {
                      if (kDebugMode) {
                        print('🔍 Debug: Creating test shift data');
                      }
                      // For debugging - show what shifts we have
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Found ${shifts.length} total shifts, ${approvedShifts.length} approved')),
                      );
                    },
                    child: const Text('Debug: Show Shift Data'),
                  ),
                ],
              ),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: Text(
                  'Ready to Start Your Shift?',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final shift = approvedShifts[index];
                  return ScheduledShiftCard(
                    shift: shift,
                    onClockIn: () => _handleClockIn(context, ref, shift),
                  );
                },
                childCount: approvedShifts.length,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Handle clock-in to specific shift
  void _handleClockIn(BuildContext context, WidgetRef ref, shift) async {
    final dutyService = ref.read(dutyStatusServiceProvider);
    final user = ref.read(authControllerProvider).value;

    if (user == null) return;

    // Simple confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clock In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Clock in to ${shift.facilityName ?? shift.address ?? 'this shift'}?'),
            const SizedBox(height: 8),
            const Text(
              'Note: Location capture may take a moment.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clock In'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await dutyService.startShift(context: context, user: user);
      } catch (e) {
        debugPrint('Clock-in failed: $e');
      }
    }
  }
}
