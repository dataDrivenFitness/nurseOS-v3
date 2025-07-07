// 📁 lib/features/work_history/presentation/tabs/summary_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/work_history/state/work_history_controller.dart';
import 'package:nurseos_v3/features/work_history/widgets/common_widgets.dart';
import 'package:nurseos_v3/features/work_history/widgets/summary_cards.dart';

class SummaryTab extends ConsumerWidget {
  const SummaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSession = ref.watch(currentWorkSessionStreamProvider);
    final todaySessions = ref.watch(todayWorkHistoryProvider);
    final weeklyHours = ref.watch(weeklyHoursProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Session Status
          currentSession.when(
            data: (session) => session != null
                ? CurrentSessionSummary(session: session)
                : const NoActiveSessionCard(),
            loading: () =>
                const LoadingCard(text: 'Checking current session...'),
            error: (_, __) => const NoActiveSessionCard(),
          ),

          const SizedBox(height: SpacingTokens.lg),

          // Today's Summary
          todaySessions.when(
            data: (sessions) => TodaysSummaryCard(sessions: sessions),
            loading: () =>
                const LoadingCard(text: 'Loading today\'s summary...'),
            error: (_, __) =>
                const ErrorCard(text: 'Unable to load today\'s summary'),
          ),

          const SizedBox(height: SpacingTokens.lg),

          // Weekly Summary
          weeklyHours.when(
            data: (duration) => WeeklyDetailedSummary(duration: duration),
            loading: () =>
                const LoadingCard(text: 'Calculating weekly summary...'),
            error: (_, __) =>
                const ErrorCard(text: 'Unable to calculate weekly summary'),
          ),
        ],
      ),
    );
  }
}
