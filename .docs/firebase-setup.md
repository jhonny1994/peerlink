# Firebase Setup Instructions

## Prerequisites
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login to Firebase: `firebase login`

## Setup Steps

### 1. Create Firebase Project
- Go to [Firebase Console](https://console.firebase.google.com/)
- Create new project: `peerlink` or `peerlink-carbodex`
- Disable Google Analytics (not needed for P2P file transfer)

### 2. Enable Firestore
- In Firebase Console, go to **Firestore Database**
- Click **Create database**
- Start in **production mode**
- Choose closest region (e.g., `us-central` or `europe-west`)

### 3. Enable Firebase Cloud Messaging (FCM)
- In Firebase Console, go to **Cloud Messaging**
- Enable if not already enabled

### 4. Configure FlutterFire CLI
Run in project root:
```bash
dart pub global run flutterfire_cli:flutterfire configure --project=peerlink
```

This will:
- Generate `lib/firebase_options.dart` with platform-specific configs
- Update Android/iOS/Web/Desktop configurations
- Register all platforms in Firebase Console

### 5. Select Platforms
When prompted, select:
- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux

### 6. Firestore Security Rules
After setup, update Firestore rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Session documents for signaling
    match /sessions/{sessionId} {
      // Anyone can read/write sessions (no auth required for P2P)
      allow read, write: if true;
      
      // Sessions expire after 15 minutes (handled by TTL)
    }
  }
}
```

### 7. Firestore TTL (Time To Live)
Set up automatic deletion in Firestore Console:
- Go to **Firestore Database** → **Indexes** → **TTL**
- Create TTL policy for `sessions` collection
- Field: `expiresAt`
- TTL: 15 minutes

### 8. Verify Installation
Run the app to test Firebase initialization:
```bash
flutter run -d windows
```

## Environment Variables
No Firebase credentials needed in `.env` - all handled by `firebase_options.dart`

## Notes
- Free Spark plan is sufficient (no billing required)
- Firestore: 50K reads/day, 20K writes/day (more than enough)
- FCM: Unlimited notifications
- No cloud storage used (P2P direct transfer only)
