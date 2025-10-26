import 'dart:typed_data';
import 'package:peerlink/src/src.dart';

/// Repository for file transfer operations
abstract class TransferRepository {
  /// Send a file to the connected peer
  ///
  /// [sessionId] - The connection session ID
  /// [filePath] - Path to the file to send
  ///
  /// Returns a stream of transfer state updates
  Stream<FileTransfer> sendFile(String sessionId, String filePath);

  /// Receive a file from the connected peer
  ///
  /// [sessionId] - The connection session ID
  /// [savePath] - Directory path where to save the received file
  ///
  /// Returns a stream of transfer state updates
  Stream<FileTransfer> receiveFile(String sessionId, String savePath);

  /// Cancel an ongoing transfer
  Future<void> cancelTransfer(String transferId);

  /// Validate file size against maximum limit (100MB)
  bool validateFileSize(int fileSize);

  /// Calculate SHA-256 hash of a file
  Future<String> calculateFileHash(String filePath);
}

/// Repository for data channel operations
abstract class DataChannelRepository {
  /// Open a data channel for the session
  Future<void> openDataChannel(String sessionId, String label);

  /// Close the data channel
  Future<void> closeDataChannel(String sessionId);

  /// Send data through the channel
  Future<void> sendData(String sessionId, Uint8List data);

  /// Listen for incoming data
  Stream<Uint8List> onDataReceived(String sessionId);

  /// Get current buffer amount
  Future<int> getBufferedAmount(String sessionId);

  /// Check if channel is open
  Future<bool> isChannelOpen(String sessionId);
}
