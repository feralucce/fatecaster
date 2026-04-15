import 'package:flutter/material.dart';

/// A modal dialog that presents an error message with optional retry /
/// dismiss actions.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => ErrorDialog(
///     title: 'Failed to Join Room',
///     message: 'Room not found. Please check the code.',
///     onRetry: () => _retryJoin(),
///   ),
/// );
/// ```
///
/// Or use the static helper:
/// ```dart
/// ErrorDialog.show(
///   context,
///   title: 'Oops!',
///   message: 'Something went wrong.',
/// );
/// ```
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;

  /// Called when the user taps **Retry**. If `null`, the retry button is
  /// hidden.
  final VoidCallback? onRetry;

  /// Label for the dismiss button. Defaults to `'Dismiss'`.
  final String dismissLabel;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.dismissLabel = 'Dismiss',
  });

  // ---------------------------------------------------------------------------
  // Static helper
  // ---------------------------------------------------------------------------

  /// Show an [ErrorDialog] as a modal using [Navigator].
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    String dismissLabel = 'Dismiss',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: onRetry == null,
      builder: (_) => ErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
        dismissLabel: dismissLabel,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        if (onRetry != null) ...[
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
          const SizedBox(width: 4),
        ],
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor:
                onRetry != null ? colorScheme.surfaceVariant : colorScheme.error,
            foregroundColor: onRetry != null
                ? colorScheme.onSurfaceVariant
                : colorScheme.onError,
          ),
          child: Text(dismissLabel),
        ),
      ],
    );
  }
}
