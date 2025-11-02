import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

      // CRITICAL FIX: Wait for all data to be delivered before completing
      // The WebRTC buffer must drain completely to ensure all chunks reached the receiver

      var bufferedAmount = await dataChannelService.getBufferedAmount(
        sessionId,
      );
      var waitCount = 0;
      const maxWaitTime = 600; // 30 seconds (600 * 50ms)
      while (bufferedAmount > 0 && waitCount < maxWaitTime) {
        // Wait up to 30 seconds for buffer to drain

        await Future<void>.delayed(const Duration(milliseconds: 50));
        bufferedAmount = await dataChannelService.getBufferedAmount(sessionId);
        waitCount++;
      }

      if (bufferedAmount > 0) {
        throw Exception(
          'Transfer timeout: WebRTC buffer did not drain after 30 seconds. '
          'File may not have been fully received.',
        );
      }

      // Add extra delay to ensure receiver processes everything
      await Future<void>.delayed(const Duration(milliseconds: 200));

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
      // Wait for data channel to be ready

      yield* _yieldState(
        controller,
        transferId,
        sessionId,
        const FileMetadata(name: '', size: 0, mimeType: '', hash: ''),
        TransferState.preparing,
        false,
        null,
      );

      await dataChannelService.waitForDataChannel(
        sessionId,
      );

      FileMetadata? metadata;
      String? outputPath;
      var bytesReceived = 0;
      var chunkCount = 0;
      DateTime? startTime;
      var metadataReceived = false;

      final dataStream = await dataChannelService.onDataReceived(sessionId);
      await for (final data in dataStream) {
        // Check if transfer was cancelled
        if (_cancelledTransfers[transferId] ?? false) {
          throw Exception('Transfer cancelled by user');
        }

        // First, try to parse as metadata
        if (!metadataReceived) {
          try {
            final metadataString = utf8.decode(data);
            final metadataJson =
                json.decode(metadataString) as Map<String, dynamic>;

            // Check if it's a metadata message
            if (metadataJson['type'] == 'metadata') {
              metadata = FileMetadata(
                name: metadataJson['name'] as String,
                size: metadataJson['size'] as int,
                mimeType: metadataJson['mimeType'] as String,
                hash: metadataJson['hash'] as String,
              );

              outputPath = path.join(savePath, metadata.name);

              // Handle file name conflicts - append (1), (2), etc. if file exists
              var conflictCounter = 1;
              var finalPath = outputPath;
              while (File(finalPath).existsSync()) {
                final extension = path.extension(metadata.name);
                final nameWithoutExt = metadata.name.replaceFirst(
                  RegExp(r'\.[\w]+$'),
                  '',
                );
                finalPath = path.join(
                  savePath,
                  '$nameWithoutExt ($conflictCounter)$extension',
                );
                conflictCounter++;

                // Safety limit to prevent infinite loop
                if (conflictCounter > 1000) {
                  throw Exception(
                    'Too many file conflicts. Cannot find available file name.',
                  );
                }
              }
              outputPath = finalPath;

              // Create the save directory if it doesn't exist
              final outputFile = File(outputPath);
              await outputFile.parent.create(recursive: true);

              metadataReceived = true;
              startTime = DateTime.now();

              // Yield transferring state
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
                  startTime: startTime,
                ),
              );

              continue; // Skip to next message (file chunks)
            }
          } on Exception {
            // If parsing fails and we haven't received metadata yet, this is wrong
            if (!metadataReceived) {
              throw Exception('Expected metadata but received invalid data');
            }
          }
        }

        // If we reach here, it's a file chunk
        if (metadata == null || outputPath == null || startTime == null) {
          throw Exception('Received chunk before metadata');
        }

        chunkCount++;

        await chunkingService.writeChunk(outputPath, data);
        bytesReceived += data.length;

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

      if (metadata == null || outputPath == null) {
        throw Exception('Transfer completed without receiving metadata');
      }

      // Check if we received all bytes
      if (bytesReceived < metadata.size) {
        throw Exception(
          'Incomplete transfer: received $bytesReceived bytes but expected ${metadata.size} bytes ($chunkCount chunks)',
        );
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
          startTime: startTime!,
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
    // Send metadata as JSON through data channel

    final metadataJson = {
      'type': 'metadata',
      'name': metadata.name,
      'size': metadata.size,
      'mimeType': metadata.mimeType,
      'hash': metadata.hash,
    };

    final metadataBytes = utf8.encode(json.encode(metadataJson));

    await dataChannelService.sendData(
      sessionId,
      Uint8List.fromList(metadataBytes),
    );
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
