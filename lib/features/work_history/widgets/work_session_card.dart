// 📁 lib/features/work_history/presentation/widgets/work_session_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/work_history/models/work_session.dart';

class WorkSessionCard extends ConsumerWidget {
  final WorkSession session;

  const WorkSessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final isActive = session.isActive;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : colors.subdued,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isActive ? 'Active Session' : 'Completed Session',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.green.shade700 : null,
                    ),
                  ),
                ),
                Text(
                  session.formattedDuration,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        isActive ? Colors.green.shade700 : colors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Session Details
            SessionDetailRow(
              icon: Icons.schedule,
              label: isActive ? 'Started' : 'Time',
              value: session.timeRange,
            ),

            const SizedBox(height: 8),

            SessionDetailRow(
              icon: Icons.location_on,
              label: 'Location',
              value: session.locationDisplay,
            ),

            if (session.department != null || session.shift != null) ...[
              const SizedBox(height: 8),
              SessionDetailRow(
                icon: Icons.work,
                label: 'Assignment',
                value:
                    '${session.department ?? 'Unknown'} • ${session.shift ?? 'Unknown'}',
              ),
            ],

            if (session.notes != null && session.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              SessionDetailRow(
                icon: Icons.note,
                label: 'Notes',
                value: session.notes!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SessionDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const SessionDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colors.subdued),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.subdued,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
