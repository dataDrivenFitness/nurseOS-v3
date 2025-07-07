// 📁 lib/features/profile/widgets/current_session_card.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/features/work_history/models/work_session.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/work_history/models/work_session_extensions.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';

class CurrentSessionCard extends StatelessWidget {
  final WorkSession session;

  const CurrentSessionCard({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return FormCard(
      title: 'Current Shift',
      child: Column(
        children: [
          _buildInfoRow(
            context,
            icon: Icons.schedule,
            label: 'Started',
            value: session.timeRange,
            colors: colors,
          ),
          const SizedBox(height: SpacingTokens.sm),
          _buildInfoRow(
            context,
            icon: Icons.timer,
            label: 'Duration',
            value: session.formattedDuration,
            colors: colors,
            valueColor: Colors.green,
          ),
          const SizedBox(height: SpacingTokens.sm),
          _buildInfoRow(
            context,
            icon: Icons.location_on,
            label: 'Location',
            value: session.locationDisplay,
            colors: colors,
          ),
          if (session.workContext.isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.sm),
            _buildInfoRow(
              context,
              icon: Icons.work,
              label: 'Assignment',
              value: session.workContext.entries
                  .where((e) => e.value != null && e.value!.isNotEmpty)
                  .map((e) => '${e.key}: ${e.value}')
                  .join(', '),
              colors: colors,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required AppColors colors,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colors.brandPrimary),
        const SizedBox(width: SpacingTokens.sm),
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
                      color: valueColor ?? colors.text,
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
