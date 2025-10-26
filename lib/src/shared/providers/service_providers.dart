import 'package:peerlink/src/shared/services/file_picker_service.dart';
import 'package:peerlink/src/shared/services/permission_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_providers.g.dart';

/// Provider for [FilePickerService].
///
/// Singleton instance for file picking with validation.
@riverpod
FilePickerService filePickerService(Ref ref) {
  return FilePickerService();
}

/// Provider for [PermissionService].
///
/// Singleton instance for runtime permission handling.
@riverpod
PermissionService permissionService(Ref ref) {
  return PermissionService();
}
