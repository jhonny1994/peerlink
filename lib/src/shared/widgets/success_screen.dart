import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// Reusable success/completion screen template.
///
/// Displays a large success icon, message, and action button.
/// Used for both sender and receiver completion screens.
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onButtonPressed,
    super.key,
  });

  /// AppBar title
  final String title;

  /// Success message to display
  final String message;

  /// Label for the action button
  final String buttonLabel;

  /// Callback when button is pressed
  final VoidCallback onButtonPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: AppIconSize.huge,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  message,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                FilledButton.icon(
                  onPressed: onButtonPressed,
                  icon: const Icon(Icons.home_rounded),
                  label: Text(buttonLabel),
                  style: FilledButton.styleFrom(
                    padding: AppSpacing.buttonPaddingVertical,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
