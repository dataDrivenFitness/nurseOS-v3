import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';
import 'package:nurseos_v3/shared/widgets/buttons/button_variants.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final Color? backgroundColor; // For special cases like success buttons
  final ButtonVariant variant;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.variant = ButtonVariant.normal,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double opacity = (onPressed == null && !isLoading) ? 0.5 : 1.0;

    // Determine effective background color
    final Color effectiveBackgroundColor;
    final Color effectiveForegroundColor;

    if (backgroundColor != null) {
      // Custom background color takes precedence
      effectiveBackgroundColor = backgroundColor!;
      effectiveForegroundColor = colorScheme.onPrimary;
    } else if (variant == ButtonVariant.destructive) {
      // Destructive variant uses error colors
      effectiveBackgroundColor = colorScheme.error;
      effectiveForegroundColor = colorScheme.onError;
    } else {
      // Normal variant uses primary colors
      effectiveBackgroundColor = colorScheme.primary;
      effectiveForegroundColor = colorScheme.onPrimary;
    }

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: double.infinity,
        child: isLoading
            ? _buildLoadingButton(
                effectiveBackgroundColor, effectiveForegroundColor)
            : _buildNormalButton(
                effectiveBackgroundColor, effectiveForegroundColor),
      ),
    );
  }

  Widget _buildLoadingButton(Color backgroundColor, Color foregroundColor) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.md,
          horizontal: SpacingTokens.lg,
        ),
        shape: ShapeTokens.defaultPill,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildNormalButton(Color backgroundColor, Color foregroundColor) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: Text(label),
        style: _buttonStyle(backgroundColor, foregroundColor),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: _buttonStyle(backgroundColor, foregroundColor),
      child: Text(label),
    );
  }

  ButtonStyle _buttonStyle(Color backgroundColor, Color foregroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.md,
        horizontal: SpacingTokens.lg,
      ),
      shape: ShapeTokens.defaultPill,
    );
  }
}
