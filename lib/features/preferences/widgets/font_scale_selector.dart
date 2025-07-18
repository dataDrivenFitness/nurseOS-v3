// 📁 lib/shared/widgets/font_scale_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/preferences/controllers/font_scale_controller.dart';

class FontScaleSelector extends ConsumerWidget {
  const FontScaleSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔄 Live Firestore stream
    final scaleAsync = ref.watch(fontScaleStreamProvider);
    final controller = ref.read(fontScaleControllerProvider.notifier);

    return scaleAsync.maybeWhen(
      data: (currentScale) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Text Size',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Slider(
            value: currentScale.clamp(
                0.8, 1.2), // ✅ FIXED: Perfect range for 1.0 at center
            min: 0.8, // ✅ 2 steps down from 1.0
            max: 1.2, // ✅ 2 steps up from 1.0
            divisions: 4, // ✅ 5 total positions
            label: '${(currentScale * 100).round()}%',
            onChanged: (newValue) {
              // ✅ FIXED: Proper async handling
              _updateScaleWithErrorHandling(controller, newValue, context);
            },
          ),
          Text(
            'Preview Text (Scale: ${currentScale.toStringAsFixed(2)})',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      orElse: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// ✅ FIXED: Properly handle async scale updates with error handling
  void _updateScaleWithErrorHandling(
    FontScaleController controller,
    double newValue,
    BuildContext context,
  ) {
    // Update scale asynchronously with proper error handling
    controller.updateScale(newValue).catchError((error) {
      // Handle errors gracefully without breaking the modal
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
}
