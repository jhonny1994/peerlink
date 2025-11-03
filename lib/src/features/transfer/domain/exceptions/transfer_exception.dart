import 'package:peerlink/src/core/exceptions/app_exception.dart';

/// Exception thrown during file transfer operations.
///
/// Error codes:
/// - 'transfer_cancelled': User cancelled the transfer
/// - 'transfer_stalled': Transfer timed out without progress
/// - 'hash_mismatch': File integrity check failed (SHA-256)
/// - 'channel_closed': Data channel closed unexpectedly
/// - 'metadata_missing': Transfer completed without metadata
/// - 'file_not_readable': Selected file cannot be read
class TransferException extends AppException {
  const TransferException(super.code, [super.technicalDetails]);

  /// Transfer was cancelled by user.
  const TransferException.cancelled([String? details])
    : super('transfer_cancelled', details);

  /// Transfer stalled without progress.
  const TransferException.stalled([String? details])
    : super('transfer_stalled', details);

  /// File integrity check failed.
  const TransferException.hashMismatch([String? details])
    : super('hash_mismatch', details);

  /// Data channel closed unexpectedly.
  const TransferException.channelClosed([String? details])
    : super('channel_closed', details);

  /// Transfer completed without receiving metadata.
  const TransferException.metadataMissing([String? details])
    : super('metadata_missing', details);

  /// File is not readable.
  const TransferException.fileNotReadable([String? details])
    : super('file_not_readable', details);
}
