import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peerlink/src/src.dart';

/// Implementation of ConnectionRepository
class ConnectionRepositoryImpl implements ConnectionRepository {
  ConnectionRepositoryImpl({
    required this.signalingService,
    required this.webRtcService,
  });

  final FirestoreSignalingService signalingService;
  final WebRtcService webRtcService;

  final _connectionController = StreamController<PeerConnection>.broadcast();

  @override
  Future<PeerConnection> createConnection() async {
    // Generate session ID
    final sessionId = CodeGenerator.generate();

    // Create peer connection
    await webRtcService.initializePeerConnection();

    // Create offer
    final offer = await webRtcService.createOffer();

    // Create signaling session
    final now = DateTime.now();
    final session = SignalingSession(
      sessionId: sessionId,
      offer: offer.sdp!,
      createdAt: now,
      expiresAt: now.add(const Duration(minutes: 15)),
    );

    // Save to Firestore
    await signalingService.createSession(session);

    // Listen for ICE candidates
    webRtcService.onIceCandidate.listen((candidate) {
      final candidateMap = candidate.toMap() as Map<String, dynamic>;
      signalingService.addCandidate(
        sessionId,
        candidateMap,
        isOffer: true,
      );
    });

    // Watch for answer
    signalingService.watchSession(sessionId).listen((session) {
      if (session?.answer != null) {
        webRtcService.setRemoteDescription(
          RTCSessionDescription(session!.answer!, 'answer'),
        );
      }

      // Add receiver's ICE candidates
      for (final candidate in session?.answerCandidates ?? []) {
        webRtcService.addIceCandidate(
          RTCIceCandidate(
            candidate['candidate'] as String?,
            candidate['sdpMid'] as String?,
            candidate['sdpMLineIndex'] as int?,
          ),
        );
      }
    });

    return PeerConnection(
      sessionId: sessionId,
      state: ConnectionState.gathering,
      localDescription: offer.sdp,
    );
  }

  @override
  Future<PeerConnection> joinConnection(String sessionId) async {
    // Get session from Firestore
    final session = await signalingService.getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }

    // Create peer connection
    await webRtcService.initializePeerConnection();

    // Set remote description (offer)
    await webRtcService.setRemoteDescription(
      RTCSessionDescription(session.offer, 'offer'),
    );

    // Add sender's ICE candidates
    for (final candidate in session.offerCandidates) {
      await webRtcService.addIceCandidate(
        RTCIceCandidate(
          candidate['candidate'] as String?,
          candidate['sdpMid'] as String?,
          candidate['sdpMLineIndex'] as int?,
        ),
      );
    }

    // Create answer
    final answer = await webRtcService.createAnswer();

    // Update session with answer
    await signalingService.updateSessionAnswer(sessionId, answer.sdp!);

    // Listen for ICE candidates
    webRtcService.onIceCandidate.listen((candidate) {
      final candidateMap = candidate.toMap() as Map<String, dynamic>;
      signalingService.addCandidate(
        sessionId,
        candidateMap,
        isOffer: false,
      );
    });

    return PeerConnection(
      sessionId: sessionId,
      state: ConnectionState.connecting,
      localDescription: answer.sdp,
      remoteDescription: session.offer,
    );
  }

  @override
  Future<void> addIceCandidate(
    String sessionId,
    Map<String, dynamic> candidate,
  ) async {
    await webRtcService.addIceCandidate(
      RTCIceCandidate(
        candidate['candidate'] as String?,
        candidate['sdpMid'] as String?,
        candidate['sdpMLineIndex'] as int?,
      ),
    );
  }

  @override
  Future<void> closeConnection(String sessionId) async {
    await webRtcService.close();
    await signalingService.deleteSession(sessionId);
    await _connectionController.close();
  }

  @override
  Stream<PeerConnection> watchConnection(String sessionId) {
    return _connectionController.stream;
  }
}
