import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:peerlink/src/src.dart';

/// Implementation of TransferRepository
class TransferRepositoryImpl implements TransferRepository {
  TransferRepositoryImpl({
    required this.chunkingService,
    required this.hashService,
    required this.dataChannelService,
  });

  final ChunkingService chunkingService;
  final HashService hashService;
  final DataChannelService dataChannelService;

  final Map<String, StreamController<FileTransfer>> _transferControllers = {};
  final Map<String, bool> _cancelledTransfers = {};

  @override
  Stream<FileTransfer> sendFile(String sessionId, String filePath) async* {
    final transferId = _generateTransferId();
    final controller = StreamController<FileTransfer>.broadcast();
    _transferControllers[transferId] = controller;

    try {
      // Validate file
      if (!await chunkingService.validateFile(filePath)) {
        throw Exception('File not found or not readable: $filePath');
      }

      final fileSize = await chunkingService.getFileSize(filePath);
      if (!validateFileSize(fileSize)) {
        throw Exception(
          'File size exceeds maximum limit of ${TransferConstants.maxFileSizeMb}MB',
        );
      }

      final fileName = path.basename(filePath);
      final mimeType = _getMimeType(fileName);

      // Calculate hash
      yield* _yieldState(
        controller,
        transferId,
        sessionId,
        FileMetadata(
          name: fileName,
          size: fileSize,
          mimeType: mimeType,
          hash: '',
        ),
        TransferState.preparing,
        true,
        null,
      );

      final fileHash = await hashService.calculateFileHash(filePath);

      final metadata = FileMetadata(
        name: fileName,
        size: fileSize,
        mimeType: mimeType,
        hash: fileHash,
      );

      // Send metadata first
      await _sendMetadata(sessionId, metadata);

      // Start transfer
      yield* _yieldState(
        controller,
        transferId,
        sessionId,
        metadata,
        TransferState.transferring,
        true,
        TransferProgress(
          bytesTransferred: 0,
          totalBytes: fileSize,
          speedBytesPerSecond: 0,
          startTime: DateTime.now(),
        ),
      );

      // Send file chunks
      final startTime = DateTime.now();
      var bytesTransferred = 0;

      await for (final chunk in chunkingService.readFileInChunks(filePath)) {
        // Check if transfer was cancelled
        if (_cancelledTransfers[transferId] ?? false) {
          throw Exception('Transfer cancelled by user');
        }

        // Wait if buffer is full
        while (await dataChannelService.getBufferedAmount(sessionId) >
            TransferConstants.maxBufferBytes) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }

        await dataChannelService.sendData(sessionId, chunk);
        bytesTransferred += chunk.length;

        // Calculate speed
        final elapsed = DateTime.now().difference(startTime).inSeconds;
        final speed = elapsed > 0 ? bytesTransferred / elapsed : 0;

        yield* _yieldState(
          controller,
          transferId,
          sessionId,
          metadata,
          TransferState.transferring,
          true,
          TransferProgress(
            bytesTransferred: bytesTransferred,
            totalBytes: fileSize,
            speedBytesPerSecond: speed.toDouble(),
            startTime: startTime,
          ),
        );
      }

      // Transfer complete
      yield* _yieldState(
        controller,
        transferId,
        sessionId,
        metadata,
        TransferState.completed,
        true,
        TransferProgress(
          bytesTransferred: bytesTransferred,
          totalBytes: fileSize,
          speedBytesPerSecond: 0,
          startTime: startTime,
          endTime: DateTime.now(),
        ),
      );
    } on Exception catch (e) {
      yield* _yieldState(
        controller,
        transferId,
        sessionId,
        const FileMetadata(name: '', size: 0, mimeType: '', hash: ''),
        TransferState.failed,
        true,
        null,
        errorMessage: e.toString(),
      );
    } finally {
      _transferControllers.remove(transferId);
      _cancelledTransfers.remove(transferId);
      await controller.close();
    }
  }

  @override
  Stream<FileTransfer> receiveFile(String sessionId, String savePath) async* {
    final transferId = _generateTransferId();
    final controller = StreamController<FileTransfer>.broadcast();
    _transferControllers[transferId] = controller;

    try {
      // Wait for metadata
      yield* _yieldState(
        controller,
        transferId,
        sessionId,
        const FileMetadata(name: '', size: 0, mimeType: '', hash: ''),
        TransferState.preparing,
        false,
        null,
      );

      final metadata = await _receiveMetadata(sessionId);
      final outputPath = path.join(savePath, metadata.name);

      // Prepare to receive
      yield* _yieldState(
        controller,
        transferId,
        sessionId,
        metadata,
        TransferState.transferring,
        false,
        TransferProgress(
          bytesTransferred: 0,
          totalBytes: metadata.size,
          speedBytesPerSecond: 0,
          startTime: DateTime.now(),
        ),
      );

      final startTime = DateTime.now();
      var bytesReceived = 0;

      // Receive chunks
      await for (final chunk in dataChannelService.onDataReceived(sessionId)) {
        // Check if transfer was cancelled
        if (_cancelledTransfers[transferId] ?? false) {
          throw Exception('Transfer cancelled by user');
        }

        await chunkingService.writeChunk(outputPath, chunk);
        bytesReceived += chunk.length;

        // Calculate speed
        final elapsed = DateTime.now().difference(startTime).inSeconds;
        final speed = elapsed > 0 ? bytesReceived / elapsed : 0;

        yield* _yieldState(
          controller,
          transferId,
          sessionId,
          metadata,
          TransferState.transferring,
          false,
          TransferProgress(
            bytesTransferred: bytesReceived,
            totalBytes: metadata.size,
            speedBytesPerSecond: speed.toDouble(),
            startTime: startTime,
          ),
        );

        // Check if complete
        if (bytesReceived >= metadata.size) {
          break;
        }
      }

      // Verify hash
      yield* _yieldState(
        controller,
        transferId,
        sessionId,
        metadata,
        TransferState.verifying,
        false,
        TransferProgress(
          bytesTransferred: bytesReceived,
          totalBytes: metadata.size,
          speedBytesPerSecond: 0,
          startTime: startTime,
        ),
      );

      final calculatedHash = await hashService.calculateFileHash(outputPath);
      if (!hashService.verifyHash(calculatedHash, metadata.hash)) {
        // Delete corrupted file
        await File(outputPath).delete();
        // ErrorMapper will map this to errorFileVerificationFailed
        throw Exception('SHA256 hash mismatch - file verification failed');
      }

      // Transfer complete
      yield* _yieldState(
        controller,
        transferId,
        sessionId,
        metadata,
        TransferState.completed,
        false,
        TransferProgress(
          bytesTransferred: bytesReceived,
          totalBytes: metadata.size,
          speedBytesPerSecond: 0,
          startTime: startTime,
          endTime: DateTime.now(),
        ),
      );
    } on Exception catch (e) {
      yield* _yieldState(
        controller,
        transferId,
        sessionId,
        const FileMetadata(name: '', size: 0, mimeType: '', hash: ''),
        TransferState.failed,
        false,
        null,
        errorMessage: e.toString(),
      );
    } finally {
      _transferControllers.remove(transferId);
      _cancelledTransfers.remove(transferId);
      await controller.close();
    }
  }

  @override
  Future<void> cancelTransfer(String transferId) async {
    _cancelledTransfers[transferId] = true;
  }

  @override
  bool validateFileSize(int fileSize) {
    return fileSize <= TransferConstants.maxFileSizeBytes;
  }

  @override
  Future<String> calculateFileHash(String filePath) {
    return hashService.calculateFileHash(filePath);
  }

  // Helper methods

  Stream<FileTransfer> _yieldState(
    StreamController<FileTransfer> controller,
    String transferId,
    String sessionId,
    FileMetadata metadata,
    TransferState state,
    bool isSender,
    TransferProgress? progress, {
    String? errorMessage,
  }) async* {
    final transfer = FileTransfer(
      transferId: transferId,
      sessionId: sessionId,
      metadata: metadata,
      state: state,
      isSender: isSender,
      progress: progress,
      errorMessage: errorMessage,
    );
    controller.add(transfer);
    yield transfer;
  }

  String _generateTransferId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _sendMetadata(String sessionId, FileMetadata metadata) async {
    // TODO(dev): Send metadata through data channel as JSON
    // For now, we'll assume metadata is sent separately
  }

  Future<FileMetadata> _receiveMetadata(String sessionId) async {
    // TODO(dev): Receive metadata through data channel
    // For now, return a placeholder
    throw UnimplementedError('Metadata exchange not yet implemented');
  }

  String _getMimeType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    // Basic MIME type mapping
    const mimeTypes = {
      '.txt': 'text/plain',
      '.pdf': 'application/pdf',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.mp4': 'video/mp4',
      '.mp3': 'audio/mpeg',
      '.zip': 'application/zip',
    };
    return mimeTypes[extension] ?? 'application/octet-stream';
  }
}
