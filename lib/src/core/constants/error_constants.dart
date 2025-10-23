/// Error codes for PeerLink operations
enum ErrorCode {
  iceGatherTimeout,
  connectionTimeout,
  transferStallTimeout,
  sha256Mismatch,
  fileTooLarge,
  turnQuotaExceeded,
  permissionDenied,
  fileNotFound,
  networkError,
  unknownError,
}

/// Maps technical error codes to user-friendly messages
class ErrorMessages {
  ErrorMessages._();

  /// Get user-friendly error message for an error code
  static String getMessage(ErrorCode code) {
    switch (code) {
      case ErrorCode.iceGatherTimeout:
        return 'Connection timed out. Please check your network and try again.';
      case ErrorCode.connectionTimeout:
        return 'Could not connect to the other device. Please verify the code.';
      case ErrorCode.transferStallTimeout:
        return 'Transfer stalled and was cancelled. Please try again.';
      case ErrorCode.sha256Mismatch:
        return 'File verification failed. The file may be corrupt. '
            'Please try sending again.';
      case ErrorCode.fileTooLarge:
        return 'File is larger than the 100MB limit.';
      case ErrorCode.turnQuotaExceeded:
        return 'Connection failed. The free service limit may have been '
            'reached. Please try again later.';
      case ErrorCode.permissionDenied:
        return 'Permission denied. Please grant the required permissions.';
      case ErrorCode.fileNotFound:
        return 'File not found. Please select a valid file.';
      case ErrorCode.networkError:
        return 'Network error. Please check your connection and try again.';
      case ErrorCode.unknownError:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
