import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// UI utilities for displaying errors, snackbars, and dialogs.
///
/// Provides consistent, user-friendly error messaging across the app.
/// All methods follow Material You design guidelines.
class UiHelpers {
  UiHelpers._();

  /// Shows a snackbar with an error message.
  ///
  /// Used for non-critical errors that don't block the flow.
  static void showErrorSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;

    final l10n = S.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: SnackBarAction(
          label: l10n.dismiss,
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Shows a snackbar with a success message.
  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: colorScheme.onPrimary),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  /// Shows an error dialog for critical errors that require user acknowledgment.
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) async {
    if (!context.mounted) return;

    final l10n = S.of(context);

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error_outline_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText ?? l10n.ok),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog with Yes/No options.
  ///
  /// Returns true if user confirms, false if user cancels.
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerousAction = false,
  }) async {
    if (!context.mounted) return false;

    final l10n = S.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText ?? l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: isDangerousAction
                  ? FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    )
                  : null,
              child: Text(confirmText ?? l10n.confirm),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// Shows a loading dialog that can be dismissed programmatically.
  ///
  /// Call Navigator.pop() to dismiss.
  static Future<void> showLoadingDialog(
    BuildContext context, {
    String? message,
  }) async {
    if (!context.mounted) return;

    final l10n = S.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Expanded(child: Text(message ?? l10n.pleaseWait)),
            ],
          ),
        ),
      ),
    );
  }

  /// Formats a file size in bytes to a human-readable string.
  ///
  /// Examples:
  /// - 512 → "512 B"
  /// - 1536 → "1.5 KB"
  /// - 5242880 → "5.0 MB"
  static String formatFileSize(BuildContext context, int bytes) {
    final l10n = S.of(context);

    if (bytes < 1024) {
      return '$bytes ${l10n.unitBytes}';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} ${l10n.unitKilobytes}';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ${l10n.unitMegabytes}';
    }
  }
}
