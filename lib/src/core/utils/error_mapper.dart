import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// Maps technical errors to user-friendly messages.
///
/// Follows the error mapping guidelines from copilot-instructions.md.
class ErrorMapper {
  ErrorMapper._();

  /// Maps exception to user-friendly error message.
  ///
  /// Returns a calm, guidance-oriented message appropriate for display.
  static String mapError(Object error, BuildContext context) {
    final l10n = S.of(context);

    // File picker exceptions
    if (error is FilePickerException) {
      switch (error.code) {
        case FilePickerErrorCode.pathUnavailable:
          return l10n.errorFilePathUnavailable;
        case FilePickerErrorCode.fileNotFound:
          return l10n.errorFileNotFound;
        case FilePickerErrorCode.fileTooLarge:
          return l10n.errorFileTooLarge;
        case FilePickerErrorCode.pickFailed:
          return l10n.errorFilePickerFailed;
      }
    }

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
