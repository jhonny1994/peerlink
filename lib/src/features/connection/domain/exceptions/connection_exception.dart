import 'package:peerlink/src/core/exceptions/app_exception.dart';

/// Exception thrown during connection operations.
///
/// Error codes:
/// - 'session_expired': Session not found or expired (> 15 minutes)
/// - 'session_not_found': Session document doesn't exist
/// - 'connection_failed': Failed to establish WebRTC connection
/// - 'connection_timeout': Connection attempt timed out
class ConnectionException extends AppException {
  const ConnectionException(super.code, [super.technicalDetails]);

  /// Session expired or not found.
  const ConnectionException.sessionExpired([String? details])
    : super('session_expired', details);

  /// Session document not found in Firestore.
  const ConnectionException.sessionNotFound([String? details])
    : super('session_not_found', details);

  /// Failed to establish WebRTC connection.
  const ConnectionException.connectionFailed([String? details])
    : super('connection_failed', details);

  /// Connection attempt timed out.
  const ConnectionException.connectionTimeout([String? details])
    : super('connection_timeout', details);
}
