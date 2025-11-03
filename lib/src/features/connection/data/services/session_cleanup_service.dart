import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing Firestore session lifecycle and cleanup.
///
/// Handles session expiration and cleanup since server-side TTL
/// is not available on Firebase free tier.
class SessionCleanupService {
  SessionCleanupService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  /// Delete a specific session by ID.
  ///
  /// Called by sender after transfer completion or cancellation.
  Future<void> deleteSession(String sessionId) async {
    try {
      await _firestore.collection('sessions').doc(sessionId).delete();
    } on FirebaseException {
      // Silently fail - session might already be deleted or not exist
      // This is not a critical error
    }
  }

  /// Check if a session is expired based on timestamp.
  ///
  /// Returns true if session is older than 15 minutes.
  bool isSessionExpired(DateTime createdAt) {
    final now = DateTime.now();
    final expirationTime = createdAt.add(const Duration(minutes: 15));
    return now.isAfter(expirationTime);
  }

  /// Delete expired sessions (batch cleanup).
  ///
  /// Can be called periodically on app start or before creating new session.
  /// NOTE: This is optional and not critical for free tier usage.
  Future<void> cleanupExpiredSessions() async {
    try {
      final now = DateTime.now();
      final fifteenMinutesAgo = now.subtract(const Duration(minutes: 15));

      // Query sessions older than 15 minutes
      final querySnapshot = await _firestore
          .collection('sessions')
          .where('createdAt', isLessThan: fifteenMinutesAgo)
          .limit(50) // Limit to avoid excessive reads
          .get();

      // Delete in batch
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      if (querySnapshot.docs.isNotEmpty) {
        await batch.commit();
      }
    } on FirebaseException {
      // Silently fail - cleanup is optional
      // Don't throw error as this is a background operation
    }
  }

  /// Validate session before joining (receiver-side check).
  ///
  /// Returns true if session exists and is not expired.
  Future<bool> isSessionValid(String sessionId) async {
    try {
      final doc = await _firestore.collection('sessions').doc(sessionId).get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data();
      if (data == null || !data.containsKey('createdAt')) {
        return false;
      }

      final createdAt = (data['createdAt'] as Timestamp).toDate();
      return !isSessionExpired(createdAt);
    } on FirebaseException {
      return false;
    }
  }
}
