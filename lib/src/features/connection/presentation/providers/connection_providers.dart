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

  /// Create a new connection and return session ID
  Future<void> createConnection() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(connectionRepositoryProvider);
      return repository.createConnection();
    });
  }

  /// Close the connection
  Future<void> closeConnection() async {
    final connection = state.value;
    if (connection != null) {
      final repository = ref.read(connectionRepositoryProvider);
      await repository.closeConnection(connection.sessionId);
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

  /// Join an existing connection with session ID
  Future<void> joinConnection(String sessionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(connectionRepositoryProvider);
      return repository.joinConnection(sessionId);
    });
  }

  /// Close the connection
  Future<void> closeConnection() async {
    final connection = state.value;
    if (connection != null) {
      final repository = ref.read(connectionRepositoryProvider);
      await repository.closeConnection(connection.sessionId);
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
