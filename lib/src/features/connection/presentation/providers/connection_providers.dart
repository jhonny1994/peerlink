import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peerlink/src/src.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_providers.g.dart';

/// Provider for Firestore instance
@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) {
  return FirebaseFirestore.instance;
}

/// Provider for FirestoreSignalingService
@Riverpod(keepAlive: true)
FirestoreSignalingService firestoreSignalingService(
  Ref ref,
) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreSignalingService(firestore);
}

/// Provider for WebRtcService
@Riverpod(keepAlive: true)
WebRtcService webRtcService(Ref ref) {
  return WebRtcService();
}

/// Provider for DataChannelService
@Riverpod(keepAlive: true)
DataChannelService dataChannelService(Ref ref) {
  return DataChannelService();
}

/// Provider for ConnectionTimeoutService
@Riverpod(keepAlive: true)
ConnectionTimeoutService connectionTimeoutService(Ref ref) {
  return ConnectionTimeoutService();
}

/// Provider for SessionCleanupService
@Riverpod(keepAlive: true)
SessionCleanupService sessionCleanupService(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return SessionCleanupService(firestore: firestore);
}

/// Provider for ConnectionRepository
@Riverpod(keepAlive: true)
ConnectionRepository connectionRepository(Ref ref) {
  final signalingService = ref.watch(firestoreSignalingServiceProvider);
  final webRtcService = ref.watch(webRtcServiceProvider);
  final dataChannelService = ref.watch(dataChannelServiceProvider);

  return ConnectionRepositoryImpl(
    signalingService: signalingService,
    webRtcService: webRtcService,
    dataChannelService: dataChannelService,
  );
}

/// Provider for creating a connection (sender)
/// keepAlive: true prevents auto-dispose during navigation
@Riverpod(keepAlive: true)
class ConnectionCreator extends _$ConnectionCreator {
  @override
  FutureOr<PeerConnection?> build() {
    return null;
  }

  /// Create a new connection and return session ID.
  ///
  /// Initializes WebRTC connection and creates Firestore session document.
  /// The session contains:
  /// - 6-digit code for receiver to join
  /// - SDP offer for WebRTC negotiation
  /// - Timestamps for expiration tracking
  ///
  /// Throws exceptions on failure (handled by AsyncValue).
  Future<void> createConnection() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(connectionRepositoryProvider);
      return repository.createConnection();
    });
  }

  /// Close the connection and cleanup session.
  ///
  /// Performs:
  /// 1. Closes WebRTC peer connection
  /// 2. Closes data channels
  /// 3. Deletes Firestore session document (best-effort)
  ///
  /// Cleanup failure doesn't affect connection closure.
  Future<void> closeConnection() async {
    final connection = state.value;
    if (connection != null) {
      final repository = ref.read(connectionRepositoryProvider);
      await repository.closeConnection(connection.sessionId);

      // Cleanup session from Firestore (sender-side)
      final cleanupService = ref.read(sessionCleanupServiceProvider);
      await cleanupService.deleteSession(connection.sessionId);

      state = const AsyncValue.data(null);
    }
  }
}

/// Provider for joining a connection (receiver)
/// keepAlive: true prevents auto-dispose during navigation
@Riverpod(keepAlive: true)
class ConnectionJoiner extends _$ConnectionJoiner {
  @override
  FutureOr<PeerConnection?> build() {
    return null;
  }

  /// Join an existing connection with session ID.
  ///
  /// Validates session before attempting connection:
  /// - Checks session exists in Firestore
  /// - Verifies session not expired (< 15 minutes old)
  /// - Throws [SessionExpiredException] if validation fails
  ///
  /// If valid:
  /// - Retrieves SDP offer from session
  /// - Creates WebRTC answer
  /// - Establishes peer connection
  ///
  /// All errors are wrapped in AsyncValue for UI consumption.
  Future<void> joinConnection(String sessionId) async {
    // Validate session before joining
    final cleanupService = ref.read(sessionCleanupServiceProvider);
    final isValid = await cleanupService.isSessionValid(sessionId);

    if (!isValid) {
      state = AsyncValue.error(
        const SessionExpiredException(),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(connectionRepositoryProvider);
      return repository.joinConnection(sessionId);
    });
  }

  /// Close the connection and cleanup session.
  ///
  /// Performs:
  /// 1. Closes WebRTC peer connection
  /// 2. Closes data channels
  /// 3. Deletes Firestore session document (best-effort)
  ///
  /// Cleanup failure doesn't affect connection closure.
  Future<void> closeConnection() async {
    final connection = state.value;
    if (connection != null) {
      final repository = ref.read(connectionRepositoryProvider);
      await repository.closeConnection(connection.sessionId);

      // Cleanup session from Firestore (receiver-side)
      final cleanupService = ref.read(sessionCleanupServiceProvider);
      await cleanupService.deleteSession(connection.sessionId);

      state = const AsyncValue.data(null);
    }
  }
}

/// Provider for watching connection state changes
@riverpod
Stream<PeerConnection> connectionStream(
  Ref ref,
  String sessionId,
) {
  final repository = ref.watch(connectionRepositoryProvider);
  return repository.watchConnection(sessionId);
}
