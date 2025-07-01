import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart'; // ✅ newly added

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double opacity = (onPressed == null) ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(
              vertical: SpacingTokens.md,
              horizontal: SpacingTokens.lg,
            ),
            shape: ShapeTokens.defaultPill, // ✅ consistent rounded shape
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
