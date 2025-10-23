/// WebRTC connection configuration constants
class ConnectionConstants {
  ConnectionConstants._();

  /// Maximum time to wait for ICE gathering to complete (seconds)
  static const int iceGatherTimeoutSec = 10;

  /// Maximum time to wait for connection establishment (seconds)
  static const int connectionTimeoutSec = 30;

  /// Maximum time to wait before considering transfer stalled (seconds)
  static const int transferStallTimeoutSec = 20;

  /// STUN servers for NAT traversal
  static const List<Map<String, dynamic>> stunServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun2.l.google.com:19302'},
  ];

  /// TURN server for relay (free tier - openrelay.metered.ca)
  static const List<Map<String, dynamic>> turnServers = [
    {
      'urls': 'turn:openrelay.metered.ca:80',
      'username': 'openrelayproject',
      'credential': 'openrelayproject',
    },
  ];

  /// Combined ICE servers (STUN + TURN)
  static List<Map<String, dynamic>> get iceServers => [
        ...stunServers,
        ...turnServers,
      ];

  /// WebRTC configuration for RTCPeerConnection
  static Map<String, dynamic> get rtcConfiguration => {
        'iceServers': iceServers,
        'iceTransportPolicy': 'all',
        'iceCandidatePoolSize': 0,
      };
}
