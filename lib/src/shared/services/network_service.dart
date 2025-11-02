import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for checking network connectivity
class NetworkService {
  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  /// On desktop, assumes connection is available if not explicitly offline
  Future<bool> hasConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      // Handle desktop platforms where connectivity_plus may return limited results
      if (connectivityResult.isEmpty) {
        // On desktop (Windows, macOS, Linux), assume connected if no explicit offline
        return !Platform.isAndroid && !Platform.isIOS;
      }

      // Check if any connection type is available
      return connectivityResult.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet,
      );
    } on Exception {
      // If connectivity check fails, assume connected
      // The actual WebRTC connection will fail if there's no network
      return true;
    }
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((
      List<ConnectivityResult> result,
    ) {
      // Handle empty results on desktop
      if (result.isEmpty) {
        return !Platform.isAndroid && !Platform.isIOS;
      }

      return result.any(
        (r) =>
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.ethernet,
      );
    });
  }
}
