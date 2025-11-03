import 'package:peerlink/src/core/exceptions/app_exception.dart';

/// Exception thrown when file picking operations fail.
///
/// Uses enum-based error codes for type safety and localization.
class FilePickerException extends AppException {
  FilePickerException(this.errorCode, [String? technicalDetails])
    : super(_getCodeString(errorCode), technicalDetails);

  final FilePickerErrorCode errorCode;

  static String _getCodeString(FilePickerErrorCode code) {
    switch (code) {
      case FilePickerErrorCode.pathUnavailable:
        return 'file_path_unavailable';
      case FilePickerErrorCode.fileNotFound:
        return 'file_not_found';
      case FilePickerErrorCode.fileTooLarge:
        return 'file_too_large';
      case FilePickerErrorCode.pickFailed:
        return 'file_pick_failed';
    }
  }
}

/// Error codes for file picker operations.
///
/// These codes are mapped to user-friendly localized messages by ErrorMapper.
enum FilePickerErrorCode {
  /// Unable to access the file path from the picked result.
  pathUnavailable,

  /// The selected file does not exist on the filesystem.
  fileNotFound,

  /// The selected file exceeds the maximum allowed size.
  fileTooLarge,

  /// Generic file picker failure (cancelled or unknown error).
  pickFailed,
}
