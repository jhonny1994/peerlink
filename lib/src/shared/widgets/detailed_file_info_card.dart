import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// Detailed file information card with optional warnings and connection info.
///
/// Extends basic file info display with additional context for acceptance screens.
class DetailedFileInfoCard extends StatelessWidget {
  const DetailedFileInfoCard({
    required this.fileName,
    required this.fileSize,
    this.warningText,
    this.connectionInfo,
    super.key,
  });

  final String fileName;
  final int fileSize;
  final String? warningText;
  final String? connectionInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: AppSpacing.cardPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File icon and name
            Row(
              children: [
                Icon(
                  Icons.insert_drive_file_rounded,
                  size: AppIconSize.xxl,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        UiHelpers.formatFileSize(context, fileSize),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Optional warning
            if (warningText != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      size: AppIconSize.sm,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        warningText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Optional connection info
            if (connectionInfo != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: AppIconSize.sm,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        connectionInfo!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
