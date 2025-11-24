import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// Reusable transfer progress widget for sender and receiver flows.
///
/// Displays:
/// - File name
/// - Progress percentage
/// - Transfer speed (MB/s)
/// - Animated flow progress indicator
/// - Optional cancel button
///
/// Follows Material You design with proper spacing and typography.
class TransferProgressWidget extends StatefulWidget {
  const TransferProgressWidget({
    required this.fileName,
    required this.progressPercentage,
    required this.transferSpeedMbps,
    this.onCancel,
    this.isSending = true,
    super.key,
  });

  final String fileName;
  final double progressPercentage;
  final double transferSpeedMbps;
  final VoidCallback? onCancel;
  final bool isSending;

  @override
  State<TransferProgressWidget> createState() => _TransferProgressWidgetState();
}

class _TransferProgressWidgetState extends State<TransferProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = S.of(context);

    final percentageText =
        '${(widget.progressPercentage * 100).toStringAsFixed(0)}%';
    final speedText = '${widget.transferSpeedMbps.toStringAsFixed(1)} MB/s';

    return Card(
      elevation: AppElevation.none,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: AppSpacing.cardPaddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  widget.isSending
                      ? Icons.upload_rounded
                      : Icons.download_rounded,
                  size: AppIconSize.xl,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  widget.isSending ? l10n.sendingFile : l10n.receivingFile,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // File name
            Text(
              widget.fileName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Animated Flow Progress
            SizedBox(
              height: AppDimensions.progressBarHeight * 2,
              child: ClipRRect(
                borderRadius: AppRadius.borderRadiusSm,
                child: CustomPaint(
                  painter: _FlowProgressPainter(
                    progress: widget.progressPercentage,
                    animationValue: _controller,
                    color: colorScheme.primary,
                    backgroundColor: colorScheme.surfaceContainerHigh,
                  ),
                  child: Container(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  percentageText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

            if (widget.onCancel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: widget.onCancel,
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

class _FlowProgressPainter extends CustomPainter {
  _FlowProgressPainter({
    required this.progress,
    required this.animationValue,
    required this.color,
    required this.backgroundColor,
  }) : super(repaint: animationValue);

  final double progress;
  final Animation<double> animationValue;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Draw background
    canvas.drawRect(Offset.zero & size, paint);

    // Draw progress bar
    paint.color = color.withValues(alpha: 0.3);
    final progressWidth = size.width * progress;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, progressWidth, size.height),
      paint,
    );

    // Draw particles
    paint.color = color;
    const particleCount = 10;
    final spacing = size.width / particleCount;
    final offset = animationValue.value * spacing;

    for (var i = 0; i < particleCount + 2; i++) {
      final x = (i * spacing) + offset - spacing;
      if (x < progressWidth) {
        // Only draw particles inside the progress area
        final opacity = 1.0 - ((x - progressWidth).abs() / 20).clamp(0.0, 1.0);
        if (opacity > 0) {
          paint.color = color.withValues(alpha: opacity);
          canvas.drawCircle(Offset(x, size.height / 2), size.height / 3, paint);
        }
      }
    }

    // Draw solid leading edge
    paint.color = color;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, progressWidth, size.height),
      paint
        ..shader = LinearGradient(
          colors: [color.withValues(alpha: 0.5), color],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, progressWidth, size.height)),
    );
  }

  @override
  bool shouldRepaint(_FlowProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
