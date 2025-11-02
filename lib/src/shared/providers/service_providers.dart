import 'package:peerlink/src/src.dart';
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

/// Provider for [NetworkService].
///
/// Singleton instance for network connectivity checking.
@Riverpod(keepAlive: true)
NetworkService networkService(Ref ref) {
  return NetworkService();
}

/// Provider for [WakelockService].
///
/// Singleton instance for managing device wakelock during transfers.
@riverpod
WakelockService wakelockService(Ref ref) {
  return WakelockService();
}
