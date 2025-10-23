# PeerLink

**Privacy-focused peer-to-peer file transfer app**

PeerLink enables secure, direct file sharing (up to 100MB) between devices without cloud storage. Built with Flutter for Android, iOS, Windows, macOS, and Ubuntu.

## Features

- 🔒 **Privacy-first**: No cloud storage, no user accounts
- 🚀 **Direct P2P transfer**: WebRTC data channels with DTLS encryption
- 📱 **Cross-platform**: Mobile (Android/iOS) and Desktop (Windows/macOS/Ubuntu)
- 🎯 **Simple pairing**: 6-digit code or QR code scanning
- ✅ **File integrity**: SHA-256 streaming verification
- 📊 **Real-time progress**: Transfer percentage and speed (MB/s)
- 🎨 **Material You**: Dynamic theming with teal accent
- 🌍 **Localized**: System language by default

## Tech Stack

- **Framework**: Flutter (Dart ^3.9.2)
- **State Management**: Riverpod (with code generation)
- **P2P**: WebRTC via `flutter_webrtc`
- **Signaling**: Firebase Firestore (free tier)
- **Notifications**: Firebase Cloud Messaging (FCM)
- **Hashing**: SHA-256 via `crypto` package
- **QR Codes**: `qr_flutter` + `mobile_scanner`

## Architecture

Feature-first DDD architecture:
- `lib/src/features/` - Feature modules (transfer, connection, settings)
- `lib/src/core/` - Shared constants, utilities, widgets
- `lib/src/shared/` - Global providers and infrastructure

## Getting Started

### Prerequisites

- Flutter SDK ^3.9.2
- Firebase project configured for all platforms
- Android Studio / Xcode / Visual Studio (platform-specific)

### Installation

```bash
# Clone the repository
git clone https://github.com/carbodex/peerlink.git
cd peerlink

# Install dependencies
flutter pub get

# Run code generation
dart run build_runner watch --delete-conflicting-outputs

# Run the app
flutter run
```

## Development

See `.docs/development-plan.md` for the complete development roadmap.

**Current Status**: Phase 0 Complete ✅ (v0.1.0-setup)

## Project Constraints

- Max file size: 100MB (configurable)
- Free-tier services only (Firebase Spark plan, public TURN server)
- Target: >85% connection success rate
- No memory leaks on large transfers
- V1.0 excludes: Pause/Resume, multi-file transfer, transfer history

## Documentation

- `.docs/prd.md` - Product Requirements Document
- `.docs/ts.md` - Technical Specification
- `.docs/branding.md` - Visual Design Guidelines
- `.docs/development-plan.md` - Development Roadmap

## License

Copyright © 2025 Carbodex. All rights reserved.
