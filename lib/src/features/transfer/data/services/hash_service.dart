import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Service for calculating SHA-256 hashes
class HashService {
  /// Calculate SHA-256 hash of a file using streaming
  ///
  /// This reads the file in chunks to avoid loading large files into memory
  Future<String> calculateFileHash(String filePath) async {
    final file = File(filePath);
    final stream = file.openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  }

  /// Calculate SHA-256 hash of data bytes
  String calculateDataHash(Uint8List data) {
    final digest = sha256.convert(data);
    return digest.toString();
  }

  /// Verify hash matches expected value
  bool verifyHash(String calculated, String expected) {
    return calculated.toLowerCase() == expected.toLowerCase();
  }
}
