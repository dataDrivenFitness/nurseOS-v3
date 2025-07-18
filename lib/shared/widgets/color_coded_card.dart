// 📁 lib/shared/widgets/color_coded_card.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';

/// Shared card component with optional color-coded sidebar
///
/// ✅ Used by PatientCard and ShiftCard for consistent styling
/// ✅ Configurable sidebar width, color, and visibility
/// ✅ Maintains exact patient card layout patterns
/// ✅ Supports InkWell tap interactions
class ColorCodedCard extends StatelessWidget {
  /// Main card content
  final Widget child;

  /// Color of the left sidebar (when shown)
  final Color? sidebarColor;

  /// Width of the sidebar in pixels
  final double sidebarWidth;

  /// Whether to show the sidebar
  final bool showSidebar;

  /// Card tap handler
  final VoidCallback? onTap;

  /// Card elevation
  final double elevation;

  /// Card margin (use EdgeInsets.zero for tight layouts)
  final EdgeInsetsGeometry margin;

  const ColorCodedCard({
    super.key,
    required this.child,
    this.sidebarColor,
    this.sidebarWidth = SpacingTokens.sidebarWidth,
    this.showSidebar = true,
    this.onTap,
    this.elevation = 2.0,
    this.margin = EdgeInsets.zero,
  });

  /// Named constructor for patient cards with risk-based sidebar
  const ColorCodedCard.patient({
    super.key,
    required this.child,
    required Color? riskColor,
    required bool showRiskSidebar,
    this.onTap,
  })  : sidebarColor = riskColor,
        showSidebar = showRiskSidebar,
        sidebarWidth = SpacingTokens.sidebarWidth,
        elevation = 2.0,
        margin = EdgeInsets.zero;

  /// Named constructor for shift cards with urgency-based sidebar
  const ColorCodedCard.shift({
    super.key,
    required this.child,
    required Color urgencyColor,
    this.onTap,
    this.margin = const EdgeInsets.only(bottom: SpacingTokens.md),
  })  : sidebarColor = urgencyColor,
        sidebarWidth = 8.0, // Shift cards use 8px for visual hierarchy
        showSidebar = true,
        elevation = 2.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Card(
      elevation: elevation,
      color: colors.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: ShapeTokens.cardRadius),
      margin: margin,
      child: InkWell(
        borderRadius: ShapeTokens.cardRadius,
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 🚦 Optional color-coded sidebar
              if (showSidebar && sidebarColor != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Container(
                    width: sidebarWidth,
                    decoration: BoxDecoration(
                      color: sidebarColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),

              // 📋 Main card content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
