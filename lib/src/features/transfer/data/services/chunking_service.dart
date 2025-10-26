import 'dart:io';
import 'dart:typed_data';
import 'package:peerlink/src/src.dart';

/// Service for chunking files for transfer
class ChunkingService {
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

  /// Write chunks to file
  ///
  /// Appends received chunks to the output file
  Future<void> writeChunk(String filePath, Uint8List chunk) async {
    final file = File(filePath);
    await file.writeAsBytes(chunk, mode: FileMode.append);
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
