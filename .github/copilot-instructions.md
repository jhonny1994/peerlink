# PeerLink - Copilot Instructions

PeerLink is a privacy-focused P2P file transfer app (Flutter) using WebRTC for direct device connections, Firebase Firestore (free tier) for signaling, and FCM for notifications. 

**Current Status (Phase 5)**: Backend complete (connection + transfer features), shared services ready (file picker, permissions), routing infrastructure complete, now implementing sender/receiver UI screens.

## Project Vision & Goals

**Target**: 100MB max file size, >85% connection success rate (free-tier TURN limits), zero cloud storage, no user accounts. **User flows**: Sender generates 6-digit code/QR → Receiver scans/enters → Accept/Decline prompt → Transfer with real-time progress (%, MB/s) → SHA-256 verification → Completion alert.

## Development Approach

**Shared-first architecture**: Setup complete shared infrastructure (providers, theme, i18n) in Phase 1 before any features. **Global provider pattern**: Create base providers in `lib/src/shared/` that throw `UnimplementedError`, then override with actual implementations in `main.dart`. All features consume shared infrastructure—no duplication.

Follow development phases in `.docs/development-plan.md`. Check off tasks as completed. Single `main` branch workflow with semantic versioning tags at phase completion.

## Architecture & Structure

**Feature-first DDD**: Organize as `lib/src/features/{transfer,connection,settings,sender,receiver,home}/` with `domain/`, `data/`, `presentation/` subdirs. Each feature has a **barrel file** (e.g., `transfer.dart`) exporting public APIs only. Import via `import 'package:peerlink/src/features/transfer/transfer.dart';`. 

**Shared code**: 
- `lib/src/shared/` - Providers (`SharedPreferencesProvider`, `themeModeProvider`, `localeProvider`), services (`FilePickerService`, `PermissionService`)
- `lib/src/core/` - Constants, routing (`AppRoutes`, `AppNavigator`), utilities

**Routing**: Use `AppNavigator` helper methods for navigation (e.g., `AppNavigator.toSenderCode(context)`) or direct `Navigator.pushNamed()` with `AppRoutes` constants. All screens already wired in `main.dart`.

**Tech stack**: Riverpod (state + DI), `flutter_webrtc`, Firebase (Firestore + FCM), `crypto` (SHA-256), `qr_flutter`, `mobile_scanner`, `shared_preferences`, `file_picker`, `permission_handler`, ARB files (i18n via `localizely.flutter-intl`).

**Platforms**: Android, iOS, Windows, macOS, Ubuntu. Desktop supports drag-and-drop + native file dialogs. Mobile requires Camera (QR) and File/Storage permissions (requested on first use).

## Critical File Transfer Logic

- **Chunking**: Fixed 64KB (`CHUNK_SIZE_BYTES = 65536`), sequential. Monitor `RTCDataChannel.bufferedAmount`—pause sending if > 256KB (`MAX_BUFFER_BYTES`) to prevent buffer overflow.
- **Integrity**: Streaming SHA-256 on both ends (pure Dart via `crypto` package—no platform channels). Reject entire transfer on mismatch.
- **Signaling flow**: Sender creates `/sessions/{6-digit-code}` in Firestore with SDP offer. Receiver reads, sends answer. ICE candidates exchanged via same doc (auto-deleted after 15 min via Firestore TTL).
- **Connection**: STUN servers (`stun.l.google.com:19302`, `stun1.l.google.com:19302`, `stun2.l.google.com:19302`), TURN fallback (`turn:openrelay.metered.ca:80`, username/credential: `openrelayproject`).
- **Encryption**: WebRTC DTLS only (native). No additional encryption layer.
- **Progress UI**: Show percentage + transfer speed (e.g., "55% - 12.5 MB/s").

## Constants (`lib/src/core/constants/`)

```dart
MAX_FILE_SIZE_MB = 100
CHUNK_SIZE_BYTES = 65536
MAX_BUFFER_BYTES = 262144
ICE_GATHER_TIMEOUT_SEC = 10
CONNECTION_TIMEOUT_SEC = 30
TRANSFER_STALL_TIMEOUT_SEC = 20
```

## Error Mapping (Technical → User)

Map technical errors to these exact user-friendly messages:
- `ICE_GATHER_TIMEOUT_SEC`: "Connection timed out. Please check your network and try again."
- `CONNECTION_TIMEOUT_SEC`: "Could not connect to the other device. Please verify the code."
- `TRANSFER_STALL_TIMEOUT_SEC`: "Transfer stalled and was cancelled. Please try again."
- `SHA256_MISMATCH`: "File verification failed. The file may be corrupt. Please try sending again."
- `FILE_TOO_LARGE`: "File is larger than the 100MB limit."
- `TURN_QUOTA_EXCEEDED`: "Connection failed. The free service limit may have been reached. Please try again later."

Display errors via non-intrusive snackbars/dialogs—keep text calm and guidance-oriented.

## Initial Setup (Phase 0-2 from dev plan)

```bash
# Phase 0: Foundation (COMPLETE ✅)
flutter pub add riverpod flutter_riverpod riverpod_annotation flutter_webrtc firebase_core cloud_firestore firebase_messaging crypto qr_flutter mobile_scanner shared_preferences file_picker permission_handler
flutter pub add --dev riverpod_generator build_runner riverpod_lint

# Phase 1: Shared infrastructure (COMPLETE ✅)
# All providers created and wired: SharedPreferencesProvider, themeModeProvider, localeProvider
# Code generation running: dart run build_runner watch --delete-conflicting-outputs

# Phase 2: Constants & Core (COMPLETE ✅)
# Constants defined in lib/src/core/constants/
# Routing setup in lib/src/core/routing/ (AppRoutes + AppNavigator)

# Phase 3: Connection Feature (COMPLETE ✅)
# WebRTC, Firestore signaling, 6-digit codes, timeouts all implemented

# Phase 4: Transfer Feature (COMPLETE ✅)
# Chunking, SHA-256, buffer management, progress tracking all implemented

# Phase 5: Sender UI (IN PROGRESS 🔄)
# HomeScreen ✅, FilePickerService ✅, PermissionService ✅, Routing ✅
# TODO: Implement actual sender screens (file picker, code display, progress)
```

## Shared Services (lib/src/shared/services/)

**FilePickerService**: Wraps `file_picker` package with:
- 100MB size validation (throws `FileTooLargeException` if exceeded)
- Returns `File?` (null if user cancels)
- Use: `final file = await ref.read(filePickerServiceProvider).pickFile();`

**PermissionService**: Handles runtime permissions with:
- `requestCameraPermission()` - For QR scanning
- `requestStoragePermission()` - For file saving (Android-specific)
- Returns `PermissionResult` enum (granted/denied/permanentlyDenied/notRequired)
- Use: `final result = await ref.read(permissionServiceProvider).requestCameraPermission();`

**Navigation**: Use `AppNavigator` static methods:
- `AppNavigator.toSenderCode(context)` - Type-safe navigation
- `AppNavigator.popUntilHome(context)` - Return to home
- All routes defined in `AppRoutes` class

## Platform Quirks

- **Android**: Gradle uses Kotlin DSL (`.gradle.kts`). Custom build dir `../../build` (not per-module). Java 11, Kotlin JVM target 11. Namespace: `com.carbodex.peerlink`.
- **iOS**: Display name "Peerlink". High refresh rate enabled. Supports all orientations (iPad includes upside-down).
- **Desktop**: Native file picker dialogs, drag-and-drop support for file selection. Consider different UX patterns vs. mobile touch-first.
- **Theming**: Material You with teal seed color `008080`. Minimalist "P+L" monogram logo (interlinked, continuous loop). Roboto/Google Sans typography.
- **UI Pattern**: Large "Send"/"Receive" buttons, progress with percentage + MB/s, "Copy Code" button for 6-digit code, ample whitespace, Material Icons.

## Key Constraints & Acceptance Criteria

- No cloud storage or user accounts (privacy-first)
- Free-tier services only (Firebase Spark plan, public TURN server)
- >85% connection success rate within TURN quota limits
- No memory leaks on large transfers (100MB files)
- System language localization by default
- V1.0 excludes: Pause/Resume (auto flow control only), multi-file transfer, transfer history

## Development Workflow

1. **Follow `.docs/development-plan.md`** phases sequentially
2. **Check off tasks** as you complete them in the dev plan
3. **Phase 1 first**: Complete shared infrastructure before touching features
4. **Single `main` branch**: Commit directly with conventional commits
5. **Tag at phase completion**: `v0.x.0` for phases, `v1.0.0` for release
6. **Test manually** as you build each feature

## References

See `.docs/prd.md` (features, user flows), `.docs/ts.md` (WebRTC protocol, Firestore schema), `.docs/branding.md` (UI/UX guidelines), `.docs/development-plan.md` (tasks to check off).
