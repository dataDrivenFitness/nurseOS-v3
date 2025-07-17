import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';
import 'package:nurseos_v3/shared/widgets/buttons/button_variants.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final ButtonVariant variant;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = ButtonVariant.normal,
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
    // Determine colors based on variant
    final Color foregroundColor;
    final Color borderColor;

    if (variant == ButtonVariant.destructive) {
      foregroundColor = colorScheme.error;
      borderColor = colorScheme.error.withAlpha(100);
    } else {
      foregroundColor = colorScheme.primary;
      borderColor = colorScheme.outline.withAlpha(100);
    }

    return OutlinedButton.styleFrom(
      foregroundColor: foregroundColor,
      side: BorderSide(color: borderColor),
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.md,
        horizontal: SpacingTokens.md,
      ),
      shape: ShapeTokens.defaultPill,
    );
  }
}
