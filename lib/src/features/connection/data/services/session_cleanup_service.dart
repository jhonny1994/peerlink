import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Firestore session lifecycle and cleanup.
///
/// Provides client-side session management as an alternative to server-side TTL
/// (not available on Firebase free tier).
///
/// Key responsibilities:
/// - Delete sessions after connection closes
/// - Validate sessions before receiver joins
/// - Check session expiration (15-minute timeout)
/// - Optional batch cleanup for expired sessions
///
/// Production usage:
/// - All methods handle FirebaseException gracefully
/// - Failed cleanups are non-critical and fail silently
/// - Session validation returns false on any error
class SessionCleanupService {
  SessionCleanupService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  /// Session expiration duration (15 minutes as per app constants).
  static const _expirationDuration = Duration(minutes: 15);

  /// Maximum number of sessions to cleanup in a single batch operation.
  static const _maxBatchSize = 50;

  /// Delete a specific session by ID.
  ///
  /// Called automatically when:
  /// - Sender closes connection after transfer completion or cancellation
  /// - Receiver closes connection
  ///
  /// Fails silently if:
  /// - Session already deleted
  /// - Session doesn't exist
  /// - Firestore operation fails
  ///
  /// This is a non-critical operation - connection closure proceeds regardless.
  Future<void> deleteSession(String sessionId) async {
    try {
      await _firestore.collection('sessions').doc(sessionId).delete();
    } on FirebaseException catch (e) {
      // Silently fail - session deletion is best-effort cleanup
      // Connection has already closed on WebRTC layer
      if (kDebugMode) {
        debugPrint('Session cleanup failed for $sessionId: ${e.message}');
      }
    }
  }

  /// Check if a session is expired based on timestamp.
  ///
  /// Returns true if session is older than 15 minutes.
  bool isSessionExpired(DateTime createdAt) {
    final now = DateTime.now();
    final expirationTime = createdAt.add(_expirationDuration);
    return now.isAfter(expirationTime);
  }

  /// Delete expired sessions (batch cleanup).
  ///
  /// Can be called periodically on app start or before creating new session.
  /// Limits to [_maxBatchSize] documents to avoid excessive Firestore reads.
  ///
  /// NOTE: This is optional and not critical for free tier usage.
  Future<void> cleanupExpiredSessions() async {
    try {
      final now = DateTime.now();
      final fifteenMinutesAgo = now.subtract(_expirationDuration);

      // Query sessions older than expiration duration
      final querySnapshot = await _firestore
          .collection('sessions')
          .where('createdAt', isLessThan: fifteenMinutesAgo)
          .limit(_maxBatchSize) // Limit to avoid excessive reads
          .get();

      // Delete in batch
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      if (querySnapshot.docs.isNotEmpty) {
        await batch.commit();
        if (kDebugMode) {
          debugPrint(
            'Cleaned up ${querySnapshot.docs.length} expired sessions',
          );
        }
      }
    } on FirebaseException catch (e) {
      // Silently fail - cleanup is optional background operation
      if (kDebugMode) {
        debugPrint('Batch session cleanup failed: ${e.message}');
      }
    }
  }

  /// Validate session before joining (receiver-side check).
  ///
  /// Returns true if:
  /// - Session document exists in Firestore
  /// - Session has valid createdAt timestamp
  /// - Session is not expired (< 15 minutes old)
  ///
  /// Returns false if:
  /// - Session doesn't exist
  /// - Session data is malformed
  /// - Session is expired
  /// - Firestore operation fails
  ///
  /// Used by receiver before attempting WebRTC connection.
  Future<bool> isSessionValid(String sessionId) async {
    try {
      final doc = await _firestore.collection('sessions').doc(sessionId).get();

      if (!doc.exists) {
        if (kDebugMode) {
          debugPrint('Session validation failed: Session $sessionId not found');
        }
        return false;
      }

      final data = doc.data();
      if (data == null || !data.containsKey('createdAt')) {
        if (kDebugMode) {
          debugPrint(
            'Session validation failed: Missing createdAt for $sessionId',
          );
        }
        return false;
      }

      final createdAt = (data['createdAt'] as Timestamp).toDate();
      final isValid = !isSessionExpired(createdAt);

      if (kDebugMode && !isValid) {
        debugPrint('Session validation failed: Session $sessionId expired');
      }

      return isValid;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          'Session validation failed: Firestore error for $sessionId: ${e.message}',
        );
      }
      return false;
    }
  }
}
