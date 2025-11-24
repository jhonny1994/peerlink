import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// A container that applies a glassmorphism effect (blur + transparency).
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.borderRadius,
    this.border,
    this.color,
    super.key,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = borderRadius ?? AppRadius.borderRadiusLg;

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (color ?? theme.colorScheme.surface).withValues(
              alpha: opacity,
            ),
            borderRadius: effectiveBorderRadius,
            border:
                border ??
                Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.2,
                  ),
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
