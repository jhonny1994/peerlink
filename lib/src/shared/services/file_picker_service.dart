// File.exists() and File.length() are necessary for file validation in this service.
// Performance impact is acceptable as these checks happen only during user file selection.
// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:peerlink/src/src.dart';

/// Service for picking files with size validation and error handling.
///
/// Wraps the file_picker package with PeerLink-specific logic:
/// - Enforces 100MB file size limit
/// - Throws error codes for localization by ErrorMapper
/// - Handles platform-specific picker behavior
class FilePickerService {
  /// Maximum file size in bytes (100MB from TransferConstants).
  static const int maxFileSizeBytes =
      TransferConstants.maxFileSizeMb * 1024 * 1024;

  /// Picks a single file with size validation.
  ///
  /// Returns a [File] object if successful, or null if user cancels.
  ///
  /// Throws [FilePickerException] with appropriate error code for UI localization:
  /// - [FilePickerErrorCode.pathUnavailable] - Cannot access file path
  /// - [FilePickerErrorCode.fileNotFound] - File doesn't exist
  /// - [FilePickerErrorCode.fileTooLarge] - Exceeds 100MB limit
  /// - [FilePickerErrorCode.pickFailed] - Unknown picker error
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
        throw FilePickerException(FilePickerErrorCode.pathUnavailable);
      }

      final file = File(path);

      // Validate file exists
      if (!await file.exists()) {
        throw FilePickerException(
          FilePickerErrorCode.fileNotFound,
          path,
        );
      }

      // Get actual file size
      final fileSize = await file.length();

      // Enforce size limit
      if (fileSize > maxFileSizeBytes) {
        throw FilePickerException(
          FilePickerErrorCode.fileTooLarge,
          '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB',
        );
      }

      return file;
    } on FilePickerException {
      rethrow;
    } catch (e) {
      // Wrap unknown errors
      throw FilePickerException(
        FilePickerErrorCode.pickFailed,
        e.toString(),
      );
    }
  }
}
