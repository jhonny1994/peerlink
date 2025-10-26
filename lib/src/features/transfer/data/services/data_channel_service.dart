import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peerlink/src/src.dart';

/// Service for managing WebRTC data channels
class DataChannelService {
  final Map<String, RTCDataChannel> _channels = {};
  final Map<String, StreamController<Uint8List>> _dataControllers = {};

  /// Create a data channel for file transfer
  Future<void> createDataChannel(
    RTCPeerConnection peerConnection,
    String sessionId,
    String label,
  ) async {
    final dataChannel = await peerConnection.createDataChannel(
      label,
      RTCDataChannelInit()
        ..ordered = true
        ..maxRetransmits = 3,
    );

    _channels[sessionId] = dataChannel;
    _dataControllers[sessionId] = StreamController<Uint8List>.broadcast();

    // Listen for incoming data
    dataChannel
      ..onMessage = (RTCDataChannelMessage message) {
        if (message.isBinary) {
          _dataControllers[sessionId]?.add(message.binary);
        }
      }
      ..onDataChannelState = (state) async {
        if (state == RTCDataChannelState.RTCDataChannelClosed) {
          await _cleanupChannel(sessionId);
        }
      };
  }

  /// Send data through the channel
  Future<void> sendData(String sessionId, Uint8List data) async {
    final channel = _channels[sessionId];
    if (channel == null) {
      throw StateError('Data channel not found for session: $sessionId');
    }

    if (channel.state != RTCDataChannelState.RTCDataChannelOpen) {
      throw StateError('Data channel is not open');
    }

    // Check buffer before sending
    final bufferedAmount = await getBufferedAmount(sessionId);
    if (bufferedAmount > TransferConstants.maxBufferBytes) {
      // Wait for buffer to drain
      await Future.delayed(
        const Duration(milliseconds: 100),
        () {},
      );
    }

    await channel.send(RTCDataChannelMessage.fromBinary(data));
  }

  /// Get stream of incoming data
  Stream<Uint8List> onDataReceived(String sessionId) {
    final controller = _dataControllers[sessionId];
    if (controller == null) {
      throw StateError('Data channel not found for session: $sessionId');
    }
    return controller.stream;
  }

  /// Get current buffered amount
  Future<int> getBufferedAmount(String sessionId) async {
    final channel = _channels[sessionId];
    if (channel == null) {
      return 0;
    }
    return channel.bufferedAmount ?? 0;
  }

  /// Check if channel is open
  bool isChannelOpen(String sessionId) {
    final channel = _channels[sessionId];
    return channel?.state == RTCDataChannelState.RTCDataChannelOpen;
  }

  /// Close data channel
  Future<void> closeDataChannel(String sessionId) async {
    final channel = _channels[sessionId];
    if (channel != null) {
      await channel.close();
      await _cleanupChannel(sessionId);
    }
  }

  /// Cleanup channel resources
  Future<void> _cleanupChannel(String sessionId) async {
    _channels.remove(sessionId);
    await _dataControllers[sessionId]?.close();
    _dataControllers.remove(sessionId);
  }

  /// Dispose all channels
  Future<void> dispose() async {
    for (final sessionId in _channels.keys.toList()) {
      await closeDataChannel(sessionId);
    }
  }
}
