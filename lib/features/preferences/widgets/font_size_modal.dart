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
                          value: _snapToNearest(scale),
                          min: 0.8,
                          max: 1.6,
                          divisions: 4, // 5 levels
                          label: _labelForScale(scale),
                          onChanged: (newValue) {
                            final snapped = _snapToNearest(newValue);
                            ref
                                .read(fontScaleControllerProvider.notifier)
                                .updateScale(snapped);
                          },
                        ),
                        Text(
                          _labelForScale(scale),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  loading: () => SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
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

final _presetScales = [0.85, 0.925, 1.0, 1.075, 1.15];

double _snapToNearest(double value) {
  return _presetScales
      .reduce((a, b) => (a - value).abs() < (b - value).abs() ? a : b);
}

String _labelForScale(double scale) {
  final snapped = _snapToNearest(scale);

  if ((snapped - 0.85).abs() < 0.01) return 'Smallest';
  if ((snapped - 0.925).abs() < 0.01) return 'Small';
  if ((snapped - 1.0).abs() < 0.01) return 'Normal';
  if ((snapped - 1.075).abs() < 0.01) return 'Large';
  if ((snapped - 1.15).abs() < 0.01) return 'Extra Large';

  return '${(snapped * 100).round()}%';
}
