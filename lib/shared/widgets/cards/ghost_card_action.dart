import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';

/// A tappable card used for "Add" or "Empty State" actions in lists.
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
    final colors = theme.extension<AppColors>()!;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 2, // ✅ Matches patient card
      color: colors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, color: colors.subdued),
              const SizedBox(width: 12),
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: colors.subdued,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
