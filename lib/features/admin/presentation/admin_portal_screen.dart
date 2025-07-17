// 📁 lib/features/admin/presentation/admin_portal_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurseos_v3/features/admin/services/admin_shift_approval_service.dart';
import 'package:nurseos_v3/features/admin/user_switcher_dialog.dart';
import 'package:nurseos_v3/features/agency/state/agency_context_provider.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/state/shift_request_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../schedule/shift_pool/state/shift_pool_provider.dart';
import '../../../test_utils/add_test_shifts.dart';
import '../../../test_utils/migration_test_data.dart';

class AdminPortalScreen extends ConsumerWidget {
  const AdminPortalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Admin Portal'),
        backgroundColor: colors.surface,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: SpacingTokens.md),
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.sm,
              vertical: SpacingTokens.xs,
            ),
            decoration: BoxDecoration(
              color: colors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'TEST MODE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.warning,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTestModeWarning(context, colors),
            const SizedBox(height: SpacingTokens.lg),
            _buildQuickActionsSection(context, colors, ref),
            const SizedBox(height: SpacingTokens.xl),
            _buildPendingRequestsSection(context, ref, colors),
            const SizedBox(height: SpacingTokens.xl),
            _buildTestDataControlsSection(context, colors, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildTestModeWarning(BuildContext context, AppColors colors) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      color: colors.warning.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: colors.warning, size: 24),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Development Testing Only',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.warning,
                      )),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    'This admin portal is for testing and demonstration purposes. In production, this would be a separate web interface with proper authentication.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.subdued,
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

  Widget _buildQuickActionsSection(
      BuildContext context, AppColors colors, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                )),
        const SizedBox(height: SpacingTokens.md),
        _buildActionCard(
          context,
          'Switch Test User',
          'Change active user for testing permissions',
          Icons.swap_horiz,
          colors.brandSecondary,
          colors,
          () => _showUserSwitcherDialog(context, ref),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Create Emergency',
                'Add urgent coverage request',
                Icons.local_hospital,
                colors.danger,
                colors,
                () => _showCreateEmergencyDialog(context, colors, ref),
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: _buildActionCard(
                context,
                'Approve All',
                'Batch approve requests',
                Icons.check_circle,
                colors.success,
                colors,
                () => _showBatchApprovalDialog(context, colors, ref),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color accentColor,
    AppColors colors,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      color: colors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Column(
            children: [
              Icon(icon, size: 32, color: accentColor),
              const SizedBox(height: SpacingTokens.sm),
              Text(title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      )),
              const SizedBox(height: SpacingTokens.xs),
              Text(subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.subdued,
                      )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingRequestsSection(
      BuildContext context, WidgetRef ref, AppColors colors) {
    final shifts = ref.watch(shiftPoolProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pending Shift Requests',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                )),
        const SizedBox(height: SpacingTokens.md),
        shifts.when(
          data: (data) {
            final shiftsWithRequests = data
                .where((shift) =>
                    shift.requestedBy != null && shift.requestedBy!.isNotEmpty)
                .toList();
            return shiftsWithRequests.isEmpty
                ? _buildEmptyRequestsCard(context, colors)
                : Column(
                    children: shiftsWithRequests
                        .map((shift) => _buildPendingRequestCard(
                            context, ref, shift, colors))
                        .toList(),
                  );
          },
          loading: () => const Center(child: AppLoader()),
          error: (e, st) => _buildErrorCard(context, colors),
        ),
      ],
    );
  }

  Widget _buildPendingRequestCard(
    BuildContext context,
    WidgetRef ref,
    dynamic shift,
    AppColors colors,
  ) {
    return Card(
      elevation: 2,
      color: colors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('${shift.location} Shift Request',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          )),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.sm,
                    vertical: SpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('PENDING',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.warning,
                            fontWeight: FontWeight.bold,
                          )),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text('Requested by: ${shift.requestedBy?.length ?? 0} nurse(s)',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.subdued)),
            const SizedBox(height: SpacingTokens.md),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Deny',
                    onPressed: () => _handleRequestAction(
                      context,
                      ref,
                      shift,
                      'deny',
                    ),
                    icon: const Icon(Icons.close, size: 16),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: PrimaryButton(
                    label: 'Approve',
                    onPressed: () => _handleRequestAction(
                      context,
                      ref,
                      shift,
                      'approve',
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    backgroundColor: colors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRequestAction(
    BuildContext context,
    WidgetRef ref,
    dynamic shift,
    String action,
  ) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isApproval = action == 'approve';
    final targetNurseUid = shift.requestedBy?.first ?? 'mockUser';

    try {
      // ✅ FIX: Use the shift's actual agencyId instead of current admin context
      final shiftAgencyId = shift.agencyId;
      if (shiftAgencyId == null) throw Exception('Shift has no agency context');

      final service = AdminShiftApprovalService();

      if (isApproval) {
        await service.approveShift(
          agencyId: shiftAgencyId, // ✅ Use shift's agency, not admin context
          shiftId: shift.id,
          nurseUid: targetNurseUid,
        );
      } else {
        await service.denyShift(
          agencyId: shiftAgencyId, // ✅ Use shift's agency, not admin context
          shiftId: shift.id,
          nurseUid: targetNurseUid,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApproval
                  ? '✅ Shift request approved'
                  : '❌ Shift request denied',
            ),
            backgroundColor: isApproval ? colors.success : colors.warning,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: colors.danger,
          ),
        );
      }
    }
  }

  Widget _buildEmptyRequestsCard(BuildContext context, AppColors colors) {
    return Card(
      elevation: 2,
      color: colors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: colors.subdued),
            const SizedBox(height: SpacingTokens.md),
            Text('No Pending Requests',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    )),
            const SizedBox(height: SpacingTokens.xs),
            Text('All shift requests have been processed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.subdued,
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, AppColors colors) {
    return Card(
      elevation: 2,
      color: colors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.danger),
            const SizedBox(height: SpacingTokens.md),
            Text('Unable to load requests',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    )),
          ],
        ),
      ),
    );
  }

  void _showCreateEmergencyDialog(
      BuildContext context, AppColors colors, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Emergency Coverage'),
        content: const Text('This would create an urgent coverage request.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            label: 'Create',
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🚨 Emergency coverage request created'),
                  backgroundColor: colors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showBatchApprovalDialog(
      BuildContext context, AppColors colors, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batch Approve Requests'),
        content: const Text(
            'This would approve all pending shift requests at once.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            label: 'Approve All',
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ All requests approved (demo)'),
                  backgroundColor: colors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showUserSwitcherDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => const UserSwitcherDialog(),
    );
  }

  Widget _buildTestDataControlsSection(
      BuildContext context, AppColors colors, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Test Data Controls',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                )),
        const SizedBox(height: SpacingTokens.md),
        _buildControlTile(
          context,
          'Generate Test Data',
          'Create sample agencies, users, patients, and shifts',
          Icons.science,
          colors.brandPrimary,
          () => MigrationTestData.generateTestData(),
        ),
        _buildControlTile(
          context,
          'Clear Test Data',
          'Remove all mock data from Firestore',
          Icons.delete_sweep,
          colors.warning,
          () => MigrationTestData.clearTestData(),
        ),
        _buildControlTile(
          context,
          'Add Sample Shifts',
          'Add additional shift records to test',
          Icons.add_circle,
          colors.brandSecondary,
          () async {
            final agencyId = ref.read(currentAgencyIdProvider);
            await TestShiftGenerator.addTestAvailableShifts(agencyId);
          },
        ),
        _buildControlTile(
          context,
          'Reset All Requests',
          'Clear all shift requests and re-set state',
          Icons.refresh,
          colors.subdued,
          () => TestShiftGenerator.clearTestShifts(),
        ),
      ],
    );
  }

  Widget _buildControlTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    Future<void> Function() onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => onTap(),
    );
  }
}
