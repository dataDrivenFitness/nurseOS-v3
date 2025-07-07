// 📁 lib/features/work_history/presentation/work_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/work_history/presentation/tabs/recent_sessions_tab.dart';
import 'package:nurseos_v3/features/work_history/presentation/tabs/this_week_tab.dart';
import 'package:nurseos_v3/features/work_history/presentation/tabs/summary_tab.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';

class WorkHistoryScreen extends ConsumerStatefulWidget {
  const WorkHistoryScreen({super.key});

  @override
  ConsumerState<WorkHistoryScreen> createState() => _WorkHistoryScreenState();
}

class _WorkHistoryScreenState extends ConsumerState<WorkHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return NurseScaffold(
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: const Text('Work History'),
          backgroundColor: colors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: colors.brandPrimary,
            unselectedLabelColor: colors.subdued,
            indicatorColor: colors.brandPrimary,
            tabs: const [
              Tab(text: 'Recent', icon: Icon(Icons.history, size: 20)),
              Tab(
                  text: 'This Week',
                  icon: Icon(Icons.calendar_month, size: 20)),
              Tab(text: 'Summary', icon: Icon(Icons.analytics, size: 20)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            RecentSessionsTab(),
            ThisWeekTab(),
            SummaryTab(),
          ],
        ),
      ),
    );
  }
}
