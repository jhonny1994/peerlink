import 'package:freezed_annotation/freezed_annotation.dart';

part 'peer_connection.freezed.dart';

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
@freezed
abstract class PeerConnection with _$PeerConnection {
  const factory PeerConnection({
    /// Unique session identifier (6-digit code)
    required String sessionId,

    /// Current connection state
    required ConnectionState state,

    /// Local SDP offer/answer
    String? localDescription,

    /// Remote SDP offer/answer
    String? remoteDescription,

    /// ICE candidates for NAT traversal
    @Default([]) List<Map<String, dynamic>> iceCandidates,

    /// Error message if connection failed
    String? error,
  }) = _PeerConnection;
}
