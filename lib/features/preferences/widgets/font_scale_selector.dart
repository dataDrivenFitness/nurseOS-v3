// 📁 lib/shared/widgets/font_scale_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/preferences/controllers/font_scale_controller.dart';

class FontScaleSelector extends ConsumerWidget {
  const FontScaleSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔄 live Firestore value
    final scaleAsync = ref.watch(fontScaleStreamProvider); // ← changed
    final controller = ref.read(fontScaleControllerProvider.notifier);

    return scaleAsync.when(
      data: (currentScale) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Text Size',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Slider(
            value: currentScale,
            min: 0.8,
            max: 2.0,
            divisions: 6,
            label: '${(currentScale * 100).round()}%',
            onChanged: controller.updateScale, // still writes as before
          ),
          Text(
            'Preview Text (Scale: ${currentScale.toStringAsFixed(2)})',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error loading scale: $e'),
    );
  }
}
