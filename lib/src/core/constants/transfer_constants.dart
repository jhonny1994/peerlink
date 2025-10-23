/// File transfer constants
class TransferConstants {
  TransferConstants._();

  /// Maximum file size allowed (MB)
  static const int maxFileSizeMb = 100;

  /// Maximum file size in bytes
  static const int maxFileSizeBytes = maxFileSizeMb * 1024 * 1024;

  /// Size of each chunk for file transfer (bytes) - 64KB
  static const int chunkSizeBytes = 65536; // 64 * 1024

  /// Maximum buffer size before pausing sending (bytes) - 256KB
  static const int maxBufferBytes = 262144; // 256 * 1024

  /// Firestore session document TTL (minutes)
  static const int sessionTtlMinutes = 15;

  /// Length of the transfer code
  static const int codeLength = 6;
}
