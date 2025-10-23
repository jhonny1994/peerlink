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

  /// Metered TURN API endpoint for dynamic credentials
  /// Provides 20GB/month free, auto-routes to nearest server
  /// Sign up at: https://dashboard.metered.ca/signup?tool=turnserver
  static const String meteredTurnApiUrl =
      'https://peerlink.metered.live/api/v1/turn/credentials';

  /// Static fallback TURN server (if API fails or for development)
  /// Uses static auth - always available but less optimal routing
  static const List<Map<String, dynamic>> staticTurnServers = [
    {
      'urls': 'turn:openrelay.metered.ca:80',
      'username': 'openrelayproject',
      'credential': 'openrelayproject',
    },
    {
      'urls': 'turn:openrelay.metered.ca:443',
      'username': 'openrelayproject',
      'credential': 'openrelayproject',
    },
  ];

  /// Static auth TURN server (alternative - uses shared secret)
  /// For services that require static auth (like Nextcloud Talk)
  static const List<Map<String, dynamic>> staticAuthTurnServers = [
    {
      'urls': 'turn:staticauth.openrelay.metered.ca:80',
      'username': 'openrelayproject',
      'credential': 'openrelayprojectsecret',
    },
    {
      'urls': 'turn:staticauth.openrelay.metered.ca:443',
      'username': 'openrelayproject',
      'credential': 'openrelayprojectsecret',
    },
  ];

  /// Fallback ICE servers (STUN + static TURN)
  /// Used when dynamic TURN API is unavailable
  static List<Map<String, dynamic>> get fallbackIceServers => [
        ...stunServers,
        ...staticTurnServers,
      ];

  /// WebRTC configuration for RTCPeerConnection
  /// Note: In production, fetch dynamic TURN credentials from meteredTurnApiUrl
  /// and merge with stunServers for optimal routing
  static Map<String, dynamic> get rtcConfiguration => {
        'iceServers': fallbackIceServers,
        'iceTransportPolicy': 'all',
        'iceCandidatePoolSize': 0,
      };
}
