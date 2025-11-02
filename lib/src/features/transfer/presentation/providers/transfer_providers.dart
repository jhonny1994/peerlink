import 'package:peerlink/src/src.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transfer_providers.g.dart';

/// Provider for ChunkingService
@Riverpod(keepAlive: true)
ChunkingService chunkingService(Ref ref) {
  return ChunkingService();
}

/// Provider for HashService
@Riverpod(keepAlive: true)
HashService hashService(Ref ref) {
  return HashService();
}

/// Provider for TransferRepository
@Riverpod(keepAlive: true)
TransferRepository transferRepository(Ref ref) {
  final chunkingService = ref.watch(chunkingServiceProvider);
  final hashService = ref.watch(hashServiceProvider);
  // Use the shared data channel service from connection providers
  final dataChannelService = ref.watch(dataChannelServiceProvider);

  return TransferRepositoryImpl(
    chunkingService: chunkingService,
    hashService: hashService,
    dataChannelService: dataChannelService,
  );
}

/// Provider for sending files
/// keepAlive: true to persist across navigation
@Riverpod(keepAlive: true)
class FileSender extends _$FileSender {
  bool _isTransferring = false;

  @override
  Stream<FileTransfer?> build() async* {
    yield null;
  }

  /// Reset the sender state (clears old transfer data)
  void reset() {
    _isTransferring = false;
    state = const AsyncValue.data(null);
  }

  /// Start sending a file
  Future<void> sendFile(String sessionId, String filePath) async {
    // Guard against multiple calls
    if (_isTransferring) {
      return;
    }

    _isTransferring = true;
    final repository = ref.read(transferRepositoryProvider);
    final wakelockService = ref.read(wakelockServiceProvider);

    // Enable wakelock to keep device awake during transfer
    await wakelockService.enable();

    state = const AsyncValue.data(null);
    state = const AsyncValue.loading();

    try {
      await for (final transfer in repository.sendFile(sessionId, filePath)) {
        state = AsyncValue.data(transfer);
      }
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      // Always disable wakelock when transfer completes or fails
      await wakelockService.disable();
      _isTransferring = false;
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
/// keepAlive: true to persist across navigation
@Riverpod(keepAlive: true)
class FileReceiver extends _$FileReceiver {
  bool _isTransferring = false;

  @override
  Stream<FileTransfer?> build() async* {
    yield null;
  }

  /// Reset the receiver state (clears old transfer data)
  void reset() {
    _isTransferring = false;
    state = const AsyncValue.data(null);
  }

  /// Start receiving a file
  Future<void> receiveFile(String sessionId, String savePath) async {
    // Guard against multiple calls
    if (_isTransferring) {
      return;
    }

    _isTransferring = true;
    final repository = ref.read(transferRepositoryProvider);
    final wakelockService = ref.read(wakelockServiceProvider);

    // Enable wakelock to keep device awake during transfer
    await wakelockService.enable();

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
    } finally {
      // Always disable wakelock when transfer completes or fails
      await wakelockService.disable();
      _isTransferring = false;
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
