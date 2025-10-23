import 'package:peerlink/src/src.dart';

/// Repository interface for WebRTC connection operations
abstract class ConnectionRepository {
  /// Create a new peer connection as sender
  /// Returns the session ID (6-digit code)
  Future<PeerConnection> createConnection();

  /// Join an existing connection as receiver
  /// [sessionId] is the 6-digit code from sender
  Future<PeerConnection> joinConnection(String sessionId);

  /// Add ICE candidate to the connection
  Future<void> addIceCandidate(
    String sessionId,
    Map<String, dynamic> candidate,
  );

  /// Close the connection and cleanup
  Future<void> closeConnection(String sessionId);

  /// Stream of connection state changes
  Stream<PeerConnection> watchConnection(String sessionId);
}

/// Repository interface for Firestore signaling operations
abstract class SignalingRepository {
  /// Create a signaling session in Firestore
  Future<void> createSession(SignalingSession session);

  /// Get a signaling session from Firestore
  Future<SignalingSession?> getSession(String sessionId);

  /// Update session with answer from receiver
  Future<void> updateSessionAnswer(String sessionId, String answer);

  /// Add ICE candidate to session
  Future<void> addCandidate(
    String sessionId,
    Map<String, dynamic> candidate, {
    required bool isOffer,
  });

  /// Delete session from Firestore
  Future<void> deleteSession(String sessionId);

  /// Watch for session changes
  Stream<SignalingSession?> watchSession(String sessionId);
}
