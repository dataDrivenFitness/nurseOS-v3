import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/font_scale_selector.dart';

class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: FontScaleSelector(),
      ),
    );
  }
}
