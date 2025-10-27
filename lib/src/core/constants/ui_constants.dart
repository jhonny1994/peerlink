/// UI constants for consistent spacing, sizing, and styling across the app.
///
/// Follows Material Design 3 spacing guidelines with 4px base unit.
/// All values are in logical pixels (dp on Android, points on iOS).
library;

import 'package:flutter/material.dart';

/// Spacing constants following Material Design 3 (4px base unit).
abstract class AppSpacing {
  // Vertical spacing
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  // Common padding values
  static const EdgeInsets screenPadding = EdgeInsets.all(xl);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(xl);
  static const EdgeInsets buttonPaddingVertical = EdgeInsets.symmetric(
    vertical: lg,
  );
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: xxl,
    vertical: 20,
  );
}

/// Border radius constants for consistent rounded corners.
abstract class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  // BorderRadius values
  static const Radius radiusSm = Radius.circular(sm);
  static const Radius radiusMd = Radius.circular(md);
  static const Radius radiusLg = Radius.circular(lg);
  static const Radius radiusXl = Radius.circular(xl);

  // BorderRadius objects
  static final BorderRadius borderRadiusSm = BorderRadius.circular(sm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(md);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(lg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(xl);
}

/// Icon size constants for consistent icon sizing.
abstract class AppIconSize {
  static const double xs = 16;
  static const double sm = 20;
  static const double md = 24;
  static const double lg = 28;
  static const double xl = 32;
  static const double xxl = 48;
  static const double huge = 80;
  static const double logo = 120;
}

/// Widget dimension constants.
abstract class AppDimensions {
  // Loading indicators
  static const double loadingIndicatorSmall = 20;
  static const double loadingIndicatorStrokeWidth = 2;

  // QR Code
  static const double qrCodeSize = 200;

  // Progress indicators
  static const double progressBarHeight = 8;

  // Content max widths
  static const double contentMaxWidth = 500;

  // Letter spacing
  static const double codeLetterSpacing = 8;
}

/// Elevation constants (Material Design 3).
abstract class AppElevation {
  static const double none = 0;
  static const double sm = 1;
  static const double md = 3;
  static const double lg = 6;
  static const double xl = 8;
}

/// Typography scale constants (font sizes).
abstract class AppFontSize {
  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double xxl = 24;
}
