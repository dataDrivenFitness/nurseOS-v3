import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/animation_tokens.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';

class GhostCardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const GhostCardAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface.withAlpha(242), // 0.95 * 255 ≈ 242
      borderRadius: ShapeTokens.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: ShapeTokens.cardRadius,
        splashColor: colorScheme.primary.withAlpha(25), // 0.1 * 255
        child: AnimatedContainer(
          duration: AnimationTokens.medium,
          padding: const EdgeInsets.all(SpacingTokens.lg),
          decoration: BoxDecoration(
            borderRadius: ShapeTokens.cardRadius,
            border: Border.all(
              color: colorScheme.outline.withAlpha(51), // 0.2 * 255
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: SpacingTokens.md),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
