/// Exception thrown when file picking operations fail.
///
/// Contains error codes that can be mapped to localized messages by ErrorMapper.
class FilePickerException implements Exception {
  const FilePickerException(this.code, [this.technicalDetails]);
  final FilePickerErrorCode code;
  final String? technicalDetails;

  @override
  String toString() =>
      'FilePickerException: ${code.name}${technicalDetails != null ? ' - $technicalDetails' : ''}';
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
