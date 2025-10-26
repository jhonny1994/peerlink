import 'package:peerlink/src/features/transfer/data/data.dart';
import 'package:peerlink/src/features/transfer/domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transfer_providers.g.dart';

/// Provider for ChunkingService
@riverpod
ChunkingService chunkingService(Ref ref) {
  return ChunkingService();
}

/// Provider for HashService
@riverpod
HashService hashService(Ref ref) {
  return HashService();
}

/// Provider for DataChannelService
@riverpod
DataChannelService dataChannelService(Ref ref) {
  return DataChannelService();
}

/// Provider for TransferRepository
@riverpod
TransferRepository transferRepository(Ref ref) {
  final chunkingService = ref.watch(chunkingServiceProvider);
  final hashService = ref.watch(hashServiceProvider);
  final dataChannelService = ref.watch(dataChannelServiceProvider);

  return TransferRepositoryImpl(
    chunkingService: chunkingService,
    hashService: hashService,
    dataChannelService: dataChannelService,
  );
}

/// Provider for sending files
@riverpod
class FileSender extends _$FileSender {
  @override
  Stream<FileTransfer?> build() async* {
    yield null;
  }

  /// Start sending a file
  Future<void> sendFile(String sessionId, String filePath) async {
    final repository = ref.read(transferRepositoryProvider);

    state = const AsyncValue.data(null);
    state = const AsyncValue.loading();

    try {
      await for (final transfer in repository.sendFile(sessionId, filePath)) {
        state = AsyncValue.data(transfer);
      }
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Cancel the current transfer
  Future<void> cancelTransfer() async {
    final currentTransfer = state.value;
    if (currentTransfer != null) {
      final repository = ref.read(transferRepositoryProvider);
      await repository.cancelTransfer(currentTransfer.transferId);
    }
  }
}

/// Provider for receiving files
@riverpod
class FileReceiver extends _$FileReceiver {
  @override
  Stream<FileTransfer?> build() async* {
    yield null;
  }

  /// Start receiving a file
  Future<void> receiveFile(String sessionId, String savePath) async {
    final repository = ref.read(transferRepositoryProvider);

    state = const AsyncValue.data(null);
    state = const AsyncValue.loading();

    try {
      await for (final transfer in repository.receiveFile(
        sessionId,
        savePath,
      )) {
        state = AsyncValue.data(transfer);
      }
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Cancel the current transfer
  Future<void> cancelTransfer() async {
    final currentTransfer = state.value;
    if (currentTransfer != null) {
      final repository = ref.read(transferRepositoryProvider);
      await repository.cancelTransfer(currentTransfer.transferId);
    }
  }
}

/// Provider for validating file size
@riverpod
bool isFileSizeValid(Ref ref, int fileSize) {
  final repository = ref.watch(transferRepositoryProvider);
  return repository.validateFileSize(fileSize);
}

/// Provider for calculating file hash
@riverpod
Future<String> fileHash(Ref ref, String filePath) async {
  final repository = ref.watch(transferRepositoryProvider);
  return repository.calculateFileHash(filePath);
}
