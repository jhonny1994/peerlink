// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:peerlink/src/core/constants/transfer_constants.dart';

/// Service for picking files with size validation and error handling.
///
/// Wraps the file_picker package with PeerLink-specific logic:
/// - Enforces 100MB file size limit
/// - Provides user-friendly error messages
/// - Handles platform-specific picker behavior
class FilePickerService {
  /// Maximum file size in bytes (100MB from TransferConstants).
  static const int maxFileSizeBytes =
      TransferConstants.maxFileSizeMb * 1024 * 1024;

  /// Picks a single file with size validation.
  ///
  /// Returns a [File] object if successful, or null if:
  /// - User cancels the picker
  /// - File exceeds size limit
  /// - Platform doesn't support file picking
  ///
  /// Throws [FileTooLargeException] if file exceeds 100MB.
  /// Throws [FilePickerException] for other errors.
  Future<File?> pickFile() async {
    try {
      // Use file_picker with type ANY to allow all file types
      final result = await FilePicker.platform.pickFiles();

      // User cancelled
      if (result == null || result.files.isEmpty) {
        return null;
      }

      final platformFile = result.files.first;
      final path = platformFile.path;

      // Platform doesn't support file paths (shouldn't happen with modern file_picker)
      if (path == null) {
        throw const FilePickerException(
          'Unable to access file path. Please try again.',
        );
      }

      final file = File(path);

      // Validate file exists
      if (!await file.exists()) {
        throw const FilePickerException(
          'Selected file does not exist. Please try again.',
        );
      }

      // Get actual file size
      final fileSize = await file.length();

      // Enforce size limit
      if (fileSize > maxFileSizeBytes) {
        throw FileTooLargeException(
          'File is larger than the ${TransferConstants.maxFileSizeMb}MB limit. '
          'Selected file size: ${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB',
        );
      }

      return file;
    } on FileTooLargeException {
      rethrow;
    } on FilePickerException {
      rethrow;
    } catch (e) {
      // Wrap unknown errors
      throw FilePickerException(
        'An error occurred while picking the file: $e',
      );
    }
  }

  /// Gets a human-readable file size string (e.g., "45.2 MB").
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Exception thrown when file exceeds size limit.
class FileTooLargeException implements Exception {
  const FileTooLargeException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown for file picker errors.
class FilePickerException implements Exception {
  const FilePickerException(this.message);
  final String message;

  @override
  String toString() => message;
}
