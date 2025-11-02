import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peerlink/src/src.dart';

/// Implementation of ConnectionRepository
class ConnectionRepositoryImpl implements ConnectionRepository {
  ConnectionRepositoryImpl({
    required this.signalingService,
    required this.webRtcService,
    required this.dataChannelService,
  });

  final FirestoreSignalingService signalingService;
  final WebRtcService webRtcService;
  final DataChannelService dataChannelService;

  late StreamController<PeerConnection> _connectionController =
      StreamController<PeerConnection>.broadcast();
  PeerConnection? _currentConnection;
  StreamSubscription<ConnectionState>? _stateSubscription;
  StreamSubscription<RTCIceCandidate>? _iceCandidateSubscription;
  StreamSubscription<SignalingSession?>? _sessionWatcherSubscription;
  StreamSubscription<RTCDataChannel>? _dataChannelSubscription;
  bool _hasSetRemoteDescription = false;
  final Set<String> _processedCandidates = {};

  @override
  Future<PeerConnection> createConnection() async {
    // Clean up any previous connection state
    await _cleanupSubscriptions();

    // Close and recreate the broadcast controller to prevent memory leaks
    if (!_connectionController.isClosed) {
      await _connectionController.close();
    }
    _connectionController = StreamController<PeerConnection>.broadcast();

    // Generate unique session ID and verify it doesn't exist in Firestore
    var sessionId = '';
    for (var attempt = 0; attempt < 6; attempt++) {
      sessionId = CodeGenerator.generate();
      final existingSession = await signalingService.getSession(sessionId);
      if (existingSession == null) {
        break; // Unique session found
      }
    }

    if (sessionId.isEmpty) {
      throw Exception(
        'Failed to generate unique session ID after 6 attempts',
      );
    }

    // Create peer connection
    final peerConnection = await webRtcService.initializePeerConnection();
    // Create data channel (sender creates it)
    await dataChannelService.createDataChannel(
      peerConnection,
      sessionId,
      'file-transfer',
    );

    // CRITICAL: Set up ICE candidate listener BEFORE creating offer
    // ICE gathering starts during offer creation, so we must listen first
    _iceCandidateSubscription = webRtcService.onIceCandidate.listen((
      candidate,
    ) {
      final candidateMap = candidate.toMap() as Map<String, dynamic>;
      // Add candidate asynchronously without blocking the stream
      unawaited(
        signalingService.addCandidate(
          sessionId,
          candidateMap,
          isOffer: true,
        ),
      );
    });

    // Create offer (ICE gathering starts here)

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

    // Watch for answer and remote ICE candidates
    _sessionWatcherSubscription = signalingService
        .watchSession(sessionId)
        .listen(
          (session) {
            // Handle async operations safely without blocking the stream
            unawaited(_handleSessionUpdate(sessionId, session));
          },
        );

    // Create initial connection object
    final connection = PeerConnection(
      sessionId: sessionId,
      state: ConnectionState.gathering,
      localDescription: offer.sdp,
    );
    _currentConnection = connection;
    _connectionController.add(connection);

    // Listen to WebRTC state changes
    _stateSubscription = webRtcService.onConnectionStateChange.listen((state) {
      if (_currentConnection != null) {
        final updatedConnection = _currentConnection!.copyWith(state: state);
        _currentConnection = updatedConnection;
        _connectionController.add(updatedConnection);
      }
    });

    return connection;
  }

  @override
  Future<PeerConnection> joinConnection(String sessionId) async {
    // Clean up any previous connection state
    await _cleanupSubscriptions();

    // Close and recreate the broadcast controller to prevent memory leaks
    if (!_connectionController.isClosed) {
      await _connectionController.close();
    }
    _connectionController = StreamController<PeerConnection>.broadcast();

    // Get session from Firestore
    final session = await signalingService.getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }

    // Create peer connection
    await webRtcService.initializePeerConnection();

    // Listen for incoming data channel (receiver gets it from sender)
    _dataChannelSubscription = webRtcService.onDataChannel.listen((
      dataChannel,
    ) {
      dataChannelService.registerDataChannel(sessionId, dataChannel);
    });

    // Set remote description (offer)
    await webRtcService.setRemoteDescription(
      RTCSessionDescription(session.offer, 'offer'),
    );
    for (final candidate in session.offerCandidates) {
      await webRtcService.addIceCandidate(
        RTCIceCandidate(
          candidate['candidate'] as String?,
          candidate['sdpMid'] as String?,
          candidate['sdpMLineIndex'] as int?,
        ),
      );
    }

    // Watch for new sender ICE candidates (trickle ICE)
    _sessionWatcherSubscription = signalingService
        .watchSession(sessionId)
        .listen(
          (session) {
            // Handle async operations safely without blocking the stream
            unawaited(_handleReceiverSessionUpdate(session));
          },
        );

    // CRITICAL: Set up ICE candidate listener BEFORE creating answer
    // ICE gathering starts during answer creation, so we must listen first
    _iceCandidateSubscription = webRtcService.onIceCandidate.listen((
      candidate,
    ) {
      final candidateMap = candidate.toMap() as Map<String, dynamic>;
      // Add candidate asynchronously without blocking the stream
      unawaited(
        signalingService.addCandidate(
          sessionId,
          candidateMap,
          isOffer: false,
        ),
      );
    });

    // Create answer (ICE gathering starts here)

    final answer = await webRtcService.createAnswer();

    // Update session with answer
    await signalingService.updateSessionAnswer(sessionId, answer.sdp!);

    // Create connection object
    final connection = PeerConnection(
      sessionId: sessionId,
      state: ConnectionState.connecting,
      localDescription: answer.sdp,
      remoteDescription: session.offer,
    );
    _currentConnection = connection;
    _connectionController.add(connection);

    // Listen to WebRTC state changes
    _stateSubscription = webRtcService.onConnectionStateChange.listen((state) {
      if (_currentConnection != null) {
        final updatedConnection = _currentConnection!.copyWith(state: state);
        _currentConnection = updatedConnection;
        _connectionController.add(updatedConnection);
      }
    });

    return connection;
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
    await _cleanupSubscriptions();
    _currentConnection = null;
    _hasSetRemoteDescription = false;
    _processedCandidates.clear();
    await webRtcService.close();
    await signalingService.deleteSession(sessionId);
    // Don't close broadcast controller - it's reused across connections
  }

  /// Handle session updates for receiver (add sender's ICE candidates)
  Future<void> _handleReceiverSessionUpdate(SignalingSession? session) async {
    // Add new sender's ICE candidates (only new ones)
    for (final candidate in session?.offerCandidates ?? []) {
      final candidateMap = candidate as Map<String, dynamic>;
      final candidateString = candidateMap['candidate'] as String?;

      // Skip if already processed
      if (candidateString != null &&
          !_processedCandidates.contains(candidateString)) {
        _processedCandidates.add(candidateString);

        await webRtcService.addIceCandidate(
          RTCIceCandidate(
            candidateString,
            candidateMap['sdpMid'] as String?,
            candidateMap['sdpMLineIndex'] as int?,
          ),
        );
      }
    }
  }

  /// Handle session updates from Firestore (called asynchronously)
  Future<void> _handleSessionUpdate(
    String sessionId,
    SignalingSession? session,
  ) async {
    // Set remote description only once when answer arrives
    if (session?.answer != null && !_hasSetRemoteDescription) {
      _hasSetRemoteDescription = true;
      await webRtcService.setRemoteDescription(
        RTCSessionDescription(session!.answer, 'answer'),
      );
    }

    // Add receiver's ICE candidates (only new ones)
    for (final candidate in session?.answerCandidates ?? []) {
      final candidateMap = candidate as Map<String, dynamic>;
      final candidateString = candidateMap['candidate'] as String?;

      // Skip if already processed
      if (candidateString != null &&
          !_processedCandidates.contains(candidateString)) {
        _processedCandidates.add(candidateString);

        await webRtcService.addIceCandidate(
          RTCIceCandidate(
            candidateString,
            candidateMap['sdpMid'] as String?,
            candidateMap['sdpMLineIndex'] as int?,
          ),
        );
      }
    }
  }

  /// Clean up all active subscriptions
  Future<void> _cleanupSubscriptions() async {
    await _stateSubscription?.cancel();
    _stateSubscription = null;
    await _iceCandidateSubscription?.cancel();
    _iceCandidateSubscription = null;
    await _sessionWatcherSubscription?.cancel();
    _sessionWatcherSubscription = null;
    await _dataChannelSubscription?.cancel();
    _dataChannelSubscription = null;
  }

  @override
  Stream<PeerConnection> watchConnection(String sessionId) {
    return _connectionController.stream;
  }
}
