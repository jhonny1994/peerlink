import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Keyboard shortcut intents for the app.
class SelectFileIntent extends Intent {
  const SelectFileIntent();
}

class CopyCodeIntent extends Intent {
  const CopyCodeIntent();
}

class CancelIntent extends Intent {
  const CancelIntent();
}

/// Keyboard shortcut mappings for desktop platforms.
class AppKeyboardShortcuts {
  /// Check if current platform supports keyboard shortcuts.
  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  /// Get keyboard shortcuts map.
  static Map<ShortcutActivator, Intent> get shortcuts => {
    // Ctrl/Cmd+O: Open file picker
    LogicalKeySet(
      defaultTargetPlatform == TargetPlatform.macOS
          ? LogicalKeyboardKey.meta
          : LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyO,
    ): const SelectFileIntent(),

    // Ctrl/Cmd+C: Copy code (when applicable)
    LogicalKeySet(
      defaultTargetPlatform == TargetPlatform.macOS
          ? LogicalKeyboardKey.meta
          : LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyC,
    ): const CopyCodeIntent(),

    // ESC: Cancel/Go back
    LogicalKeySet(LogicalKeyboardKey.escape): const CancelIntent(),
  };
}
