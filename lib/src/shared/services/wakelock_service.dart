import 'dart:io';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Service for managing device wakelock during file transfers.
///
/// Keeps the device screen on during active transfers to prevent
/// the screen from turning off and interrupting the connection.
class WakelockService {
  /// Enable wakelock to keep screen on
  Future<void> enable() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await WakelockPlus.enable();
    }
  }

  /// Disable wakelock to allow screen to turn off
  Future<void> disable() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await WakelockPlus.disable();
    }
  }

  /// Check if wakelock is currently enabled
  Future<bool> isEnabled() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        return await WakelockPlus.enabled;
      } on Exception {
        return false;
      }
    }
    return false;
  }
}
