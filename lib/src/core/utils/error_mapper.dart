import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// Maps technical errors to user-friendly localized messages.
///
/// Follows a two-tier approach:
/// 1. Typed exceptions (AppException subclasses) - Preferred, type-safe
/// 2. String-based error matching - Fallback for legacy/external errors
///
/// All user-facing error messages use l10n for proper internationalization.
class ErrorMapper {
  ErrorMapper._();

  /// Maps exception to user-friendly error message.
  ///
  /// Returns a calm, guidance-oriented message appropriate for display.
  static String mapError(Object error, BuildContext context) {
    final l10n = S.of(context);

    // Type-safe exception handling (preferred)
    if (error is AppException) {
      return _mapAppException(error, l10n);
    }

    // Legacy string-based error matching (fallback)
    return _mapLegacyError(error, l10n);
  }

  /// Maps typed AppException subclasses to localized messages.
  static String _mapAppException(AppException exception, S l10n) {
    switch (exception.code) {
      // File picker errors
      case 'file_path_unavailable':
        return l10n.errorFilePathUnavailable;
      case 'file_not_found':
        return l10n.errorFileNotFound;
      case 'file_too_large':
        return l10n.errorFileTooLarge;
      case 'file_pick_failed':
        return l10n.errorFilePickerFailed;

      // Connection errors
      case 'session_expired':
        return l10n.errorSessionExpired;
      case 'session_not_found':
        return l10n.errorInvalidCode;
      case 'connection_failed':
        return l10n.errorCouldNotConnect;
      case 'connection_timeout':
        return l10n.errorConnectionTimeout;
      case 'network_error':
        return l10n.errorNetwork;
      case 'connection_unknown':
        return l10n.errorCouldNotConnect;

      // Transfer errors
      case 'transfer_cancelled':
        return l10n.errorUnexpected; // Or add specific l10n.transferCancelled
      case 'transfer_stalled':
        return l10n.errorTransferStalled;
      case 'hash_mismatch':
        return l10n.errorFileVerificationFailed;
      case 'channel_closed':
        return l10n.errorCouldNotConnect;
      case 'metadata_missing':
        return l10n.errorUnexpected;
      case 'file_not_readable':
        return l10n.errorFileNotFound;
      case 'file_conflict_limit':
        return l10n.errorUnexpected;

      // Fallback for unknown codes
      default:
        return l10n.errorUnexpected;
    }
  }

  /// Maps legacy string-based errors to localized messages.
  ///
  /// Used for:
  /// - StateError, TimeoutException, generic Exception
  /// - External library errors
  /// - Errors that haven't been migrated to typed exceptions yet
  static String _mapLegacyError(Object error, S l10n) {
    final errorString = error.toString().toLowerCase();

    // StateError and connection errors
    if (error is StateError ||
        errorString.contains('data channel') ||
        errorString.contains('peer connection') ||
        errorString.contains('not initialized')) {
      return l10n.errorCouldNotConnect;
    }

    // Transfer cancelled by user (not an error, but handle gracefully)
    if (errorString.contains('cancelled') || errorString.contains('canceled')) {
      return l10n
          .errorUnexpected; // Or could add specific l10n.transferCancelled
    }

    // File not found errors
    if (errorString.contains('file') &&
        (errorString.contains('not found') ||
            errorString.contains('not readable'))) {
      return l10n.errorFileNotFound;
    }

    // File size errors
    if (errorString.contains('file') &&
        (errorString.contains('too large') ||
            errorString.contains('exceeds') ||
            errorString.contains('100mb') ||
            errorString.contains('size limit') ||
            errorString.contains('maximum limit'))) {
      return l10n.errorFileTooLarge;
    }

    // Connection timeout errors
    if (errorString.contains('ice') &&
        (errorString.contains('gather') || errorString.contains('timeout'))) {
      return l10n.errorConnectionTimeout;
    }

    if (errorString.contains('connection') && errorString.contains('timeout')) {
      return l10n.errorCouldNotConnect;
    }

    // Transfer stall errors
    if (errorString.contains('stall') ||
        errorString.contains('transfer timeout')) {
      return l10n.errorTransferStalled;
    }

    // Hash verification errors
    if (errorString.contains('sha') ||
        errorString.contains('hash') ||
        errorString.contains('verification') ||
        errorString.contains('integrity')) {
      return l10n.errorFileVerificationFailed;
    }

    // TURN quota errors
    if (errorString.contains('turn') &&
        (errorString.contains('quota') || errorString.contains('limit'))) {
      return l10n.errorTurnQuotaExceeded;
    }

    // Permission errors
    if (errorString.contains('permission')) {
      if (errorString.contains('camera')) {
        return l10n.errorCameraPermission;
      }
      if (errorString.contains('storage') || errorString.contains('file')) {
        return l10n.errorStoragePermission;
      }
      return l10n.errorPermissionDenied;
    }

    // Network errors
    if (errorString.contains('network') || errorString.contains('internet')) {
      return l10n.errorNetwork;
    }

    // Session errors
    if (errorString.contains('session') &&
        (errorString.contains('not found') ||
            errorString.contains('expired'))) {
      return l10n.errorSessionExpired;
    }

    if (errorString.contains('invalid code') ||
        errorString.contains('code not found')) {
      return l10n.errorInvalidCode;
    }

    // Firestore errors
    if (errorString.contains('firestore') || errorString.contains('firebase')) {
      return l10n.errorServiceUnavailable;
    }

    // Generic fallback
    return l10n.errorUnexpected;
  }
}
