# PeerLink Development Plan

**Version:** 1.0 | **Date:** October 22, 2025

## Phase 0: Foundation & Setup ✅

- [x] Initialize Git repository (`.gitignore`, initial commit)
- [x] Install dependencies (Riverpod, WebRTC, Firebase, crypto, QR packages)
- [x] Install `shared_preferences` package
- [x] Create project structure (`lib/src/features/`, `lib/src/core/`, `lib/src/shared/`)
- [x] Commit and tag as `v0.1.0-setup`

## Phase 1: Shared Infrastructure ✅

- [x] Create global `SharedPreferencesProvider` in `lib/src/shared/` (throws `UnimplementedError`)
- [x] Override provider in `main.dart` with actual `SharedPreferences` instance
- [x] Set up Riverpod `ProviderScope` in `main.dart`
- [x] Configure internationalization (ARB files, `localizely.flutter-intl`)
- [x] Create locale provider (reads from shared prefs, defaults to system language)
- [x] Implement dynamic Material You theming (teal seed color `#008080`)
- [x] Create theme mode provider (light/dark/system from shared prefs)
- [x] Wire theme and locale providers to `MaterialApp`
- [x] Set up Riverpod code generation (`build_runner watch`)
- [x] Test theme switching and locale changes
- [x] Commit and tag as `v0.2.0-shared`

## Phase 2: Constants & Core Utilities

- [x] Define constants in `lib/src/core/constants/` (file sizes, timeouts, STUN/TURN)
- [x] Create error mapping utilities (technical → user-friendly messages)
- [x] Set up Firebase project (Firestore + FCM)
- [x] Configure Firebase for all platforms (Android, iOS, Windows, macOS, Ubuntu)
- [x] Initialize Firebase in `main.dart`
- [x] Commit and tag as `v0.3.0-core`

## Phase 3: Connection Feature ⚠️

- [x] **Connection Feature** - Domain layer (entities, repository interfaces)
- [x] **Connection Feature** - Data layer (WebRTC service, Firestore signaling)
- [x] **Connection Feature** - Presentation layer (Riverpod providers)
- [x] Implement STUN/TURN configuration
- [x] Implement Firestore session management (`/sessions/{code}`)
- [x] Implement 6-digit code generation
- [x] Add connection timeout handling (constants defined)
- [ ] **BUG FIX REQUIRED:** Fix memory leaks - manage stream subscriptions (ICE candidates, signaling, data channel)
- [ ] **BUG FIX REQUIRED:** Connection state stream not emitting updates (partially fixed, needs testing)
- [x] Commit and tag as `v0.4.0-connection`

## Phase 4: File Transfer ⚠️

- [x] **Transfer Feature** - Domain layer (file transfer entity, use cases)
- [x] **Transfer Feature** - Data layer (chunking, SHA-256 streaming)
- [x] **Transfer Feature** - Presentation layer (transfer state providers)
- [x] Implement 64KB chunking with buffer management
- [x] Implement streaming SHA-256 hash calculation
- [x] Implement transfer flow control (pause on buffer overflow)
- [x] Add file size validation (100MB limit)
- [x] Implement transfer progress tracking (%, MB/s)
- [ ] **BUG FIX REQUIRED:** Fix lost data between metadata and file chunk stream subscriptions
- [ ] **BUG FIX REQUIRED:** Implement timeout service integration (ICE gathering, connection, transfer stall)
- [ ] **BUG FIX REQUIRED:** Add retry logic for failed transfers
- [x] Commit and tag as `v0.5.0-transfer`

## Phase 5: Sender UI ✅

- [x] Home screen with "Send" button
- [x] File picker service with 100MB validation
- [x] Permission service for runtime permissions
- [x] Navigation/routing setup (AppRoutes + AppNavigator)
- [x] Placeholder screens for sender flow
- [x] Implement sender file picker screen (use FilePickerService)
- [x] Display 6-digit code + QR code
- [x] "Copy Code" functionality
- [x] Transfer progress screen (percentage + speed)
- [x] Success/failure notifications
- [x] Error handling UI (snackbars/dialogs)
- [x] Desktop drag-and-drop support
- [x] Commit and tag as `v0.6.0-sender`

## Phase 6: Receiver UI ⚠️

- [x] Home screen with "Receive" button
- [x] Placeholder screens for receiver flow
- [x] Implement receiver code entry screen (6-digit input)
- [x] QR scanner integration (use mobile_scanner + PermissionService)
- [x] Camera permission handling (use PermissionService)
- [x] Accept/Decline file prompt
- [x] File/Storage permission handling (use PermissionService)
- [x] Transfer progress screen (percentage + speed)
- [x] Success/failure notifications
- [ ] **BUG FIX REQUIRED:** Replace hardcoded fake data in accept screen with real metadata exchange
- [ ] **BUG FIX REQUIRED:** Replace hardcoded save path with platform-specific paths (use `path_provider`)
- [ ] **BUG FIX REQUIRED:** Add proper file save location picker for desktop platforms
- [x] Commit and tag as `v0.7.0-receiver`

## Phase 7: Settings UI ✅

- [x] **Settings Feature** - Settings screen placeholder
- [x] Settings route and navigation wiring
- [x] Implement theme switcher UI (light/dark/system) using themeModeProvider
- [x] Language selector UI (optional - if adding in-app selector) using localeProvider
- [x] Settings persistence (already handled by providers)
- [x] About section (app version, licenses)
- [x] Commit and tag as `v0.8.0-settings`

## Phase 7.5: Critical Bug Fixes & Stabilization 🚨

**Connection Repository:**
- [ ] Fix memory leaks - store and cancel all stream subscriptions
  - [ ] ICE candidate stream subscriptions (sender + receiver)
  - [ ] Firestore signaling session watcher
  - [ ] Data channel stream subscription
- [ ] Test connection state stream emissions (verify auto-navigation works)
- [ ] Add proper cleanup in `closeConnection()`

**Transfer Repository:**
- [ ] Refactor `receiveFile()` to use SINGLE continuous stream for metadata + chunks
  - [ ] Remove separate `_receiveMetadata()` stream subscription
  - [ ] Handle metadata as first message in main receive loop
  - [ ] Ensure no data loss between subscriptions
- [ ] Integrate `ConnectionTimeoutService` for all operations
  - [ ] ICE gathering timeout (10 seconds)
  - [ ] Connection establishment timeout (30 seconds)
  - [ ] Transfer stall detection (20 seconds)
- [ ] Add transfer retry logic on network failures

**Receiver UI:**
- [ ] Implement real metadata exchange in accept screen
  - [ ] Sender sends metadata when receiver joins (before transfer starts)
  - [ ] Receiver displays actual file name, size, type in accept dialog
  - [ ] Remove hardcoded placeholder data
- [ ] Fix file save paths (platform-specific)
  - [ ] Android: Use `path_provider` for external storage with proper permissions
  - [ ] iOS: Use `path_provider` for app documents directory
  - [ ] Desktop: Use file picker dialog for save location
  - [ ] Handle filename conflicts (auto-rename or prompt user)

**Testing Requirements:**
- [ ] End-to-end transfer on two physical devices (Android/iOS)
- [ ] Large file (100MB) transfer without memory issues
- [ ] Network interruption handling test
- [ ] Multiple consecutive transfers (verify no memory leaks)
- [ ] Platform-specific path testing on all platforms

**Commit and tag as `v0.8.5-stabilization`**

## Phase 8: Platform Polish

- [x] Desktop drag-and-drop support (Windows, macOS, Ubuntu)
- [x] Android/iOS permissions verified (Camera, Storage, Network, Notifications)
- [ ] Keyboard shortcuts for desktop (Ctrl/Cmd+O, Ctrl/Cmd+C, ESC)
- [ ] Haptic feedback for mobile interactions
- [ ] Android-specific: Transfer notifications, adaptive icon
- [ ] iOS-specific: Transfer notifications, app icon
- [ ] Platform-specific file save dialogs (integrated in Phase 7.5)
- [ ] Better error message mapping through ErrorMapper
- [ ] Loading states and empty states polish
- [ ] Commit and tag as `v0.9.0-polish`

## Phase 9: Firebase Integration

- [ ] Firestore security rules
- [ ] Firestore TTL cleanup (15 min session expiry)
- [ ] FCM silent notifications implementation
- [ ] FCM token management
- [ ] Test Firebase integration on all platforms
- [ ] Commit and tag as `v0.10.0-firebase`

## Phase 10: Release Preparation

- [ ] App icon finalization (P+L monogram)
- [ ] App store assets (screenshots, descriptions)
- [ ] Release signing configuration (Android/iOS)
- [ ] Privacy policy + terms of service
- [ ] Update README with user documentation
- [ ] Create release notes
- [ ] Commit and tag as `v1.0.0`

## Phase 11: Deployment

- [ ] Build release APK/AAB (Android)
- [ ] Build release IPA (iOS)
- [ ] Build release executables (Windows, macOS, Ubuntu)
- [ ] Submit to Google Play Store
- [ ] Submit to Apple App Store
- [ ] Publish desktop releases (GitHub Releases)
- [ ] Monitor initial user feedback
- [ ] Tag as `v1.0.0-release`

## Git Workflow

- **Single branch:** Work directly on `main` branch
- **Commit convention:** `type(scope): message` (e.g., `feat(shared): add theme provider`)
- **Tags:** Semantic versioning at phase completion (`v0.x.0` for phases, `v1.0.0` for release)
- **Commits:** Atomic commits for each completed task

## Notes

- **Shared-first approach:** Phase 1 sets up all shared infrastructure (providers, theme, i18n)
- **Global provider pattern:** `SharedPreferencesProvider` throws `UnimplementedError`, overridden in `main.dart`
- Each phase builds on previous phases (chronological order)
- Feature-by-feature approach after shared setup (connection → transfer → UI → polish)
- Version control at every phase completion
- DRY principle: Shared infrastructure reused across all features
- Test manually as you build features

## Critical Issues Discovered (Oct 30, 2025)

**Status:** Phases 3, 4, 6 have critical bugs preventing production deployment

**Bug Summary:**
1. **Connection Repository** - Memory leaks from unmanaged stream subscriptions
2. **Transfer Repository** - Lost file data between metadata/chunk stream subscriptions  
3. **Transfer Repository** - Timeout service defined but never used
4. **Receiver Accept Screen** - Shows hardcoded fake file data instead of real metadata
5. **Receiver Progress** - Hardcoded save path won't work on iOS/Android

**Resolution:** New Phase 7.5 inserted for critical bug fixes and stabilization before platform polish and release.
