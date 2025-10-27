import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// Reusable card displaying file information.
///
/// Shows file icon, name, and size with consistent styling.
/// Used in sender and receiver flows.
class FileInfoCard extends StatelessWidget {
  const FileInfoCard({
    required this.fileName,
    required this.fileSize,
    this.highlighted = false,
    super.key,
  });

  /// The name of the file
  final String fileName;

  /// The size of the file in bytes
  final int fileSize;

  /// Whether to use highlighted (primary container) styling
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: highlighted ? colorScheme.primaryContainer : null,
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insert_drive_file_rounded,
                  color: highlighted
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    fileName,
                    style:
                        (highlighted
                                ? theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                  )
                                : theme.textTheme.titleSmall)
                            ?.copyWith(
                              overflow: TextOverflow.ellipsis,
                            ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              UiHelpers.formatFileSize(context, fileSize),
              style:
                  (highlighted
                          ? theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.8,
                              ),
                            )
                          : theme.textTheme.bodySmall)
                      ?.copyWith(
                        overflow: TextOverflow.ellipsis,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
