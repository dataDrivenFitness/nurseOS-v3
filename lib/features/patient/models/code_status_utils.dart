// lib/features/patient/models/code_status_utils.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';

/// Utility class for code status related UI logic
class CodeStatusUtils {
  CodeStatusUtils._(); // Private constructor to prevent instantiation

  /// Get the appropriate icon for a code status
  static IconData getIcon(String status) {
    switch (status.toLowerCase().trim()) {
      case 'dnr':
        return Icons.heart_broken;
      case 'dni':
        return Icons.remove_circle_outline;
      case 'full':
      case 'full code':
        return Icons.favorite;
      case 'limited':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }

  /// Get the appropriate color for a code status
  static Color getColor(String status, AppColors colors) {
    switch (status.toLowerCase().trim()) {
      case 'dnr':
        return colors.danger;
      case 'dni':
        return colors.warning;
      case 'full':
      case 'full code':
        return colors.success;
      case 'limited':
        return colors.brandAccent;
      default:
        return colors.subdued;
    }
  }

  /// Get the tooltip/description for a code status
  static String getTooltip(String status) {
    switch (status.toLowerCase().trim()) {
      case 'dnr':
        return 'DNR: Do Not Resuscitate';
      case 'dni':
        return 'DNI: Do Not Intubate';
      case 'full':
      case 'full code':
        return 'Full Code: All resuscitative efforts';
      case 'limited':
        return 'Limited Code: Some interventions only';
      default:
        return 'Code Status: Unspecified';
    }
  }

  /// Get both icon and color in one call for efficiency
  static CodeStatusStyle getStyle(String status, AppColors colors) {
    return CodeStatusStyle(
      icon: getIcon(status),
      color: getColor(status, colors),
      tooltip: getTooltip(status),
    );
  }
}

/// Data class to hold code status styling information
class CodeStatusStyle {
  final IconData icon;
  final Color color;
  final String tooltip;

  const CodeStatusStyle({
    required this.icon,
    required this.color,
    required this.tooltip,
  });
}
