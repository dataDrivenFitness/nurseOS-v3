import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/opacity_tokens.dart';

// 🎨 Tunable visual constants
const double _iconSize = 28;
const double _capsuleVerticalPadding = 6;
const double _capsuleHorizontalPadding = 20;
const double _badgeSize = 8;

class NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final bool badge;

  const NavIcon({
    super.key,
    required this.icon,
    required this.isSelected,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _capsuleHorizontalPadding,
        vertical: _capsuleVerticalPadding,
      ),
      decoration: isSelected
          ? BoxDecoration(
              color: colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(100),
            )
          : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            size: _iconSize,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface
                    .withValues(alpha: OpacityTokens.disabledState / 255),
          ),
          if (badge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: _badgeSize,
                height: _badgeSize,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
