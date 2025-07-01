import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';

class TextLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const TextLinkButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.sm,
          horizontal: SpacingTokens.md,
        ),
        alignment: Alignment.centerLeft,
        shape: ShapeTokens.defaultPill, // ✅ applies consistent button shape
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.error,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
