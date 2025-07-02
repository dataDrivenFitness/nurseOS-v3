import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';

class CodeStatusPill extends StatelessWidget {
  final String codeStatus;

  const CodeStatusPill({super.key, required this.codeStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textTheme = theme.textTheme;

    final status = codeStatus.toLowerCase();

    late final Color bgColor;
    late final Color borderColor;
    late final Color textColor;
    late final IconData icon;
    late final String tooltip;

    switch (status) {
      case 'dnr':
        bgColor = colors.danger.withOpacity(0.15);
        borderColor = colors.danger;
        textColor = colors.danger;
        icon = Icons.heart_broken;
        tooltip = 'DNR: Do Not Resuscitate';
        break;
      case 'dni':
        bgColor = colors.warning.withOpacity(0.15);
        borderColor = colors.warning;
        textColor = colors.warning;
        icon = Icons.remove_circle_outline;
        tooltip = 'DNI: Do Not Intubate';
        break;
      case 'full':
      case 'full code':
        bgColor = colors.success.withOpacity(0.15);
        borderColor = colors.success;
        textColor = colors.success;
        icon = Icons.favorite;
        tooltip = 'Full Code: All resuscitative efforts';
        break;
      case 'limited':
        bgColor = colors.brandAccent.withOpacity(0.15);
        borderColor = colors.brandAccent;
        textColor = colors.brandAccent;
        icon = Icons.warning_amber_rounded;
        tooltip = 'Limited Code: Some interventions only';
        break;
      default:
        bgColor = colors.onSurface.withOpacity(0.1);
        borderColor = colors.subdued;
        textColor = colors.subdued;
        icon = Icons.info_outline;
        tooltip = 'Code Status: Unspecified';
    }

    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                codeStatus,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: textColor,
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
