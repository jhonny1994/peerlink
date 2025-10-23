/// WebRTC connection state
enum ConnectionState {
  /// Not connected
  disconnected,

  /// Gathering ICE candidates
  gathering,

  /// Connecting to peer
  connecting,

  /// Connected to peer
  connected,

  /// Connection failed
  failed,

  /// Connection closed
  closed,
}

/// Represents a WebRTC peer connection session
class PeerConnection {
  const PeerConnection({
    required this.sessionId,
    required this.state,
    this.localDescription,
    this.remoteDescription,
    this.iceCandidates = const [],
    this.error,
  });

  /// Unique session identifier (6-digit code)
  final String sessionId;

  /// Current connection state
  final ConnectionState state;

  /// Local SDP offer/answer
  final String? localDescription;

  /// Remote SDP offer/answer
  final String? remoteDescription;

  /// ICE candidates for NAT traversal
  final List<Map<String, dynamic>> iceCandidates;

  /// Error message if connection failed
  final String? error;

  PeerConnection copyWith({
    String? sessionId,
    ConnectionState? state,
    String? localDescription,
    String? remoteDescription,
    List<Map<String, dynamic>>? iceCandidates,
    String? error,
  }) {
    return PeerConnection(
      sessionId: sessionId ?? this.sessionId,
      state: state ?? this.state,
      localDescription: localDescription ?? this.localDescription,
      remoteDescription: remoteDescription ?? this.remoteDescription,
      iceCandidates: iceCandidates ?? this.iceCandidates,
      error: error ?? this.error,
    );
  }

  @override
  String toString() => 'PeerConnection(sessionId: $sessionId, state: $state)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeerConnection &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId &&
          state == other.state;

  @override
  int get hashCode => sessionId.hashCode ^ state.hashCode;
}
