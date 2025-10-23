/// Firestore session data for signaling
class SignalingSession {
  const SignalingSession({
    required this.sessionId,
    required this.offer,
    required this.createdAt,
    required this.expiresAt,
    this.answer,
    this.offerCandidates = const [],
    this.answerCandidates = const [],
  });

  /// Unique session identifier (6-digit code)
  final String sessionId;

  /// SDP offer from sender
  final String offer;

  /// SDP answer from receiver (null until receiver responds)
  final String? answer;

  /// ICE candidates from sender
  final List<Map<String, dynamic>> offerCandidates;

  /// ICE candidates from receiver
  final List<Map<String, dynamic>> answerCandidates;

  /// Session creation timestamp
  final DateTime createdAt;

  /// Session expiration timestamp (15 minutes after creation)
  final DateTime expiresAt;

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'offer': offer,
      'answer': answer,
      'offerCandidates': offerCandidates,
      'answerCandidates': answerCandidates,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory SignalingSession.fromFirestore(
    String sessionId,
    Map<String, dynamic> data,
  ) {
    return SignalingSession(
      sessionId: sessionId,
      offer: data['offer'] as String,
      answer: data['answer'] as String?,
      offerCandidates: (data['offerCandidates'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      answerCandidates: (data['answerCandidates'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      createdAt: DateTime.parse(data['createdAt'] as String),
      expiresAt: DateTime.parse(data['expiresAt'] as String),
    );
  }

  @override
  String toString() => 'SignalingSession(sessionId: $sessionId)';
}
