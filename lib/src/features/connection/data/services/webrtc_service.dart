import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peerlink/src/src.dart';
import 'package:peerlink/src/src.dart' as domain;

/// WebRTC service for managing peer connections
class WebRtcService {
  WebRtcService();

  RTCPeerConnection? _peerConnection;
  final _stateController = StreamController<domain.ConnectionState>.broadcast();
  final _iceCandidatesController =
      StreamController<RTCIceCandidate>.broadcast();
  final _dataChannelController = StreamController<RTCDataChannel>.broadcast();

  /// Stream of connection state changes
  Stream<domain.ConnectionState> get onConnectionStateChange =>
      _stateController.stream;

  /// Stream of ICE candidates
  Stream<RTCIceCandidate> get onIceCandidate => _iceCandidatesController.stream;

  /// Stream of incoming data channels (for receiver)
  Stream<RTCDataChannel> get onDataChannel => _dataChannelController.stream;

  /// Create a new peer connection
  Future<RTCPeerConnection> initializePeerConnection() async {
    final configuration = ConnectionConstants.rtcConfiguration;
    _peerConnection = await createPeerConnection(configuration);

    // Listen to connection state changes
    _peerConnection!.onConnectionState = (state) {
      _stateController.add(_mapRtcState(state));
    };

    // Listen to ICE candidates
    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _iceCandidatesController.add(candidate);
      }
    };

    // Listen to incoming data channels (receiver side)
    _peerConnection!.onDataChannel = _dataChannelController.add;

    return _peerConnection!;
  }

  /// Create SDP offer
  Future<RTCSessionDescription> createOffer() async {
    if (_peerConnection == null) {
      throw StateError('Peer connection not initialized');
    }

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  /// Create SDP answer
  Future<RTCSessionDescription> createAnswer() async {
    if (_peerConnection == null) {
      throw StateError('Peer connection not initialized');
    }

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  /// Set remote description
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    if (_peerConnection == null) {
      throw StateError('Peer connection not initialized');
    }

    await _peerConnection!.setRemoteDescription(description);
  }

  /// Add ICE candidate
  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    if (_peerConnection == null) {
      throw StateError('Peer connection not initialized');
    }

    await _peerConnection!.addCandidate(candidate);
  }

  /// Close peer connection
  Future<void> close() async {
    await _peerConnection?.close();
    _peerConnection = null;
    await _stateController.close();
    await _iceCandidatesController.close();
    await _dataChannelController.close();
  }

  /// Map RTCPeerConnectionState to domain ConnectionState
  domain.ConnectionState _mapRtcState(RTCPeerConnectionState state) {
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateNew:
        return domain.ConnectionState.disconnected;
      case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
        return domain.ConnectionState.connecting;
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        return domain.ConnectionState.connected;
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        return domain.ConnectionState.failed;
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        return domain.ConnectionState.disconnected;
      case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
        return domain.ConnectionState.closed;
    }
  }

  /// Get current peer connection (for testing)
  RTCPeerConnection? get peerConnection => _peerConnection;
}
