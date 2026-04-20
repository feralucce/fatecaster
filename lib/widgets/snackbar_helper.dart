import 'package:flutter/material.dart';

/// Type of snackbar notification.
enum SnackbarType { success, error, info, warning }

/// Helpers for showing themed snackbar (toast-style) notifications.
///
/// Usage:
/// ```dart
/// SnackbarHelper.show(
///   context,
///   message: 'Room created successfully!',
///   type: SnackbarType.success,
/// );
///
/// SnackbarHelper.showError(
///   context,
///   message: 'Failed to join room.',
///   onRetry: () => _retry(),
/// );
/// ```
class SnackbarHelper {
  SnackbarHelper._();

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  static const Duration _defaultDuration = Duration(seconds: 3);
  static const Duration _errorDuration = Duration(seconds: 5);

  // ---------------------------------------------------------------------------
  // Public helpers
  // ---------------------------------------------------------------------------

  /// Show a snackbar with automatic styling based on [type].
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration? duration,
    VoidCallback? onRetry,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      type: type,
      duration: duration ?? (type == SnackbarType.error ? _errorDuration : _defaultDuration),
      onRetry: onRetry,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Shorthand for a success snackbar.
  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.success);
  }

  /// Shorthand for an error snackbar with optional retry.
  static void showError(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.error,
      onRetry: onRetry,
    );
  }

  /// Shorthand for an info snackbar.
  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.info);
  }

  /// Shorthand for a warning snackbar.
  static void showWarning(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.warning);
  }

  // ---------------------------------------------------------------------------
  // Internal implementation
  // ---------------------------------------------------------------------------

  static void _show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    required Duration duration,
    VoidCallback? onRetry,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final colors = _colorsForType(type, theme);

    SnackBarAction? action;
    if (onRetry != null) {
      action = SnackBarAction(
        label: 'Retry',
        textColor: colors.foreground,
        onPressed: onRetry,
      );
    } else if (onAction != null && actionLabel != null) {
      action = SnackBarAction(
        label: actionLabel,
        textColor: colors.foreground,
        onPressed: onAction,
      );
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(_iconForType(type), color: colors.foreground, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colors.foreground),
            ),
          ),
        ],
      ),
      backgroundColor: colors.background,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
      action: action,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static IconData _iconForType(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_outline_rounded;
      case SnackbarType.error:
        return Icons.error_outline_rounded;
      case SnackbarType.warning:
        return Icons.warning_amber_rounded;
      case SnackbarType.info:
        return Icons.info_outline_rounded;
    }
  }

  static _SnackbarColors _colorsForType(SnackbarType type, ThemeData theme) {
    switch (type) {
      case SnackbarType.success:
        return const _SnackbarColors(
          background: Color(0xFF2E7D32),
          foreground: Colors.white,
        );
      case SnackbarType.error:
        return _SnackbarColors(
          background: theme.colorScheme.error,
          foreground: theme.colorScheme.onError,
        );
      case SnackbarType.warning:
        return const _SnackbarColors(
          background: Color(0xFFF57F17),
          foreground: Colors.white,
        );
      case SnackbarType.info:
        return _SnackbarColors(
          background: theme.colorScheme.secondary,
          foreground: theme.colorScheme.onSecondary,
        );
    }
  }
}

class _SnackbarColors {
  final Color background;
  final Color foreground;
  const _SnackbarColors({required this.background, required this.foreground});
}
