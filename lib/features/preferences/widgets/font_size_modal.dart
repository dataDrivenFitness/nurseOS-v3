// 📁 lib/features/preferences/widgets/font_size_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/preferences/controllers/font_scale_controller.dart';

void showTextSizeModal(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.lg,
          SpacingTokens.xl,
          SpacingTokens.lg,
          SpacingTokens.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Text Size',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: SpacingTokens.lg),
            Consumer(
              builder: (context, ref, _) {
                final fontScaleAsync = ref.watch(fontScaleControllerProvider);

                return fontScaleAsync.when(
                  data: (scale) => SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Slider(
                          value:
                              scale.clamp(0.8, 1.2), // ✅ FIXED: Perfect range
                          min: 0.8, // ✅ 2 steps down from 1.0
                          max: 1.2, // ✅ 2 steps up from 1.0
                          divisions: 4, // ✅ 5 total positions
                          label: _labelForScale(scale),
                          onChanged: (newValue) {
                            // ✅ FIXED: Proper async handling
                            _updateScaleWithErrorHandling(
                                ref, newValue, context);
                          },
                        ),
                        Text(
                          _labelForScale(scale),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 24),
                        CircularProgressIndicator(),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                  error: (e, st) => SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Failed to load font scale',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

// ✅ PERFECT: 5 positions with Normal (1.0) exactly at 50%
// Range: 0.6 to 1.4, Step size: 0.2
final _presetScales = [0.8, 0.9, 1.0, 1.1, 1.2];

double _snapToNearest(double value) {
  return _presetScales
      .reduce((a, b) => (a - value).abs() < (b - value).abs() ? a : b);
}

String _labelForScale(double scale) {
  if (scale <= 0.85) return 'Smallest'; // 0.8 (0% position)
  if (scale <= 0.95) return 'Small'; // 0.9 (25% position)
  if (scale <= 1.05) return 'Normal'; // 1.0 (50% position) ⭐
  if (scale <= 1.15) return 'Large'; // 1.1 (75% position)
  return 'Largest'; // 1.2 (100% position)
}

// ✅ FIXED: Proper async error handling for modal
void _updateScaleWithErrorHandling(
  WidgetRef ref,
  double newValue,
  BuildContext context,
) {
  final controller = ref.read(fontScaleControllerProvider.notifier);

  controller.updateScale(newValue).catchError((error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update text size: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  });
}
