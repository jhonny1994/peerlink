import 'package:flutter/material.dart';

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

    // Format percentage
    final percentageText = '${(progressPercentage * 100).toStringAsFixed(0)}%';

    // Format transfer speed
    final speedText = '${transferSpeedMbps.toStringAsFixed(1)} MB/s';

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Operation text
            Row(
              children: [
                Icon(
                  isSending ? Icons.upload_rounded : Icons.download_rounded,
                  size: 32,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  isSending ? 'Sending file...' : 'Receiving file...',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // File name
            Text(
              fileName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Progress indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressPercentage,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),

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
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cancel Transfer'),
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
