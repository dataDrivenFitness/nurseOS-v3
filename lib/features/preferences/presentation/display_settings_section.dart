// lib/features/preferences/presentation/display_settings_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/shared/widgets/app_loader.dart';
import '../../../core/theme/spacing.dart';
import '../state/display_preferences_controller.dart';
import '../domain/patient_display_option.dart';

class DisplaySettingsSection extends ConsumerWidget {
  const DisplaySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(displayPreferencesControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    return prefsAsync.when(
      loading: () => const Center(child: AppLoader()),
      error: (e, _) => Text("Error loading preferences: $e"),
      data: (prefs) => ExpansionTile(
        title: const Text("Patient Info Display"),
        children: PatientDisplayOption.values.map((option) {
          final isEnabled = prefs.options.contains(option);
          return SwitchListTile(
            value: isEnabled,
            onChanged: (_) {
              ref
                  .read(displayPreferencesControllerProvider.notifier)
                  .toggle(option);
            },
            title: Text(option.label, style: textTheme.bodyLarge),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
            ),
          );
        }).toList(),
      ),
    );
  }
}
