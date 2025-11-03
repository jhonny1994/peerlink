import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Firebase Cloud Messaging (FCM).
///
/// Handles FCM token management and silent notifications for WebRTC signaling.
/// Note: FCM is available on free tier but has usage quotas.
class FcmService {
  final FirebaseMessaging _messaging;

  FcmService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  /// Initialize FCM and request notification permissions.
  ///
  /// Returns the FCM token if successful, null otherwise.
  Future<String?> initialize() async {
    try {
      // Request permission (iOS only, Android auto-grants)
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        final token = await _messaging.getToken();
        
        if (kDebugMode) {
          print('FCM Token: $token');
        }
        
        return token;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('FCM initialization error: $e');
      }
      return null;
    }
  }

  /// Get the current FCM token.
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Delete the current FCM token.
  ///
  /// Useful for logout or privacy features.
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      // Silently fail
    }
  }

  /// Listen to token refresh events.
  ///
  /// FCM tokens can be refreshed by the system.
  /// Returns a stream of new tokens.
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Handle background messages.
  ///
  /// This must be a top-level function for background execution.
  /// Currently not implemented as we use WebRTC data channels for signaling.
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    // Handle background message
    // For PeerLink, we primarily use Firestore for signaling
    // so background FCM is optional
    if (kDebugMode) {
      print('Background message: ${message.messageId}');
    }
  }

  /// Configure foreground message handling.
  ///
  /// Returns a stream of messages received while app is in foreground.
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  /// Configure message tap handling (when notification is tapped).
  ///
  /// Returns a stream of messages from notification taps.
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// Get the initial message if app was opened from notification.
  Future<RemoteMessage?> getInitialMessage() async {
    return _messaging.getInitialMessage();
  }
}
