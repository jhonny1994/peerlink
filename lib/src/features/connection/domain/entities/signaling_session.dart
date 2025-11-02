import 'package:freezed_annotation/freezed_annotation.dart';

part 'signaling_session.freezed.dart';
part 'signaling_session.g.dart';

/// Firestore session data for signaling
@freezed
abstract class SignalingSession with _$SignalingSession {
  const factory SignalingSession({
    /// Unique session identifier (6-digit code)
    required String sessionId,

    /// SDP offer from sender
    required String offer,

    /// Session creation timestamp
    required DateTime createdAt,

    /// Session expiration timestamp (15 minutes after creation)
    required DateTime expiresAt,

    /// SDP answer from receiver (null until receiver responds)
    String? answer,

    /// ICE candidates from sender
    @Default([]) List<Map<String, dynamic>> offerCandidates,

    /// ICE candidates from receiver
    @Default([]) List<Map<String, dynamic>> answerCandidates,

    /// Whether receiver has clicked Accept and is ready to receive
    @Default(false) bool receiverReady,
  }) = _SignalingSession;

  /// Create from JSON
  factory SignalingSession.fromJson(Map<String, dynamic> json) =>
      _$SignalingSessionFromJson(json);

  /// Create from Firestore document
  factory SignalingSession.fromFirestore(
    String sessionId,
    Map<String, dynamic> data,
  ) {
    return SignalingSession(
      sessionId: sessionId,
      offer: data['offer'] as String,
      answer: data['answer'] as String?,
      offerCandidates:
          (data['offerCandidates'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
      answerCandidates:
          (data['answerCandidates'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
      createdAt: DateTime.parse(data['createdAt'] as String),
      expiresAt: DateTime.parse(data['expiresAt'] as String),
      receiverReady: data['receiverReady'] as bool? ?? false,
    );
  }
  const SignalingSession._();

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
}
