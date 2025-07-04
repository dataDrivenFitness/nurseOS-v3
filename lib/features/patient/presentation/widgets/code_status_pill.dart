import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/code_status_utils.dart';

class CodeStatusPill extends StatelessWidget {
  final String codeStatus;

  const CodeStatusPill({super.key, required this.codeStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textTheme = theme.textTheme;

    // Use shared utility for consistent styling
    final style = CodeStatusUtils.getStyle(codeStatus, colors);

    return Tooltip(
      message: style.tooltip,
      preferBelow: false,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          color: style.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: style.color, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(style.icon, size: 12, color: style.color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                codeStatus,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: style.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
