import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  const SecondaryButton({
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
      child: SizedBox(
        width: double.infinity,
        child: icon != null
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: icon!,
                label: Text(label),
                style: _buttonStyle(colorScheme),
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: _buttonStyle(colorScheme),
                child: Text(label),
              ),
      ),
    );
  }

  ButtonStyle _buttonStyle(ColorScheme colorScheme) {
    return OutlinedButton.styleFrom(
      foregroundColor: colorScheme.primary,
      side: BorderSide(color: colorScheme.outline.withAlpha(100)),
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.md,
        horizontal: SpacingTokens.md,
      ),
      shape: ShapeTokens.defaultPill,
    );
  }
}
