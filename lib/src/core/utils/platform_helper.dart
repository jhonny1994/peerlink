import 'dart:io';

import 'package:flutter/foundation.dart';

/// Platform detection utilities.
///
/// Provides centralized platform detection to avoid code duplication.
class PlatformHelper {
  PlatformHelper._();

  /// Check if running on desktop platform (Windows, macOS, or Linux).
  ///
  /// Uses [Platform] checks which work for compiled apps.
  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// Check if running on desktop platform using [TargetPlatform].
  ///
  /// Uses [defaultTargetPlatform] which is useful for widget-level checks.
  static bool get isDesktopPlatform =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;
}
