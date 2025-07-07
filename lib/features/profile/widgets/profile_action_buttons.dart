// 📁 lib/features/profile/widgets/profile_action_buttons.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/profile/service/duty_status_service.dart';
import 'package:nurseos_v3/features/work_history/models/work_session.dart';
import 'package:nurseos_v3/features/work_history/state/work_history_controller.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/shared/widgets/buttons/secondary_button.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/l10n/l10n.dart';

class ProfileActionButtons extends ConsumerWidget {
  final UserModel user;
  final WorkSession? currentSession;
  final VoidCallback onEditProfile;

  const ProfileActionButtons({
    super.key,
    required this.user,
    required this.currentSession,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = Theme.of(context).extension<AppColors>()!;
    final workHistoryState = ref.watch(workHistoryControllerProvider);

    // Determine button state
    final isOnShift = currentSession != null;
    final isLoading = workHistoryState.isLoading;

    return Row(
      children: [
        // Edit Profile Button (takes up half the width)
        Expanded(
          child: SecondaryButton(
            label: l10n.editProfile,
            onPressed: onEditProfile,
            icon: const Icon(Icons.edit, size: 18),
          ),
        ),

        const SizedBox(width: SpacingTokens.md),

        // Shift Toggle Button (takes up half the width)
        Expanded(
          child: PrimaryButton(
            label: isOnShift ? 'End Shift' : 'Start Shift',
            onPressed: isLoading
                ? null
                : () => _showShiftConfirmation(context, ref, isOnShift),
            isLoading: isLoading,
            icon: isLoading
                ? null
                : Icon(
                    isOnShift ? Icons.stop_circle : Icons.play_circle,
                    size: 18,
                  ),
            backgroundColor:
                isOnShift ? Colors.red.shade600 : colors.brandPrimary,
          ),
        ),
      ],
    );
  }

  /// Show confirmation dialog for shift actions
  void _showShiftConfirmation(
      BuildContext context, WidgetRef ref, bool isOnShift) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isOnShift ? 'End Shift' : 'Start Shift'),
        content: Text(
          isOnShift
              ? 'Are you sure you want to end your current shift? Make sure you\'ve completed all your tasks and documented any important notes.'
              : 'Are you ready to start your shift? Your location will be recorded for attendance tracking.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _handleShiftToggle(context, ref);
            },
            style: FilledButton.styleFrom(
              backgroundColor: isOnShift ? Colors.red.shade600 : null,
            ),
            child: Text(isOnShift ? 'End Shift' : 'Start Shift'),
          ),
        ],
      ),
    );
  }

  /// Handle shift toggle with proper error handling
  Future<void> _handleShiftToggle(BuildContext context, WidgetRef ref) async {
    final dutyService = ref.read(dutyStatusServiceProvider);

    try {
      if (currentSession == null) {
        // Start new shift
        await dutyService.startShift(
          context: context,
          user: user,
        );
      } else {
        // End current shift
        await dutyService.endShift(
          context: context,
          currentSession: currentSession!,
        );
      }
    } catch (e) {
      debugPrint('❌ Shift toggle error: $e');
      // Error handling is done in the service
    }
  }
}
