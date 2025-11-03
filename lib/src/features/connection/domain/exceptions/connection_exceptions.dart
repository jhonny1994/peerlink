/// Exceptions related to connection operations.
///
/// These exceptions are mapped to user-friendly messages via ErrorMapper.
library;

/// Exception thrown when a session is expired or invalid.
class SessionExpiredException implements Exception {
  const SessionExpiredException([this.message]);
  final String? message;

  @override
  String toString() =>
      message ?? 'Session expired or not found. Please generate a new code.';
}

/// Exception thrown when session validation fails.
class SessionValidationException implements Exception {
  const SessionValidationException([this.message]);
  final String? message;

  @override
  String toString() => message ?? 'Session validation failed';
}

/// Exception thrown when session cleanup fails.
class SessionCleanupException implements Exception {
  const SessionCleanupException([this.message]);
  final String? message;

  @override
  String toString() => message ?? 'Session cleanup failed';
}

/// Exception thrown when FCM initialization fails.
class FcmInitializationException implements Exception {
  const FcmInitializationException([this.message]);
  final String? message;

  @override
  String toString() => message ?? 'FCM initialization failed';
}

/// Exception thrown when FCM token operations fail.
class FcmTokenException implements Exception {
  const FcmTokenException([this.message]);
  final String? message;

  @override
  String toString() => message ?? 'FCM token operation failed';
}
