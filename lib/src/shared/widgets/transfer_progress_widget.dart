import 'package:flutter/material.dart';
import 'package:peerlink/src/core/constants/ui_constants.dart';
import 'package:peerlink/src/shared/localization/generated/l10n.dart';

/// Reusable transfer progress widget for sender and receiver flows.
///
/// Displays:
/// - File name
/// - Progress percentage
/// - Transfer speed (MB/s)
/// - Linear progress indicator
/// - Optional cancel button
///
/// Follows Material You design with proper spacing and typography.
class TransferProgressWidget extends StatelessWidget {
  const TransferProgressWidget({
    required this.fileName,
    required this.progressPercentage,
    required this.transferSpeedMbps,
    this.onCancel,
    this.isSending = true,
    super.key,
  });

  /// Name of the file being transferred.
  final String fileName;

  /// Progress percentage (0.0 to 1.0).
  final double progressPercentage;

  /// Transfer speed in MB/s.
  final double transferSpeedMbps;

  /// Optional callback when user taps cancel button.
  /// If null, cancel button is not shown.
  final VoidCallback? onCancel;

  /// Whether this is a send operation (true) or receive operation (false).
  /// Used for appropriate labeling.
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = S.of(context);

    // Format percentage
    final percentageText = '${(progressPercentage * 100).toStringAsFixed(0)}%';

    // Format transfer speed
    final speedText = '${transferSpeedMbps.toStringAsFixed(1)} MB/s';

    return Card(
      elevation: AppElevation.none,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: AppSpacing.cardPaddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Operation text
            Row(
              children: [
                Icon(
                  isSending ? Icons.upload_rounded : Icons.download_rounded,
                  size: AppIconSize.xl,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  isSending ? l10n.sendingFile : l10n.receivingFile,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // File name
            Text(
              fileName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Progress indicator
            ClipRRect(
              borderRadius: AppRadius.borderRadiusSm,
              child: LinearProgressIndicator(
                value: progressPercentage,
                minHeight: AppDimensions.progressBarHeight,
                backgroundColor: colorScheme.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Stats row: Percentage + Speed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Percentage
                Text(
                  percentageText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Speed
                Row(
                  children: [
                    Icon(
                      Icons.speed_rounded,
                      size: AppIconSize.xs,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      speedText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Cancel button (if callback provided)
            if (onCancel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close_rounded),
                  label: Text(l10n.cancelTransfer),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
