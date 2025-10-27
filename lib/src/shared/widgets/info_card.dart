import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// Reusable info card with icon and text.
///
/// Used throughout the app to display informational messages
/// with consistent styling and spacing.
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.text,
    this.icon = Icons.info_outline,
    super.key,
  });

  /// The informational text to display
  final String text;

  /// The icon to display (defaults to info_outline)
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
