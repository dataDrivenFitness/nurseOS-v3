// 📁 lib/features/work_history/presentation/tabs/recent_sessions_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/work_history/state/work_history_controller.dart';
import 'package:nurseos_v3/features/work_history/widgets/common_widgets.dart';
import 'package:nurseos_v3/features/work_history/widgets/work_session_card.dart';
import 'package:nurseos_v3/shared/widgets/app_loader.dart';

class RecentSessionsTab extends ConsumerWidget {
  const RecentSessionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentHistory = ref.watch(recentWorkHistoryProvider);

    return recentHistory.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return const EmptyState(
            icon: Icons.work_history,
            title: 'No Work History',
            subtitle: 'Your completed shifts will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(SpacingTokens.md),
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
        onRetry: () => ref.invalidate(recentWorkHistoryProvider),
      ),
    );
  }
}
