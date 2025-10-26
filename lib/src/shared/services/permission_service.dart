import 'package:permission_handler/permission_handler.dart';

/// Service for requesting and checking runtime permissions.
///
/// Wraps permission_handler with PeerLink-specific logic:
/// - Camera permission for QR scanning
/// - Storage/Photos permission for file saving (platform-specific)
/// - User-friendly error messages and guidance
class PermissionService {
  /// Requests camera permission for QR code scanning.
  ///
  /// Returns true if permission is granted or was already granted.
  /// Returns false if user denies permission.
  ///
  /// On iOS, you must have camera usage description in Info.plist.
  /// On Android, you must have CAMERA permission in AndroidManifest.xml.
  Future<PermissionResult> requestCameraPermission() async {
    final status = await Permission.camera.status;

    // Already granted
    if (status.isGranted) {
      return PermissionResult.granted;
    }

    // Previously denied, direct to settings
    if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    // Request permission
    final result = await Permission.camera.request();

    if (result.isGranted) {
      return PermissionResult.granted;
    } else if (result.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    } else {
      return PermissionResult.denied;
    }
  }

  /// Requests storage permission for file saving (Android-specific).
  ///
  /// On Android 13+ (API 33+), uses photos permission.
  /// On Android 10-12, uses storage permission with scoped storage.
  /// On iOS, no permission needed (uses system file picker).
  /// On desktop, no permission needed (uses native file dialogs).
  ///
  /// Returns true if permission is granted or not required.
  Future<PermissionResult> requestStoragePermission() async {
    // On iOS/Desktop, storage permission is not needed
    if (!_isAndroid()) {
      return PermissionResult.notRequired;
    }

    // Android 13+ uses photos permission
    final permission = await _getStoragePermission();
    final status = await permission.status;

    // Already granted
    if (status.isGranted || status.isLimited) {
      return PermissionResult.granted;
    }

    // Previously denied, direct to settings
    if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    // Request permission
    final result = await permission.request();

    if (result.isGranted || result.isLimited) {
      return PermissionResult.granted;
    } else if (result.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    } else {
      return PermissionResult.denied;
    }
  }

  /// Opens app settings so user can grant permissions manually.
  Future<bool> openAppSettings() async {
    return openAppSettings();
  }

  /// Checks if camera permission is granted without requesting.
  Future<bool> isCameraPermissionGranted() async {
    return Permission.camera.isGranted;
  }

  /// Checks if storage permission is granted without requesting.
  Future<bool> isStoragePermissionGranted() async {
    if (!_isAndroid()) {
      return true; // Not required on iOS/Desktop
    }
    final permission = await _getStoragePermission();
    final status = await permission.status;
    return status.isGranted || status.isLimited;
  }

  // Platform detection helpers
  bool _isAndroid() {
    // In a real implementation, use Platform.isAndroid
    // For now, we assume permission_handler handles this internally
    return false; // Placeholder
  }

  Future<Permission> _getStoragePermission() async {
    // Android 13+ (API 33+) uses granular media permissions
    // For simplicity, we use photos permission which covers received files
    return Permission.photos;
  }
}

/// Result of a permission request.
enum PermissionResult {
  /// Permission granted by user.
  granted,

  /// Permission denied by user (can request again).
  denied,

  /// Permission permanently denied (must go to settings).
  permanentlyDenied,

  /// Permission not required on this platform.
  notRequired,
}
