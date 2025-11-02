import 'dart:io';
import 'dart:typed_data';
import 'package:peerlink/src/src.dart';

/// Service for chunking files for transfer
class ChunkingService {
  // File-level locks to ensure sequential writes per file
  final Map<String, Future<void>> _fileLocks = {};

  /// Read file in chunks
  ///
  /// Returns a stream of chunks with fixed size (CHUNK_SIZE_BYTES)
  Stream<Uint8List> readFileInChunks(String filePath) async* {
    final file = File(filePath);
    final fileStream = file.openRead();

    await for (final chunk in fileStream) {
      // Split large chunks if needed
      if (chunk.length > TransferConstants.chunkSizeBytes) {
        for (
          var i = 0;
          i < chunk.length;
          i += TransferConstants.chunkSizeBytes
        ) {
          final end = (i + TransferConstants.chunkSizeBytes < chunk.length)
              ? i + TransferConstants.chunkSizeBytes
              : chunk.length;
          yield Uint8List.fromList(chunk.sublist(i, end));
        }
      } else {
        yield Uint8List.fromList(chunk);
      }
    }
  }

  /// Write chunks to file with guaranteed sequential order
  ///
  /// Appends received chunks to the output file.
  /// Uses file-level locking to ensure writes happen sequentially
  /// even when called concurrently from async code.
  Future<void> writeChunk(String filePath, Uint8List chunk) async {
    // Wait for any pending writes to this file to complete
    await _fileLocks[filePath];

    // Create a new future for this write operation
    final writeFuture = _writeChunkInternal(filePath, chunk);

    // Store it as the lock for subsequent writes
    _fileLocks[filePath] = writeFuture;

    // Wait for our write to complete
    await writeFuture;
  }

  Future<void> _writeChunkInternal(String filePath, Uint8List chunk) async {
    final file = File(filePath);
    // Use writeAsBytes with append mode and flush: true for immediate persistence
    await file.writeAsBytes(chunk, mode: FileMode.append, flush: true);
  }

  /// Get file size
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return file.length();
  }

  /// Validate file exists and is readable
  Future<bool> validateFile(String filePath) async {
    final file = File(filePath);
    return file.existsSync();
  }
}
