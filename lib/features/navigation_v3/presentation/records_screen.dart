// lib/features/navigation_v3/presentation/records_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/work_history/state/work_history_controller.dart';
import 'package:nurseos_v3/features/work_history/models/work_session.dart';

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _showExportDialog(context),
            tooltip: 'Export Records',
          ),
        ],
      ),
      body: const RecordsContent(),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Records'),
        content: const Text(
            'Export functionality coming soon.\nYou\'ll be able to export your work history for payroll and record keeping.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class RecordsContent extends ConsumerWidget {
  const RecordsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        // Invalidate providers to trigger refresh
        ref.invalidate(recentWorkHistoryProvider);
        ref.invalidate(weeklyHoursProvider);
        ref.invalidate(thisWeekWorkHistoryProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hours Summary Section
            const HoursSummaryCard(),
            const SizedBox(height: SpacingTokens.lg),

            // Work Analytics Section
            const WorkAnalyticsCard(),
            const SizedBox(height: SpacingTokens.lg),

            // Recent Work History Section
            Text(
              'Recent Work History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: SpacingTokens.md),
            const WorkHistoryList(),
          ],
        ),
      ),
    );
  }
}

class HoursSummaryCard extends ConsumerWidget {
  const HoursSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyHoursAsync = ref.watch(weeklyHoursProvider);
    final thisWeekSessionsAsync = ref.watch(thisWeekWorkHistoryProvider);
    final colors = Theme.of(context).extension<AppColors>()!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: colors.brandPrimary,
                  size: 24,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  'Hours Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.lg),

            // Show simple message if providers are stuck
            weeklyHoursAsync.when(
              data: (duration) {
                final hours = duration.inMinutes / 60.0;
                return Column(
                  children: [
                    _buildHoursStat(
                      context,
                      'This Week',
                      '${hours.toStringAsFixed(1)} hrs',
                      colors.brandPrimary,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    thisWeekSessionsAsync.when(
                      data: (sessions) {
                        final completedShifts =
                            sessions.where((s) => s.endTime != null).length;
                        return _buildHoursStat(
                          context,
                          'Shifts This Week',
                          '$completedShifts shifts',
                          colors.subdued,
                        );
                      },
                      loading: () => _buildHoursStat(context,
                          'Shifts This Week', '-- shifts', colors.subdued),
                      error: (_, __) => _buildHoursStat(
                          context, 'Shifts This Week', 'Error', colors.subdued),
                    ),
                  ],
                );
              },
              loading: () => Column(
                children: [
                  _buildHoursStat(
                      context, 'This Week', '-- hrs', colors.subdued),
                  const SizedBox(height: SpacingTokens.md),
                  _buildHoursStat(
                      context, 'Shifts This Week', '-- shifts', colors.subdued),
                  const SizedBox(height: SpacingTokens.md),
                  const Text('Loading hours data...',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
              error: (_, __) => Column(
                children: [
                  _buildHoursStat(
                      context, 'This Week', 'Error', colors.subdued),
                  const SizedBox(height: SpacingTokens.md),
                  _buildHoursStat(
                      context, 'Shifts This Week', 'Error', colors.subdued),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursStat(
      BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildLoadingStat(BuildContext context, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    );
  }

  Widget _buildErrorStat(BuildContext context, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          'Error',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
        ),
      ],
    );
  }
}

class WorkAnalyticsCard extends ConsumerWidget {
  const WorkAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSessionsAsync = ref.watch(recentWorkHistoryProvider);
    final colors = Theme.of(context).extension<AppColors>()!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: colors.brandPrimary,
                  size: 24,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  'Work Analytics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.lg),
            recentSessionsAsync.when(
              data: (sessions) {
                final completedSessions =
                    sessions.where((s) => s.endTime != null).toList();

                if (completedSessions.isEmpty) {
                  return Text(
                    'No completed shifts yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.subdued,
                        ),
                  );
                }

                // Calculate analytics
                final totalHours = completedSessions.fold<double>(
                  0.0,
                  (sum, session) => sum + (session.duration ?? 0) / 3600.0,
                );

                final averageShiftLength =
                    totalHours / completedSessions.length;

                // Count facilities worked at
                final facilities = completedSessions
                    .map((s) => s.facility ?? 'Unknown')
                    .toSet()
                    .length;

                return Column(
                  children: [
                    _buildAnalyticsStat(
                      context,
                      'Last 30 Days',
                      '${totalHours.toStringAsFixed(1)} hrs',
                      colors.brandPrimary,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    _buildAnalyticsStat(
                      context,
                      'Average Shift',
                      '${averageShiftLength.toStringAsFixed(1)} hrs',
                      colors.subdued,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    _buildAnalyticsStat(
                      context,
                      'Facilities',
                      '$facilities locations',
                      colors.subdued,
                    ),
                  ],
                );
              },
              loading: () => Column(
                children: [
                  _buildAnalyticsStat(
                      context, 'Last 30 Days', '-- hrs', colors.subdued),
                  const SizedBox(height: SpacingTokens.md),
                  _buildAnalyticsStat(
                      context, 'Average Shift', '-- hrs', colors.subdued),
                  const SizedBox(height: SpacingTokens.md),
                  _buildAnalyticsStat(
                      context, 'Facilities', '-- locations', colors.subdued),
                  const SizedBox(height: SpacingTokens.md),
                  const Text('Loading analytics...',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
              error: (error, _) => Text(
                'Unable to load analytics',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsStat(
      BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

class WorkHistoryList extends ConsumerWidget {
  const WorkHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;

    if (user == null) {
      return const Center(child: Text('Not authenticated'));
    }

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workHistory')
          .orderBy('startTime', descending: true)
          .limit(10)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Loading work history...'),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const _EmptyWorkHistory();
        }

        // Parse documents manually
        final sessions = <WorkSession>[];
        for (final doc in snapshot.data!.docs) {
          try {
            final session = WorkSession.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'sessionId': doc.id,
            });
            sessions.add(session);
          } catch (e) {
            print('Failed to parse session ${doc.id}: $e');
            // Skip this document and continue
          }
        }

        if (sessions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No valid work sessions found'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return WorkSessionCard(session: session);
          },
        );
      },
    );
  }
}

class _EmptyWorkHistory extends StatelessWidget {
  const _EmptyWorkHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              'No work history yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Your completed shifts will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class WorkSessionCard extends StatelessWidget {
  final WorkSession session;

  const WorkSessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isCompleted = session.endTime != null;
    final isActive = !isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(session.startTime),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.sm,
                    vertical: SpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.shade100
                        : colors.subdued.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Completed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              isActive ? Colors.green.shade700 : colors.subdued,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: SpacingTokens.md),

            // Time information
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
                    _formatTimeRange(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (isCompleted && session.duration != null)
                  Text(
                    _formatDuration(session.duration!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.subdued,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
              ],
            ),

            // Location information
            const SizedBox(height: SpacingTokens.sm),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: colors.subdued,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    session.startAddress,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.subdued,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Facility information
            if (session.facility != null) ...[
              const SizedBox(height: SpacingTokens.sm),
              Row(
                children: [
                  Icon(
                    Icons.business,
                    size: 16,
                    color: colors.subdued,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(
                      session.facility!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.subdued,
                          ),
                    ),
                  ),
                ],
              ),
            ],

            // Department and shift information
            if (session.department != null || session.shift != null) ...[
              const SizedBox(height: SpacingTokens.sm),
              Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 16,
                    color: colors.subdued,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(
                      [session.department, session.shift]
                          .where((e) => e != null)
                          .join(' • '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.subdued,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimeRange() {
    final startTime = DateFormat('h:mm a').format(session.startTime);
    if (session.endTime != null) {
      final endTime = DateFormat('h:mm a').format(session.endTime!);
      return '$startTime - $endTime';
    } else {
      return '$startTime - Active';
    }
  }

  String _formatDuration(int durationSeconds) {
    final duration = Duration(seconds: durationSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
