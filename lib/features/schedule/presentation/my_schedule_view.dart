// lib/features/schedule/presentation/my_schedule_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/schedule/state/upcoming_shifts_provider.dart';
import 'package:nurseos_v3/features/schedule/widgets/scheduled_shift_card.dart';

class MyScheduleView extends ConsumerWidget {
  const MyScheduleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final upcomingShiftsAsync = ref.watch(upcomingShiftsProvider(user.uid));

    return upcomingShiftsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                'Error loading shifts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      data: (shifts) {
        if (shifts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Text(
                    'No upcoming shifts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'Your confirmed shifts will appear here',
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

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
          itemCount: shifts.length,
          itemBuilder: (context, index) {
            final shift = shifts[index];
            return ScheduledShiftCard(
              shift: shift,
            );
          },
        );
      },
    );
  }
}
