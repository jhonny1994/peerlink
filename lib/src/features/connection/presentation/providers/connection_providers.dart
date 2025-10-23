import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peerlink/src/features/connection/connection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connection_providers.g.dart';

/// Provider for Firestore instance
@riverpod
FirebaseFirestore firestore(Ref ref) {
  return FirebaseFirestore.instance;
}

/// Provider for FirestoreSignalingService
@riverpod
FirestoreSignalingService firestoreSignalingService(
  Ref ref,
) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreSignalingService(firestore);
}

/// Provider for WebRtcService
@riverpod
WebRtcService webRtcService(Ref ref) {
  return WebRtcService();
}

/// Provider for ConnectionRepository
@riverpod
ConnectionRepository connectionRepository(Ref ref) {
  final signalingService = ref.watch(firestoreSignalingServiceProvider);
  final webRtcService = ref.watch(webRtcServiceProvider);

  return ConnectionRepositoryImpl(
    signalingService: signalingService,
    webRtcService: webRtcService,
  );
}

/// Provider for creating a connection (sender)
@riverpod
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
      return await repository.createConnection();
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
@riverpod
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
      return await repository.joinConnection(sessionId);
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
