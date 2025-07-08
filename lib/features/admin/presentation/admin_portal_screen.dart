// lib/features/admin/presentation/admin_portal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/state/shift_request_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../schedule/shift_pool/state/shift_pool_provider.dart';
import '../../../test_utils/add_test_shifts.dart';

/// Temporary admin portal for testing shift request approvals
///
/// This screen simulates future admin functionality for:
/// - Viewing pending shift requests
/// - Approving/denying requests
/// - Managing emergency coverage
/// - Admin-only controls for testing
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
            // Header warning
            _buildTestModeWarning(context, colors),

            const SizedBox(height: SpacingTokens.lg),

            // Quick Actions
            _buildQuickActionsSection(context, colors),

            const SizedBox(height: SpacingTokens.xl),

            // Pending Requests
            _buildPendingRequestsSection(context, ref, colors),

            const SizedBox(height: SpacingTokens.xl),

            // System Controls
            _buildSystemControlsSection(context, colors),
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
            Icon(
              Icons.warning_amber,
              color: colors.warning,
              size: 24,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Development Testing Only',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.warning,
                    ),
                  ),
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

  Widget _buildQuickActionsSection(BuildContext context, AppColors colors) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
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
                () => _showCreateEmergencyDialog(context, colors),
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
                () => _showBatchApprovalDialog(context, colors),
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
    final theme = Theme.of(context);

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
              Icon(
                icon,
                size: 32,
                color: accentColor,
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.subdued,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingRequestsSection(
    BuildContext context,
    WidgetRef ref,
    AppColors colors,
  ) {
    final theme = Theme.of(context);
    final shifts = ref.watch(shiftPoolProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Shift Requests',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        shifts.when(
          data: (data) {
            // Filter shifts that have requests
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

  Widget _buildEmptyRequestsCard(BuildContext context, AppColors colors) {
    final theme = Theme.of(context);

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
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: colors.subdued,
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              'No Pending Requests',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              'All shift requests have been processed',
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

  Widget _buildPendingRequestCard(
    BuildContext context,
    WidgetRef ref,
    dynamic shift,
    AppColors colors,
  ) {
    final theme = Theme.of(context);
    final controller = ref.read(shiftRequestControllerProvider);

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
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${shift.location} Shift Request',
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
                    color: colors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PENDING',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: SpacingTokens.sm),

            // Mock request details
            Text(
              'Requested by: Nurse Demo User',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.subdued,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              'Time: ${shift.startTime.toString().split(' ')[1].substring(0, 5)} - ${shift.endTime.toString().split(' ')[1].substring(0, 5)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.subdued,
              ),
            ),

            const SizedBox(height: SpacingTokens.md),

            // Action buttons
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

  Widget _buildSystemControlsSection(BuildContext context, AppColors colors) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Controls',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Card(
          elevation: 2,
          color: colors.surfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              children: [
                _buildControlTile(
                  context, // Pass context
                  'Reset All Requests',
                  'Clear all test request states',
                  Icons.refresh,
                  colors.brandPrimary,
                  () => _showResetDialog(context, colors),
                ),
                Divider(color: colors.subdued.withOpacity(0.3)),
                _buildControlTile(
                  context, // Pass context
                  'Generate Sample Data',
                  'Add test shifts and requests',
                  Icons.data_usage,
                  colors.brandSecondary,
                  () => _showGenerateDataDialog(context, colors),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlTile(
    BuildContext context, // Add context parameter
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildErrorCard(BuildContext context, AppColors colors) {
    final theme = Theme.of(context);

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
            Icon(
              Icons.error_outline,
              size: 48,
              color: colors.danger,
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              'Unable to load requests',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog and action handlers
  void _showCreateEmergencyDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Emergency Coverage'),
        content: const Text(
          'This would create an urgent coverage request that appears in the Emergency Coverage section. In a real system, this would integrate with scheduling and notification systems.',
        ),
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
                  content:
                      const Text('Emergency coverage request created (demo)'),
                  backgroundColor: colors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showBatchApprovalDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batch Approve Requests'),
        content: const Text(
          'This would approve all pending shift requests at once. Are you sure you want to proceed?',
        ),
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
                  content: const Text('All requests approved (demo)'),
                  backgroundColor: colors.success,
                ),
              );
            },
            backgroundColor: colors.success,
          ),
        ],
      ),
    );
  }

  Future<void> _handleRequestAction(
    BuildContext context,
    WidgetRef ref,
    dynamic shift,
    String action, [
    String? nurseUid,
  ]) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isApproval = action == 'approve';

    // Get nurse UID from requestedBy if not provided
    final targetNurseUid = nurseUid ??
        (shift.requestedBy?.isNotEmpty == true
            ? shift.requestedBy!.first
            : 'mockUser');

    try {
      if (isApproval) {
        // Use the existing mock admin approval logic with the actual nurse UID
        await _approveShiftRequest(shift.id, targetNurseUid);
      } else {
        // Deny by removing from requestedBy array
        await _denyShiftRequest(shift.id, targetNurseUid);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApproval
                  ? 'Shift request approved and assigned to $targetNurseUid'
                  : 'Shift request denied for $targetNurseUid',
            ),
            backgroundColor: isApproval ? colors.success : colors.warning,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: colors.danger,
          ),
        );
      }
    }
  }

  /// Approve shift request using existing mock admin logic
  Future<void> _approveShiftRequest(
      String shiftId, String approvedNurseUid) async {
    final firestore = FirebaseFirestore.instance;
    final shiftRef = firestore.collection('shifts').doc(shiftId);

    await firestore.runTransaction((tx) async {
      final shiftDoc = await tx.get(shiftRef);
      if (!shiftDoc.exists) {
        throw Exception('Shift not found');
      }

      final currentData = shiftDoc.data()!;
      final requestedBy = List<String>.from(currentData['requestedBy'] ?? []);

      // Verify the nurse actually requested this shift
      if (!requestedBy.contains(approvedNurseUid)) {
        throw Exception('Nurse $approvedNurseUid did not request this shift');
      }

      // Update the shift with assignment (existing logic)
      tx.update(shiftRef, {
        'assignedTo': approvedNurseUid,
        'status': 'accepted',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': 'admin_mock_uid',
      });
    });
  }

  /// Deny shift request by removing from requestedBy
  Future<void> _denyShiftRequest(String shiftId, String nurseUid) async {
    final firestore = FirebaseFirestore.instance;
    final shiftRef = firestore.collection('shifts').doc(shiftId);

    await firestore.runTransaction((tx) async {
      final shiftDoc = await tx.get(shiftRef);
      if (!shiftDoc.exists) {
        throw Exception('Shift not found');
      }

      final currentData = shiftDoc.data()!;
      final requestedBy = List<String>.from(currentData['requestedBy'] ?? []);

      // Remove the nurse from requestedBy array
      requestedBy.remove(nurseUid);

      tx.update(shiftRef, {
        'requestedBy': requestedBy,
      });
    });
  }

  void _showResetDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Test Shifts'),
        content: const Text(
          'This will remove all test shifts from Firestore. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          SecondaryButton(
            label: 'Clear All',
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await TestShiftGenerator.clearTestShifts();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          '🧹 All test shifts cleared from Firestore'),
                      backgroundColor: colors.warning,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Failed to clear shifts: $e'),
                      backgroundColor: colors.danger,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showGenerateDataDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Generate Test Shifts'),
        content: const Text(
          'This will add sample shifts to Firestore for testing the scheduling system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            label: 'Generate',
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await TestShiftGenerator.addTestAvailableShifts();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          const Text('✅ Test shifts generated successfully!'),
                      backgroundColor: colors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Failed to generate shifts: $e'),
                      backgroundColor: colors.danger,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
