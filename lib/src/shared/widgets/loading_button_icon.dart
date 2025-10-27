import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// Reusable loading indicator for buttons.
///
/// Shows a small circular progress indicator that fits
/// within button icon space.
class LoadingButtonIcon extends StatelessWidget {
  const LoadingButtonIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: AppDimensions.loadingIndicatorSmall,
      height: AppDimensions.loadingIndicatorSmall,
      child: CircularProgressIndicator(
        strokeWidth: AppDimensions.loadingIndicatorStrokeWidth,
      ),
    );
  }
}
