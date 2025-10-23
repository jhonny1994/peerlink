# Product Requirements Document (PRD)
## PeerLink: Secure Peer-to-Peer File Transfer - Cross-Platform (Mobile & Desktop)

**Version:** 1.1 | **Date:** October 22, 2025

---

## Executive Summary
PeerLink is a privacy-focused, reliable peer-to-peer file sharing app designed for mobile (iOS, Android) and desktop (Windows, macOS, Linux). It enables users to send files (up to a default of 100MB) directly without involving cloud storage, emphasizing security, speed, and simplicity. This project will leverage free-tier cloud services (Firebase) for signaling and push notifications to maximize feasibility at no cost.

---

## Product Vision
Deliver a straightforward yet robust app that allows fast, encrypted file transfers between devices with minimal setup, ensuring user privacy and high reliability within the constraints of free-tier services.

---

## Core Features (Version 1.1)
- **File Selection & Transfer**: Select any single file up to a configurable size (default 100MB, developer-adjustable).
- **Peer Connection**: Generate a 6-digit short code or scan a QR code for instant pairing.
- **WebRTC DataChannel**: Establish secure, direct P2P connections, with fallback to a free-tier TURN server.
- **Chunked Transfer**: 64KB fixed chunks with automatic buffer management and flow control.
- **Integrity Check**: SHA-256 streaming hash verification to ensure no file corruption.
- **Progress Indicator**: Real-time transfer percentage and speed (e.g., MB/s).
- **Encryption**: Native WebRTC DTLS encryption only.
- **Connection Timeout & Retry**: Automatic handling of connection timeouts and stalls.
- **Localization**: Multi-language support. The app will default to the device's system language.
- **Theming**: Dynamic Material You themes (light/dark/system, seed color).
- **Error Handling**: Clear, user-friendly error messages for common failures (e.g., timeout, hash mismatch, connection fail).
- **Session Cleanup**: Stale connection data is automatically cleaned after 15 minutes.
- **Push Notifications**: Silent notifications to "wake up" the receiving app for an incoming request.
- **Cross-Platform UI**: Responsive layout, native 'Open File' dialog, and drag-and-drop support on desktop.

---

## User Flows
- **First Launch**: User opens app -> User is prompted to grant Camera permission (for QR scanning) -> User is prompted for File/Storage access (when first sending/receiving a file).
- **Send**: User selects a file -> App generates a 6-digit code and a QR code -> User shows QR to receiver or uses the "Copy Code" button -> App waits for connection -> Transfer begins -> User is notified on completion or failure.
- **Receive**: User taps "Receive" -> User enters the 6-digit code or scans the QR code -> App connects to sender -> User is prompted to "Accept" or "Decline" the incoming file transfer -> File downloads & is verified -> User is alerted on completion.

---

## Platform Scope
- iOS
- Android
- Windows
- macOS
- Ubuntu

---

## Constraints
- Developer-controlled max file size (default 100MB, adjustable via a constant).
- Use **Firebase Firestore (free "Spark" plan)** for signaling and metadata exchange.
- Use **Firebase Cloud Messaging (FCM)** for push notifications.
- Use a **free-tier public TURN server** (`openrelay.metered.ca`) for NAT traversal.
- No cloud storage or user accounts.
- Version 1.0 will not include user-initiated "Pause/Resume" (only automatic flow control).

---

## Acceptance Criteria
- Transfers succeed for files up to the configured 100MB size.
- Connection success rate >85% **within the limits of the free-tier TURN server's monthly data quota**.
- No memory leaks or crashes, especially during large file transfers.
- All main features are available on all supported platforms.
- Localization works seamlessly by default.
- UI themes switch instantly.
- User is shown a clear, understandable error if a connection fails (e.g., "Connection timed out") or a file is corrupt (e.g., "File verification failed").

---

## Future Scope (Post-Launch)
- Multi-file transfer
- User-initiated Pause & Resume
- Transfer history
- Native share sheet integration
- In-app language selector