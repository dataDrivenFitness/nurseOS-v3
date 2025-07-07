// 📁 lib/features/work_history/widgets/summary_cards.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/work_history/models/work_session.dart';
import 'package:nurseos_v3/features/work_history/widgets/summary_row.dart';

class CurrentSessionSummary extends StatelessWidget {
  final WorkSession session;

  const CurrentSessionSummary({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Currently On Duty',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Started: ${session.timeRange}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Duration: ${session.formattedDuration}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
            ),
            if (session.department != null || session.shift != null) ...[
              const SizedBox(height: 4),
              Text(
                '${session.department ?? 'Unknown'} • ${session.shift ?? 'Unknown'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.subdued,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoActiveSessionCard extends StatelessWidget {
  const NoActiveSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Currently Off Duty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodaysSummaryCard extends StatelessWidget {
  final List<WorkSession> sessions;

  const TodaysSummaryCard({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text('No shifts today'),
            ],
          ),
        ),
      );
    }

    // Calculate today's total hours
    int totalMinutes = 0;
    for (final session in sessions) {
      if (session.duration != null) {
        // Duration is stored in seconds, convert to minutes
        totalMinutes += (session.duration! / 60).round();
      } else {
        // For active sessions, calculate current duration
        final currentDuration = DateTime.now().difference(session.startTime);
        totalMinutes += currentDuration.inMinutes;
      }
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            SummaryRow(
              icon: Icons.today,
              label:
                  '${sessions.length} shift${sessions.length != 1 ? 's' : ''}',
            ),
            const SizedBox(height: 4),
            SummaryRow(
              icon: Icons.timer,
              label: '${hours}h ${minutes}m total',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyDetailedSummary extends StatelessWidget {
  final Duration duration;

  const WeeklyDetailedSummary({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    // Calculate if it's a full-time equivalent
    final isFullTime = hours >= 32; // Assuming 32+ hours is full-time
    final overtimeHours = hours > 40 ? hours - 40 : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            SummaryRowWithValue(
              icon: Icons.schedule,
              label: 'Total Hours',
              value: '${hours}h ${minutes.toString().padLeft(2, '0')}m',
            ),
            const SizedBox(height: 8),
            SummaryRowWithValue(
              icon: Icons.work,
              label: 'Status',
              value: isFullTime ? 'Full-time' : 'Part-time',
              valueColor: isFullTime ? Colors.green : Colors.orange,
            ),
            if (overtimeHours > 0) ...[
              const SizedBox(height: 8),
              SummaryRowWithValue(
                icon: Icons.trending_up,
                label: 'Overtime',
                value: '${overtimeHours}h',
                valueColor: Colors.red,
              ),
            ],
            const SizedBox(height: 8),
            SummaryRowWithValue(
              icon: Icons.calendar_month,
              label: 'Week Period',
              value: _getWeekPeriod(),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekPeriod() {
    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return '${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}';
  }
}
