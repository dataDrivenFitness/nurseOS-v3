// lib/shared/widgets/app_snackbar.dart
//
// ─────────────────────────────────────────────────────────────────────────────
//  NurseOS v2 • Centralized Snackbar System
//  ------------------------------------------
//  * Single source of truth for all SnackBar styling and behavior
//  * Automatically uses AppColors theme and supports text scaling
//  * Provides semantic types (success, error, info, warning) with appropriate colors
//  * Handles common patterns: loading states, actions, custom durations
//
//  Usage Examples
//  ──────────────
//  // Basic success message
//  AppSnackbar.success(context, 'Shift started successfully');
//
//  // Error with retry action
//  AppSnackbar.error(
//    context,
//    'Failed to save patient data',
//    action: SnackBarAction(
//      label: 'Retry',
//      onPressed: () => _retryOperation(),
//    ),
//  );
//
//  // Loading state
//  AppSnackbar.loading(context, 'Saving patient...');
//
//  // Custom color and duration
//  AppSnackbar.custom(
//    context,
//    'Custom notification',
//    backgroundColor: Colors.purple,
//    duration: Duration(seconds: 5),
//  );
//
//  Architecture Alignment
//  ─────────────────────
//  • Uses AppColors theme extension for consistent theming
//  • Supports MediaQuery text scaling for accessibility
//  • Follows NurseOS v2 patterns with static utility methods
//  • Centralized to prevent style drift across features
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';

/// Centralized snackbar system for consistent messaging across NurseOS
class AppSnackbar {
  // Private constructor to prevent instantiation
  AppSnackbar._();

  // Default durations for different message types
  static const Duration _defaultDuration = Duration(seconds: 3);
  static const Duration _errorDuration = Duration(seconds: 5);
  static const Duration _loadingDuration = Duration(seconds: 30);

  /// Show a success snackbar with green background
  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onVisible,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    _showSnackbar(
      context,
      message: message,
      backgroundColor: colors.success,
      textColor: Colors.white,
      duration: duration ?? _defaultDuration,
      action: action,
      onVisible: onVisible,
    );
  }

  /// Show an error snackbar with red background
  static void error(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onVisible,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    _showSnackbar(
      context,
      message: message,
      backgroundColor: colors.danger,
      textColor: Colors.white,
      duration: duration ?? _errorDuration,
      action: action,
      onVisible: onVisible,
    );
  }

  /// Show a warning snackbar with orange background
  static void warning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onVisible,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    _showSnackbar(
      context,
      message: message,
      backgroundColor: colors.warning,
      textColor: Colors.white,
      duration: duration ?? _defaultDuration,
      action: action,
      onVisible: onVisible,
    );
  }

  /// Show an info snackbar with primary brand color
  static void info(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onVisible,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    _showSnackbar(
      context,
      message: message,
      backgroundColor: colors.brandPrimary,
      textColor: Colors.white,
      duration: duration ?? _defaultDuration,
      action: action,
      onVisible: onVisible,
    );
  }

  /// Show a loading snackbar with spinner and neutral background
  static void loading(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onVisible,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textScaler = MediaQuery.textScalerOf(context);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: textScaler.scale(16),
              height: textScaler.scale(16),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: textScaler.scale(14),
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.brandNeutral,
        duration: duration ?? _loadingDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(SpacingTokens.md),
        onVisible: onVisible,
      ),
    );
  }

  /// Show a custom snackbar with specified colors and options
  static void custom(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    Color textColor = Colors.white,
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onVisible,
    IconData? icon,
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      duration: duration ?? _defaultDuration,
      action: action,
      onVisible: onVisible,
      icon: icon,
    );
  }

  /// Show a snackbar using medication purple theme
  static void medication(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    VoidCallback? onVisible,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    _showSnackbar(
      context,
      message: message,
      backgroundColor: colors.medicationPurple,
      textColor: Colors.white,
      duration: duration ?? _defaultDuration,
      action: action,
      onVisible: onVisible,
      icon: Icons.medication,
    );
  }

  /// Private helper method to show snackbar with consistent styling
  static void _showSnackbar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required Duration duration,
    SnackBarAction? action,
    VoidCallback? onVisible,
    IconData? icon,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);

    // Clear any existing snackbars to prevent stacking
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: textScaler.scale(18),
                color: textColor,
              ),
              const SizedBox(width: SpacingTokens.sm),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: textScaler.scale(14),
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action != null
            ? SnackBarAction(
                label: action.label,
                onPressed: action.onPressed,
                textColor: textColor,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(SpacingTokens.md),
        onVisible: onVisible,
      ),
    );
  }
}

/// Extension methods for quick access to common snackbar patterns
extension AppSnackbarExtensions on BuildContext {
  /// Quick success snackbar
  void showSuccess(String message, {SnackBarAction? action}) {
    AppSnackbar.success(this, message, action: action);
  }

  /// Quick error snackbar
  void showError(String message, {SnackBarAction? action}) {
    AppSnackbar.error(this, message, action: action);
  }

  /// Quick warning snackbar
  void showWarning(String message, {SnackBarAction? action}) {
    AppSnackbar.warning(this, message, action: action);
  }

  /// Quick info snackbar
  void showInfo(String message, {SnackBarAction? action}) {
    AppSnackbar.info(this, message, action: action);
  }

  /// Quick loading snackbar
  void showLoading(String message) {
    AppSnackbar.loading(this, message);
  }
}
