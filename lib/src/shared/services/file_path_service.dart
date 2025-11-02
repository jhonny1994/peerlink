import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:peerlink/src/src.dart';

/// Service for managing platform-specific file paths.
///
/// Provides methods to get appropriate directories for saving files
/// based on the current platform (desktop vs mobile).
class FilePathService {
  /// Get platform-specific download/save directory.
  ///
  /// On desktop (Windows, macOS, Linux): Returns Downloads directory,
  /// falls back to Documents if unavailable.
  ///
  /// On mobile (Android, iOS): Returns application documents directory.
  Future<Directory> getDownloadDirectory() async {
    // For desktop, use Downloads directory
    if (PlatformHelper.isDesktopPlatform) {
      final directory = await getDownloadsDirectory();
      if (directory != null) {
        return directory;
      }
      // Fallback to application documents if Downloads not available
      return getApplicationDocumentsDirectory();
    }

    // For mobile, use application documents directory
    return getApplicationDocumentsDirectory();
  }

  /// Get temporary directory for the current platform.
  Future<Directory> getTemporaryDirectory() async {
    return getTemporaryDirectory();
  }

  /// Get application support directory for the current platform.
  Future<Directory> getApplicationSupportDirectory() async {
    return getApplicationSupportDirectory();
  }
}
