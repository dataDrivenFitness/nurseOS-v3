// lib/features/navigation_v3/presentation/my_shift_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/text_styles.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
import 'package:nurseos_v3/features/navigation_v3/presentation/widgets/current_shift_tab.dart';

/// My Shift Screen - Shows clock-in interface and patient/task management
///
/// Architecture:
/// - Off Duty: Clock in interface
/// - On Duty: 2-tab system (Patients | Tasks) within CurrentShiftTab
class MyShiftScreen extends ConsumerWidget {
  const MyShiftScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = AppTypography.textTheme;

    return NurseScaffold(
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(
            'My Shift',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          backgroundColor: colors.surface,
          elevation: 0,
          centerTitle: false,
        ),
        body: const CurrentShiftTab(),
      ),
    );
  }
}
