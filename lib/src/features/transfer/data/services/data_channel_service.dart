import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peerlink/src/src.dart';

/// Service for managing WebRTC data channels
class DataChannelService {
  final Map<String, RTCDataChannel> _channels = {};
  final Map<String, StreamController<Uint8List>> _dataControllers = {};
  // Buffer incoming data until someone subscribes - CRITICALLY IMPORTANT
  final Map<String, List<Uint8List>> _dataBuffer = {};
  // Track if buffer has been flushed already
  final Map<String, bool> _bufferFlushed = {};

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

    _setupDataChannel(sessionId, dataChannel);
  }

  /// Register an existing data channel (for receiver)
  void registerDataChannel(String sessionId, RTCDataChannel dataChannel) {
    _setupDataChannel(sessionId, dataChannel);
  }

  /// Setup data channel listeners
  void _setupDataChannel(String sessionId, RTCDataChannel dataChannel) {
    _channels[sessionId] = dataChannel;
    // Initialize buffer for this session
    _dataBuffer[sessionId] = [];
    _bufferFlushed[sessionId] = false;
    // Create BROADCAST controller so multiple listeners can subscribe
    _dataControllers[sessionId] = StreamController<Uint8List>.broadcast();

    // Listen for incoming data
    dataChannel
      ..onMessage = (RTCDataChannelMessage message) {
        if (message.isBinary) {
          final controller = _dataControllers[sessionId];
          if (controller != null) {
            // CRITICAL FIX: Only send directly if there's an active listener
            // Otherwise, keep buffering to prevent data loss on broadcast streams
            if (controller.hasListener) {
              controller.add(message.binary);
            } else {
              // Buffer until someone subscribes

              _dataBuffer[sessionId]?.add(message.binary);
            }
          }
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

    // Wait for buffer to drain if full - CRITICAL FIX: use WHILE loop
    var bufferedAmount = await getBufferedAmount(sessionId);
    while (bufferedAmount > TransferConstants.maxBufferBytes) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bufferedAmount = await getBufferedAmount(sessionId);
    }

    await channel.send(RTCDataChannelMessage.fromBinary(data));
  }

  /// Get stream of incoming data
  Future<Stream<Uint8List>> onDataReceived(String sessionId) async {
    final controller = _dataControllers[sessionId];
    if (controller == null) {
      throw StateError('Data channel not found for session: $sessionId');
    }

    // Flush any buffered data first (only once per session)
    final buffer = _dataBuffer[sessionId];
    final alreadyFlushed = _bufferFlushed[sessionId] ?? false;

    if (buffer != null && buffer.isNotEmpty && !alreadyFlushed) {
      _bufferFlushed[sessionId] = true;

      // Flush immediately and synchronously to prevent race conditions
      // We must flush before returning the stream to ensure no data loss
      final bufferedData = List<Uint8List>.from(buffer);
      buffer.clear();

      // Schedule emission in next microtask (runs before event loop continues)
      unawaited(
        Future.microtask(() {
          for (final data in bufferedData) {
            if (controller.hasListener) {
              controller.add(data);
            }
          }
        }),
      );
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

  /// Wait for data channel to be ready
  Future<void> waitForDataChannel(
    String sessionId, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (!isChannelOpen(sessionId)) {
      if (stopwatch.elapsed > timeout) {
        throw TimeoutException(
          'Data channel did not open within ${timeout.inSeconds} seconds',
        );
      }

      // Check if channel exists but not open yet
      final channel = _channels[sessionId];
      if (channel != null) {
        if (channel.state == RTCDataChannelState.RTCDataChannelClosed) {
          throw StateError('Data channel closed unexpectedly');
        }
      } else {}

      // Wait a bit before checking again
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    stopwatch.stop();
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
    _dataBuffer.remove(sessionId);
    _bufferFlushed.remove(sessionId);
  }

  /// Dispose all channels
  Future<void> dispose() async {
    for (final sessionId in _channels.keys.toList()) {
      await closeDataChannel(sessionId);
    }
  }
}
