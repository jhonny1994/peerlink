import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:peerlink/src/features/transfer/domain/entities/file_metadata.dart';
import 'package:peerlink/src/features/transfer/domain/entities/transfer_progress.dart';

part 'file_transfer.freezed.dart';

/// Transfer state enum
enum TransferState {
  idle,
  preparing,
  transferring,
  verifying,
  completed,
  failed,
  cancelled,
}

/// File transfer entity
@freezed
abstract class FileTransfer with _$FileTransfer {
  const factory FileTransfer({
    required String transferId,
    required String sessionId,
    required FileMetadata metadata,
    required TransferState state,
    required bool isSender,
    TransferProgress? progress,
    String? errorMessage,
  }) = _FileTransfer;
}
