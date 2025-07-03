import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';

class TertiaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  const TertiaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double opacity = (onPressed == null) ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: icon != null
          ? TextButton.icon(
              onPressed: onPressed,
              icon: icon!,
              label: Text(label),
              style: _buttonStyle(colorScheme),
            )
          : TextButton(
              onPressed: onPressed,
              style: _buttonStyle(colorScheme),
              child: Text(label),
            ),
    );
  }

  ButtonStyle _buttonStyle(ColorScheme colorScheme) {
    return TextButton.styleFrom(
      foregroundColor: colorScheme.primary,
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.md,
        horizontal: SpacingTokens.lg,
      ),
      shape: ShapeTokens.defaultPill,
    );
  }
}
