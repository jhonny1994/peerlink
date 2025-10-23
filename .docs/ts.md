# Technical Specification (High-Level)
## PeerLink: Cross-Platform Peer-to-Peer File Transfer

**Version:** 1.1 | **Date:** October 22, 2025

---

## Architecture Overview
- **Pattern**: Feature-first, lean DDD architecture with clear separation:
  - **Presentation Layer:** UI, state (Riverpod)
  - **Domain Layer:** Business logic, use cases
  - **Data Layer:** Repositories, external services
- **Framework**: Flutter (targeting mobile & desktop).
- **Core Libraries & Services**:
  - **WebRTC**: `flutter_webrtc` for P2P data channels.
  - **Signaling**: **Firebase Firestore (Spark Plan)**. Used for exchanging SDP offers/answers and ICE candidates. A session document is created with a 6-digit random ID (the 'short code').
  - **Push Notifications**: **Firebase Cloud Messaging (FCM)**. Used to send a silent, data-only notification to "wake" the receiver's app when a sender initiates a connection.
  - **State Management**: **Riverpod**. Used for both state management and dependency injection.
  - **Hashing**: **crypto** (Dart package). Used for streaming SHA-256 hash calculation.
  - **QR Code**: **qr_flutter** (for generation) and **mobile_scanner** (for scanning).
  - **Localization**: Managed via `.arb` files using the **localizely.flutter-intl** VS Code extension.

---

## Core Data & Algorithms
- **Chunking**: Fixed size 64KB, sequential, with buffer management based on `RTCDataChannel.balancedAmount`.
- **Hashing**:
  - Compute SHA-256 hash of the file stream on both sender and receiver.
  - Implemented in pure Dart using the `crypto` package to avoid platform-channel complexity.
- **Transfer Protocol**:
  - Initiate WebRTC connection via signaling (Firestore).
  - Use DataChannel for transferring chunks with flow control.
  - Monitor `bufferedAmount`; pause send loop if > 256KB to prevent buffer overflow.
- **Security**:
  - WebRTC DTLS encryption (native). No manual encryption layer is added.

---

## Session Management & Cleanup
- **Session Lifecycle**: A sender creates a document in Firestore (e.g., `/sessions/123456`). The receiver reads this document to connect.
- **Session Cleanup**: A **TTL (Time-to-Live) policy** will be set on the Firestore `/sessions/` collection. Documents will be automatically deleted 15 minutes after creation to clean up stale data, fulfilling the PRD requirement at no cost.

---

## Error Handling (Technical to User)
A map of technical failures to user-facing error messages:
- **ICE_GATHER_TIMEOUT_SEC**: "Connection timed out. Please check your network and try again."
- **CONNECTION_TIMEOUT_SEC**: "Could not connect to the other device. Please verify the code."
- **TRANSFER_STALL_TIMEOUT_SEC**: "Transfer stalled and was cancelled. Please try again."
- **SHA256_MISMATCH**: "File verification failed. The file may be corrupt. Please try sending again."
- **TURN_QUOTA_EXCEEDED (if detectable)**: "Connection failed. The free service limit may have been reached. Please try again later."
- **FILE_TOO_LARGE**: "File is larger than the 100MB limit."

---

## Constants & Config
*No code snippets, as requested. These values will be defined in a constants file.*

- **Size limits**
  - MAX_FILE_SIZE_MB: 100
  - CHUNK_SIZE_BYTES: 65536 (64 * 1024)
  - MAX_BUFFER_BYTES: 262144 (256 * 1024)

- **Timeouts (seconds)**
  - ICE_GATHER_TIMEOUT_SEC: 10
  - CONNECTION_TIMEOUT_SEC: 30
  - TRANSFER_STALL_TIMEOUT_SEC: 20

- **Signaling & TURN (Free Tier)**
  - STUN_SERVERS: (List)
    - `stun:stun.l.google.com:19302`
    - `stun:stun1.l.google.com:19302`
    - `stun:stun2.l.google.com:19302`
  - TURN_SERVER: `turn:openrelay.metered.ca:80`
  - TURN_USERNAME: `openrelayproject`
  - TURN_CREDENTIAL: `openrelayproject`