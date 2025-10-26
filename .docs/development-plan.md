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

## Phase 3: Connection Feature

- [x] **Connection Feature** - Domain layer (entities, repository interfaces)
- [x] **Connection Feature** - Data layer (WebRTC service, Firestore signaling)
- [x] **Connection Feature** - Presentation layer (Riverpod providers)
- [x] Implement STUN/TURN configuration
- [x] Implement Firestore session management (`/sessions/{code}`)
- [x] Implement 6-digit code generation
- [x] Add connection timeout handling (constants defined)
- [x] Commit and tag as `v0.4.0-connection`

## Phase 4: File Transfer

- [x] **Transfer Feature** - Domain layer (file transfer entity, use cases)
- [x] **Transfer Feature** - Data layer (chunking, SHA-256 streaming)
- [x] **Transfer Feature** - Presentation layer (transfer state providers)
- [x] Implement 64KB chunking with buffer management
- [x] Implement streaming SHA-256 hash calculation
- [x] Implement transfer flow control (pause on buffer overflow)
- [x] Add file size validation (100MB limit)
- [x] Implement transfer progress tracking (%, MB/s)
- [x] Commit and tag as `v0.5.0-transfer`

## Phase 5: Sender UI

- [x] Home screen with "Send" button
- [x] File picker service with 100MB validation
- [x] Permission service for runtime permissions
- [x] Navigation/routing setup (AppRoutes + AppNavigator)
- [x] Placeholder screens for sender flow
- [ ] Desktop drag-and-drop support
- [ ] Implement sender file picker screen (use FilePickerService)
- [ ] Display 6-digit code + QR code
- [ ] "Copy Code" functionality
- [ ] Transfer progress screen (percentage + speed)
- [ ] Success/failure notifications
- [ ] Error handling UI (snackbars/dialogs)
- [ ] Commit and tag as `v0.6.0-sender`

## Phase 6: Receiver UI

- [x] Home screen with "Receive" button
- [x] Placeholder screens for receiver flow
- [ ] Implement receiver code entry screen (6-digit input)
- [ ] QR scanner integration (use mobile_scanner + PermissionService)
- [ ] Camera permission handling (use PermissionService)
- [ ] Accept/Decline file prompt
- [ ] File/Storage permission handling (use PermissionService)
- [ ] Transfer progress screen (percentage + speed)
- [ ] Success/failure notifications
- [ ] Commit and tag as `v0.7.0-receiver`

## Phase 7: Settings UI

- [x] **Settings Feature** - Settings screen placeholder
- [x] Settings route and navigation wiring
- [ ] Implement theme switcher UI (light/dark/system) using themeModeProvider
- [ ] Language selector UI (if adding in-app selector) using localeProvider
- [ ] Settings persistence (already handled by providers)
- [ ] About section (app version, licenses)
- [ ] Commit and tag as `v0.8.0-settings`

## Phase 8: Platform Polish

- [ ] Android-specific: Permissions, notifications, adaptive icon
- [ ] iOS-specific: Permissions, notifications, app icon
- [ ] Windows-specific: File dialogs, window management
- [ ] macOS-specific: File dialogs, permissions
- [ ] Ubuntu-specific: File dialogs, permissions
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
