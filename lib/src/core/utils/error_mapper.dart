/// Maps technical errors to user-friendly messages.
///
/// Follows the error mapping guidelines from copilot-instructions.md.
class ErrorMapper {
  ErrorMapper._();

  /// Maps exception to user-friendly error message.
  ///
  /// Returns a calm, guidance-oriented message appropriate for display.
  static String mapError(Object error) {
    final errorString = error.toString().toLowerCase();

    // File size errors
    if (errorString.contains('file') &&
        (errorString.contains('too large') ||
            errorString.contains('100mb') ||
            errorString.contains('size limit'))) {
      return 'File is larger than the 100MB limit.';
    }

    // Connection timeout errors
    if (errorString.contains('ice') &&
        (errorString.contains('gather') || errorString.contains('timeout'))) {
      return 'Connection timed out. Please check your network and try again.';
    }

    if (errorString.contains('connection') && errorString.contains('timeout')) {
      return 'Could not connect to the other device. Please verify the code.';
    }

    // Transfer stall errors
    if (errorString.contains('stall') || errorString.contains('transfer timeout')) {
      return 'Transfer stalled and was cancelled. Please try again.';
    }

    // Hash verification errors
    if (errorString.contains('sha') ||
        errorString.contains('hash') ||
        errorString.contains('verification') ||
        errorString.contains('integrity')) {
      return 'File verification failed. The file may be corrupt. Please try sending again.';
    }

    // TURN quota errors
    if (errorString.contains('turn') &&
        (errorString.contains('quota') || errorString.contains('limit'))) {
      return 'Connection failed. The free service limit may have been reached. Please try again later.';
    }

    // Permission errors
    if (errorString.contains('permission')) {
      if (errorString.contains('camera')) {
        return 'Camera permission is required to scan QR codes. Please grant permission in settings.';
      }
      if (errorString.contains('storage') || errorString.contains('file')) {
        return 'Storage permission is required to save files. Please grant permission in settings.';
      }
      return 'Permission denied. Please check app permissions in settings.';
    }

    // Network errors
    if (errorString.contains('network') || errorString.contains('internet')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    // Session errors
    if (errorString.contains('session') &&
        (errorString.contains('not found') || errorString.contains('expired'))) {
      return 'Session expired or invalid. Please generate a new code and try again.';
    }

    if (errorString.contains('invalid code') || errorString.contains('code not found')) {
      return 'Invalid code. Please check the code and try again.';
    }

    // Firestore errors
    if (errorString.contains('firestore') || errorString.contains('firebase')) {
      return 'Service temporarily unavailable. Please try again in a moment.';
    }

    // Generic fallback
    return 'An unexpected error occurred. Please try again.';
  }
}
