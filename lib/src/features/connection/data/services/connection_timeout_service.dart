import 'dart:async';
import 'package:peerlink/src/core/core.dart';

/// Service for handling connection timeouts
class ConnectionTimeoutService {
  final Map<String, Timer> _timers = {};
  final Map<String, DateTime> _lastActivityTimes = {};

  /// Start ICE gathering timeout
  Future<void> startIceGatheringTimeout(
    String sessionId,
    void Function() onTimeout,
  ) async {
    _cancelTimer(sessionId);
    _timers[sessionId] = Timer(
      Duration(seconds: ConnectionConstants.iceGatherTimeoutSec),
      () {
        onTimeout();
        _cleanup(sessionId);
      },
    );
  }

  /// Start connection establishment timeout
  Future<void> startConnectionTimeout(
    String sessionId,
    void Function() onTimeout,
  ) async {
    _cancelTimer(sessionId);
    _timers[sessionId] = Timer(
      Duration(seconds: ConnectionConstants.connectionTimeoutSec),
      () {
        onTimeout();
        _cleanup(sessionId);
      },
    );
  }

  /// Start transfer stall detection
  Future<void> startTransferStallDetection(
    String sessionId,
    void Function() onStall,
  ) async {
    _lastActivityTimes[sessionId] = DateTime.now();
    _cancelTimer(sessionId);

    // Check periodically if transfer has stalled
    _timers[sessionId] = Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        final lastActivity = _lastActivityTimes[sessionId];
        if (lastActivity == null) {
          timer.cancel();
          return;
        }

        final stallDuration = DateTime.now().difference(lastActivity).inSeconds;
        if (stallDuration >= ConnectionConstants.transferStallTimeoutSec) {
          onStall();
          _cleanup(sessionId);
          timer.cancel();
        }
      },
    );
  }

  /// Update last activity time (call this when transfer progress happens)
  void updateActivity(String sessionId) {
    _lastActivityTimes[sessionId] = DateTime.now();
  }

  /// Cancel timeout for session
  void cancelTimeout(String sessionId) {
    _cancelTimer(sessionId);
    _lastActivityTimes.remove(sessionId);
  }

  /// Cancel all timeouts
  void cancelAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _lastActivityTimes.clear();
  }

  void _cancelTimer(String sessionId) {
    _timers[sessionId]?.cancel();
    _timers.remove(sessionId);
  }

  void _cleanup(String sessionId) {
    _cancelTimer(sessionId);
    _lastActivityTimes.remove(sessionId);
  }

  /// Dispose all resources
  void dispose() {
    cancelAll();
  }
}
