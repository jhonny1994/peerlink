/// WebRTC connection configuration constants
class ConnectionConstants {
  ConnectionConstants._();

  /// Maximum time to wait for ICE gathering to complete (seconds)
  static const int iceGatherTimeoutSec = 10;

  /// Maximum time to wait for connection establishment (seconds)
  static const int connectionTimeoutSec = 30;

  /// Maximum time to wait before considering transfer stalled (seconds)
  static const int transferStallTimeoutSec = 20;

  /// Metered TURN API credentials
  /// API Key for fetching dynamic TURN credentials
  static const String meteredApiKey = 'a9b079453dc5f67777b21c67d286d0d433cd';

  /// Metered TURN API endpoint for dynamic credentials
  /// Provides 20GB/month free, auto-routes to nearest server
  static const String meteredTurnApiUrl =
      'https://carbodex.metered.live/api/v1/turn/credentials?apiKey=$meteredApiKey';

  /// STUN servers for NAT traversal (Metered + Google)
  static const List<Map<String, dynamic>> stunServers = [
    {'urls': 'stun:stun.relay.metered.ca:80'},
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
  ];

  /// Static TURN credentials (fallback if API fails)
  /// Username and credential for direct TURN server access
  static const String meteredUsername = 'd0fd9d04bc1b25ee582a241d';
  static const String meteredCredential = 'kGl6lfn3UZ76x808';

  /// Static TURN servers (fallback if API fails)
  /// Uses hardcoded credentials - always available
  static const List<Map<String, dynamic>> staticTurnServers = [
    {
      'urls': 'turn:standard.relay.metered.ca:80',
      'username': meteredUsername,
      'credential': meteredCredential,
    },
    {
      'urls': 'turn:standard.relay.metered.ca:80?transport=tcp',
      'username': meteredUsername,
      'credential': meteredCredential,
    },
    {
      'urls': 'turn:standard.relay.metered.ca:443',
      'username': meteredUsername,
      'credential': meteredCredential,
    },
    {
      'urls': 'turns:standard.relay.metered.ca:443?transport=tcp',
      'username': meteredUsername,
      'credential': meteredCredential,
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
