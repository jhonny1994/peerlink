import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Firebase Cloud Messaging (FCM).
///
/// Handles FCM token management and notification permissions for WebRTC signaling.
///
/// Production notes:
/// - FCM is available on Firebase free tier but has usage quotas
/// - All methods handle exceptions gracefully and fail silently
/// - Debug logging only enabled in debug mode
/// - Background message handling must be top-level function
///
/// Platform behavior:
/// - iOS: Requires explicit permission request
/// - Android: Auto-grants notification permission
/// - Web: Requires user interaction for permission
class FcmService {
  FcmService({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;
  final FirebaseMessaging _messaging;

  /// Initialize FCM and request notification permissions.
  ///
  /// Platform-specific behavior:
  /// - iOS: Shows system permission dialog
  /// - Android: Auto-grants permission
  ///
  /// Returns the FCM token if successful, null otherwise.
  /// Failures are logged in debug mode but don't throw exceptions.
  Future<String?> initialize() async {
    try {
      // Request permission (iOS requires explicit request, Android auto-grants)
      final settings = await _messaging.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        final token = await _messaging.getToken();

        if (kDebugMode && token != null) {
          debugPrint(
            'FCM initialized successfully. Token: ${token.substring(0, 20)}...',
          );
        }

        return token;
      }

      if (kDebugMode) {
        debugPrint('FCM permission denied: ${settings.authorizationStatus}');
      }

      return null;
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('FCM initialization failed: $e');
      }
      return null;
    }
  }

  /// Get the current FCM token.
  ///
  /// Returns null if token is unavailable or an error occurs.
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get FCM token: $e');
      }
      return null;
    }
  }

  /// Delete the current FCM token.
  ///
  /// Useful for privacy features or when user logs out.
  /// Fails silently if deletion is unsuccessful.
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      if (kDebugMode) {
        debugPrint('FCM token deleted successfully');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to delete FCM token: $e');
      }
    }
  }

  /// Listen to token refresh events.
  ///
  /// FCM tokens can be refreshed by the system periodically.
  /// Returns a stream of new tokens that should be persisted.
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Handle background messages.
  ///
  /// IMPORTANT: This must be a top-level function for background execution.
  /// Cannot access instance members or use BuildContext.
  ///
  /// For PeerLink, WebRTC signaling primarily uses Firestore.
  /// FCM is reserved for future notification features.
  @pragma('vm:entry-point')
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('Background FCM message received: ${message.messageId}');
      debugPrint('  Data: ${message.data}');
      debugPrint('  Notification: ${message.notification?.title}');
    }
    // Future: Handle background notification actions
  }

  /// Configure foreground message handling.
  ///
  /// Returns a stream of messages received while app is in foreground.
  /// Use this to show in-app notifications or update UI.
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  /// Configure message tap handling (when notification is tapped).
  ///
  /// Returns a stream of messages from notification taps that opened the app.
  /// Use this to navigate to specific screens based on notification data.
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// Get the initial message if app was opened from a terminated state.
  ///
  /// Returns the notification message that launched the app, or null if
  /// the app was opened normally.
  Future<RemoteMessage?> getInitialMessage() async {
    try {
      return await _messaging.getInitialMessage();
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get initial FCM message: $e');
      }
      return null;
    }
  }
}
