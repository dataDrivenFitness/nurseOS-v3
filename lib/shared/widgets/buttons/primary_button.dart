import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final Color? backgroundColor; // For special cases like success buttons

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double opacity = (onPressed == null && !isLoading) ? 0.5 : 1.0;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: double.infinity,
        child: isLoading
            ? _buildLoadingButton(colorScheme, effectiveBackgroundColor)
            : _buildNormalButton(colorScheme, effectiveBackgroundColor),
      ),
    );
  }

  Widget _buildLoadingButton(ColorScheme colorScheme, Color backgroundColor) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: colorScheme.onPrimary,
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
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildNormalButton(ColorScheme colorScheme, Color backgroundColor) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: Text(label),
        style: _buttonStyle(colorScheme, backgroundColor),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: _buttonStyle(colorScheme, backgroundColor),
      child: Text(label),
    );
  }

  ButtonStyle _buttonStyle(ColorScheme colorScheme, Color backgroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.md,
        horizontal: SpacingTokens.lg,
      ),
      shape: ShapeTokens.defaultPill,
    );
  }
}
