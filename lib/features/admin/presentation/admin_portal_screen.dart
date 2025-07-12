// lib/features/admin/presentation/admin_portal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurseos_v3/features/agency/state/agency_context_provider.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/state/shift_request_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../schedule/shift_pool/state/shift_pool_provider.dart';
import '../../../test_utils/add_test_shifts.dart';
import '../../agency/services/agency_migration_service.dart';
import '../../../test_utils/migration_test_data.dart';

/// Admin portal with multi-agency migration capabilities
///
/// This screen provides admin functionality for:
/// - Multi-agency data migration
/// - Viewing pending shift requests
/// - Approving/denying requests
/// - Managing emergency coverage
/// - Admin-only controls for testing
class AdminPortalScreen extends ConsumerStatefulWidget {
  const AdminPortalScreen({super.key});

  @override
  ConsumerState<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends ConsumerState<AdminPortalScreen> {
  bool _isMigrationRunning = false;
  bool _isMigrationComplete = false;
  MigrationResult? _migrationResult;
  final _migrationService = AgencyMigrationService();

  @override
  void initState() {
    super.initState();
    _checkMigrationStatus();
  }

  Future<void> _checkMigrationStatus() async {
    final isComplete = await _migrationService.isMigrationComplete();
    if (mounted) {
      setState(() {
        _isMigrationComplete = isComplete;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

        // Migration Status Card
        _buildMigrationCard(context, colors),
        const SizedBox(height: SpacingTokens.md),

        // Test Data Controls Card (only show if migration not complete)
        if (!_isMigrationComplete) ...[
          _buildTestDataCard(context, colors),
          const SizedBox(height: SpacingTokens.md),
        ],

        // Existing System Controls Card
        _buildSystemControlsCard(context, colors),
      ],
    );
  }

  Widget _buildMigrationCard(BuildContext context, AppColors colors) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      color: _isMigrationComplete
          ? colors.success.withOpacity(0.1)
          : colors.warning.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _isMigrationComplete
              ? colors.success.withOpacity(0.3)
              : colors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _isMigrationComplete
                      ? Icons.check_circle
                      : Icons.warning_amber,
                  color: _isMigrationComplete ? colors.success : colors.warning,
                  size: 24,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    'Multi-Agency Migration',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _isMigrationComplete
                          ? colors.success
                          : colors.warning,
                    ),
                  ),
                ),
                if (_isMigrationComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.sm,
                      vertical: SpacingTokens.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'COMPLETE',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.success,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: SpacingTokens.sm),

            // Status description
            Text(
              _isMigrationComplete
                  ? 'Your data has been successfully migrated to the multi-agency structure.'
                  : 'Migrate existing data to support multiple agencies and improve data isolation.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.subdued,
              ),
            ),

            // Migration results (if available)
            if (_migrationResult != null) ...[
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Last migration: ${_migrationResult!.usersProcessed} users, '
                '${_migrationResult!.patientsProcessed} patients, '
                '${_migrationResult!.shiftsProcessed} shifts processed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.subdued,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // Progress indicator (if running)
            if (_isMigrationRunning) ...[
              const SizedBox(height: SpacingTokens.md),
              const LinearProgressIndicator(),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Migration in progress... This may take several minutes.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.subdued,
                ),
              ),
            ],

            const SizedBox(height: SpacingTokens.md),

            // Action buttons
            Row(
              children: [
                if (!_isMigrationComplete && !_isMigrationRunning) ...[
                  Expanded(
                    child: PrimaryButton(
                      label: 'Run Migration',
                      onPressed: () => _runMigration(context, colors),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      backgroundColor: colors.warning,
                    ),
                  ),
                ] else if (_isMigrationComplete) ...[
                  Expanded(
                    child: SecondaryButton(
                      label: 'View Details',
                      onPressed: () => _showMigrationDetails(context, colors),
                      icon: const Icon(Icons.info, size: 16),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: SecondaryButton(
                      label: 'Rollback',
                      onPressed: () => _showRollbackDialog(context, colors),
                      icon: const Icon(Icons.undo, size: 16),
                    ),
                  ),
                ],
                if (_isMigrationRunning)
                  Expanded(
                    child: SecondaryButton(
                      label: 'Running...',
                      onPressed: null,
                      icon: const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestDataCard(BuildContext context, AppColors colors) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      color: colors.brandPrimary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.brandPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.science,
                  color: colors.brandPrimary,
                  size: 24,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  'Migration Testing',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.brandPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Generate sample data to test the migration process safely.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.subdued,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Column(
              children: [
                _buildControlTile(
                  context,
                  'Generate Test Data',
                  'Create sample users, patients, and shifts',
                  Icons.add_circle,
                  colors.brandPrimary,
                  () => _generateTestData(context, colors),
                ),
                Divider(color: colors.subdued.withOpacity(0.3)),
                _buildControlTile(
                  context,
                  'Clear Test Data',
                  'Remove all test migration data',
                  Icons.delete_sweep,
                  colors.warning,
                  () => _clearTestData(context, colors),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemControlsCard(BuildContext context, AppColors colors) {
    return Card(
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
              context,
              'Reset All Requests',
              'Clear all test request states',
              Icons.refresh,
              colors.brandPrimary,
              () => _showResetDialog(context, colors),
            ),
            Divider(color: colors.subdued.withOpacity(0.3)),
            _buildControlTile(
              context,
              'Generate Sample Data',
              'Add test shifts and requests',
              Icons.data_usage,
              colors.brandSecondary,
              () => _showGenerateDataDialog(context, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlTile(
    BuildContext context,
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

  // Migration Methods
  Future<void> _runMigration(BuildContext context, AppColors colors) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Run Multi-Agency Migration'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will:'),
            SizedBox(height: 8),
            Text('• Create a default agency for existing data'),
            Text('• Add agency context to all users'),
            Text('• Move patients to agency collections'),
            Text('• Move shifts to agency collections'),
            SizedBox(height: 16),
            Text(
              'Original data will be preserved for safety. This operation may take several minutes.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            label: 'Run Migration',
            onPressed: () => Navigator.pop(dialogContext, true),
            backgroundColor: colors.warning,
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isMigrationRunning = true;
      _migrationResult = null;
    });

    try {
      final result = await _migrationService.runFullMigration();

      if (mounted) {
        setState(() {
          _isMigrationRunning = false;
          _isMigrationComplete = result.success;
          _migrationResult = result;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? '✅ Migration completed successfully!'
                  : '⚠️ Migration completed with ${result.errors.length} errors',
            ),
            backgroundColor: result.success ? colors.success : colors.warning,
            duration: const Duration(seconds: 5),
          ),
        );

        if (result.success) {
          _showMigrationDetails(context, colors);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMigrationRunning = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Migration failed: $e'),
            backgroundColor: colors.danger,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showMigrationDetails(BuildContext context, AppColors colors) {
    if (_migrationResult == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Migration Results'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✅ Users processed: ${_migrationResult!.usersProcessed}'),
              Text(
                  '✅ Patients migrated: ${_migrationResult!.patientsProcessed}'),
              Text('✅ Shifts migrated: ${_migrationResult!.shiftsProcessed}'),
              Text(
                  '✅ Scheduled shifts migrated: ${_migrationResult!.scheduledShiftsProcessed}'),
              if (_migrationResult!.errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Errors:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._migrationResult!.errors.map((error) => Text('• $error')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRollbackDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rollback Migration'),
        content: const Text(
          'This will remove all migrated agency data but keep your original data intact. '
          'Are you sure you want to rollback the migration?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          SecondaryButton(
            label: 'Rollback',
            onPressed: () async {
              Navigator.pop(dialogContext);

              setState(() {
                _isMigrationRunning = true;
              });

              try {
                await _migrationService.rollbackMigration();

                if (mounted) {
                  setState(() {
                    _isMigrationRunning = false;
                    _isMigrationComplete = false;
                    _migrationResult = null;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('✅ Migration rollback completed'),
                      backgroundColor: colors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isMigrationRunning = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Rollback failed: $e'),
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

  // Test Data Methods
  Future<void> _generateTestData(BuildContext context, AppColors colors) async {
    final agencyId = ref.read(currentAgencyIdProvider);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Generate Test Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will create sample users, patients, and shifts to test the migration process. Continue?',
            ),
            const SizedBox(height: 12),
            if (agencyId != null)
              Text(
                'Target Agency: $agencyId',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              const Text(
                'Warning: No agency selected. Using default_agency.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            label: 'Generate',
            onPressed: () => Navigator.pop(dialogContext, true),
            backgroundColor: colors.brandPrimary,
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await MigrationTestData.generateTestData(agencyId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Test data generated for ${agencyId ?? 'default_agency'}!',
            ),
            backgroundColor: colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to generate test data: $e'),
            backgroundColor: colors.danger,
          ),
        );
      }
    }
  }

  Future<void> _clearTestData(BuildContext context, AppColors colors) async {
    final agencyId = ref.read(currentAgencyIdProvider);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Test Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will remove all test migration data. Continue?'),
            const SizedBox(height: 12),
            if (agencyId != null)
              Text(
                'Target Agency: $agencyId',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              const Text(
                'Warning: No agency selected. Using default_agency.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          SecondaryButton(
            label: 'Clear',
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await MigrationTestData.clearTestData(agencyId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🧹 Test data cleared from ${agencyId ?? 'default_agency'}!',
            ),
            backgroundColor: colors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to clear test data: $e'),
            backgroundColor: colors.danger,
          ),
        );
      }
    }
  }

  // Dialog and action handlers (existing methods)
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

  /// Approve shift request and create scheduled shift
  Future<void> _approveShiftRequest(
      String shiftId, String approvedNurseUid) async {
    final firestore = FirebaseFirestore.instance;

    // Get current agency context
    final agencyId = ref.read(currentAgencyIdProvider);
    if (agencyId == null) {
      throw Exception('No agency context available');
    }

    final shiftRef = firestore
        .collection('agencies')
        .doc(agencyId)
        .collection('shifts')
        .doc(shiftId);

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

      debugPrint('🔍 Approving shift $shiftId for nurse $approvedNurseUid');
      debugPrint('   Original shift data keys: ${currentData.keys.toList()}');

      // Update the shift to assigned status
      tx.update(shiftRef, {
        'assignedTo': approvedNurseUid,
        'status': 'assigned',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': 'admin_mock_uid',
      });

      // 🔧 FIXED: Get patients from the original shift OR find facility patients
      List<String> assignedPatientIds = [];

      // Option 1: If the shift already has assigned patients, use those
      if (currentData['assignedPatientIds'] != null) {
        assignedPatientIds =
            List<String>.from(currentData['assignedPatientIds']);
        debugPrint(
            '✅ Using pre-assigned patients from shift: $assignedPatientIds');
      } else {
        // Option 2: For facility shifts, find and assign patients dynamically
        final locationType = _inferLocationType(currentData['location']);
        if (locationType == 'facility') {
          assignedPatientIds = await _findAndAssignFacilityPatients(
            tx,
            firestore,
            agencyId,
            approvedNurseUid,
            currentData,
          );
          debugPrint(
              '✅ Dynamically assigned facility patients: $assignedPatientIds');
        } else {
          debugPrint('ℹ️ Residence shift - no automatic patient assignment');
        }
      }

      // Create corresponding scheduled shift
      final scheduledShiftRef = firestore
          .collection('agencies')
          .doc(agencyId)
          .collection('scheduledShifts')
          .doc(); // Auto-generate ID

      final scheduledShiftData = {
        'id': scheduledShiftRef.id,
        'agencyId': agencyId,
        'assignedTo': approvedNurseUid,
        'status': 'scheduled',
        'locationType': _inferLocationType(currentData['location']),
        'facilityName': currentData['facilityName'],
        'address': currentData['addressLine1'], // For backward compatibility
        'addressLine1': currentData['addressLine1'],
        'addressLine2': currentData['addressLine2'],
        'city': currentData['city'],
        'state': currentData['state'],
        'zip': currentData['zip'],
        'startTime': currentData['startTime'],
        'endTime': currentData['endTime'],
        'isConfirmed': false, // Nurse needs to confirm
        'assignedPatientIds':
            assignedPatientIds, // 🎯 Critical: Transfer patients to scheduled shift
        'createdAt': FieldValue.serverTimestamp(),
        'createdFrom': 'shift_request_approval',
        'originalShiftId': shiftId,
      };

      tx.set(scheduledShiftRef, scheduledShiftData);

      debugPrint(
          '🎉 Created scheduled shift with ${assignedPatientIds.length} patients');
      debugPrint('   Scheduled shift ID: ${scheduledShiftRef.id}');
      debugPrint('   Assigned patients: $assignedPatientIds');
    });
  }

  /// Find facility patients and assign them to the shift (NOT to the nurse directly)
  Future<List<String>> _findAndAssignFacilityPatients(
    Transaction tx,
    FirebaseFirestore firestore,
    String agencyId,
    String nurseUid,
    Map<String, dynamic> shiftData,
  ) async {
    try {
      // Query patients in the same facility/department
      final facilityName = shiftData['facilityName'] as String?;
      final department = shiftData['department'] as String?;

      if (facilityName == null) {
        debugPrint('⚠️ No facility name in shift data, no patients to assign');
        return [];
      }

      debugPrint(
          '🔍 Finding patients for facility: $facilityName, department: $department');

      // Find patients in this facility/department
      final patientsQuery = firestore
          .collection('agencies')
          .doc(agencyId)
          .collection('patients')
          .where('location', isEqualTo: 'hospital'); // Facility patients

      // If we have department info, filter by department too
      Query query = patientsQuery;
      if (department != null && department.isNotEmpty) {
        query = patientsQuery.where('department', isEqualTo: department);
      }

      // Execute query to find facility patients
      final patientsSnapshot = await query.get();
      final patientIds = <String>[];

      // 🔧 FIXED: Don't modify patients - just collect their IDs for the shift
      for (final patientDoc in patientsSnapshot.docs) {
        final patientData = patientDoc.data() as Map<String, dynamic>;
        final patientId = patientDoc.id;

        // Add patient ID to the shift assignment
        patientIds.add(patientId);

        debugPrint(
            '✅ Will assign patient $patientId (${patientData['firstName']} ${patientData['lastName']}) to shift for nurse $nurseUid');
      }

      debugPrint(
          '📋 Assigned ${patientIds.length} patients to nurse $nurseUid for facility shift');
      return patientIds;
    } catch (e) {
      debugPrint('❌ Error finding facility patients: $e');
      // Don't fail the whole transaction, just log and continue
      return [];
    }
  }

  /// Helper to infer location type from shift data
  String _inferLocationType(String? location) {
    if (location == null) return 'facility';

    final locationLower = location.toLowerCase();
    if (locationLower.contains('home') || locationLower.contains('residence')) {
      return 'residence';
    }
    return 'facility';
  }

  /// Deny shift request by removing from requestedBy
  Future<void> _denyShiftRequest(String shiftId, String nurseUid) async {
    final firestore = FirebaseFirestore.instance;

    // Get current agency context
    final agencyId = ref.read(currentAgencyIdProvider);
    if (agencyId == null) {
      throw Exception('No agency context available');
    }

    final shiftRef = firestore
        .collection('agencies')
        .doc(agencyId)
        .collection('shifts')
        .doc(shiftId);

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
        'deniedAt': FieldValue.serverTimestamp(),
        'deniedBy': 'admin_mock_uid',
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
    final agencyId = ref.read(currentAgencyIdProvider);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Generate Test Shifts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will add sample shifts to Firestore for testing the scheduling system.',
            ),
            const SizedBox(height: 12),
            if (agencyId != null)
              Text(
                'Target Agency: $agencyId',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              const Text(
                'Warning: No agency selected. Using default_agency.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
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
                await TestShiftGenerator.addTestAvailableShifts(agencyId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✅ Test shifts generated for ${agencyId ?? 'default_agency'}!',
                      ),
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
