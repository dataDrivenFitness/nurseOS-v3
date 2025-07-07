// 📁 lib/features/work_history/presentation/tabs/this_week_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/work_history/state/work_history_controller.dart';
import 'package:nurseos_v3/features/work_history/widgets/work_session_card.dart';
import 'package:nurseos_v3/features/work_history/widgets/common_widgets.dart';
import 'package:nurseos_v3/shared/widgets/app_loader.dart';

class ThisWeekTab extends ConsumerWidget {
  const ThisWeekTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thisWeekHistory = ref.watch(thisWeekWorkHistoryProvider);
    final weeklyHours = ref.watch(weeklyHoursProvider);

    return Column(
      children: [
        // Weekly Summary Header
        Container(
          margin: const EdgeInsets.all(SpacingTokens.md),
          padding: const EdgeInsets.all(SpacingTokens.lg),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .extension<AppColors>()!
                .brandPrimary
                .withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: weeklyHours.when(
            data: (duration) => WeeklySummaryHeader(duration: duration),
            loading: () =>
                const LoadingRow(text: 'Calculating weekly hours...'),
            error: (_, __) => const Text('Unable to calculate weekly hours'),
          ),
        ),

        // This Week's Sessions
        Expanded(
          child: thisWeekHistory.when(
            data: (sessions) {
              if (sessions.isEmpty) {
                return const EmptyState(
                  icon: Icons.calendar_today,
                  title: 'No Shifts This Week',
                  subtitle: 'Start your first shift to see it here',
                );
              }

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                    child: WorkSessionCard(session: session),
                  );
                },
              );
            },
            loading: () => const Center(child: AppLoader()),
            error: (error, _) => ErrorState(
              error: error.toString(),
              onRetry: () {
                ref.invalidate(thisWeekWorkHistoryProvider);
                ref.invalidate(weeklyHoursProvider);
              },
            ),
          ),
        ),
      ],
    );
  }
}
