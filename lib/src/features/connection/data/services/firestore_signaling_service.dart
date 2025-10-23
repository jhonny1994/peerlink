import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peerlink/src/features/connection/domain/entities/signaling_session.dart';
import 'package:peerlink/src/features/connection/domain/repositories/connection_repository.dart';

/// Firestore implementation of SignalingRepository
class FirestoreSignalingService implements SignalingRepository {
  FirestoreSignalingService(this._firestore);

  final FirebaseFirestore _firestore;

  /// Collection reference for sessions
  CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('sessions');

  @override
  Future<void> createSession(SignalingSession session) async {
    await _sessions.doc(session.sessionId).set(session.toFirestore());
  }

  @override
  Future<SignalingSession?> getSession(String sessionId) async {
    final doc = await _sessions.doc(sessionId).get();
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    return SignalingSession.fromFirestore(sessionId, data);
  }

  @override
  Future<void> updateSessionAnswer(String sessionId, String answer) async {
    await _sessions.doc(sessionId).update({'answer': answer});
  }

  @override
  Future<void> addCandidate(
    String sessionId,
    Map<String, dynamic> candidate, {
    required bool isOffer,
  }) async {
    final field = isOffer ? 'offerCandidates' : 'answerCandidates';
    await _sessions.doc(sessionId).update({
      field: FieldValue.arrayUnion([candidate]),
    });
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _sessions.doc(sessionId).delete();
  }

  @override
  Stream<SignalingSession?> watchSession(String sessionId) {
    return _sessions.doc(sessionId).snapshots().map((doc) {
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return SignalingSession.fromFirestore(sessionId, data);
    });
  }
}
