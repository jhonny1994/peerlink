import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer_progress.freezed.dart';

/// Transfer progress information
@freezed
abstract class TransferProgress with _$TransferProgress {
  const factory TransferProgress({
    required int bytesTransferred,
    required int totalBytes,
    required double speedBytesPerSecond,
    required DateTime startTime,
    DateTime? endTime,
  }) = _TransferProgress;

  const TransferProgress._();

  /// Get transfer percentage (0-100)
  double get percentage => (bytesTransferred / totalBytes) * 100;

  /// Get transfer speed in MB/s
  double get speedMBps => speedBytesPerSecond / (1024 * 1024);

  /// Check if transfer is complete
  bool get isComplete => bytesTransferred >= totalBytes;

  /// Get elapsed time in seconds
  int get elapsedSeconds =>
      (endTime ?? DateTime.now()).difference(startTime).inSeconds;
}
