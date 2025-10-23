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

### 7. Session Cleanup (Free Tier Alternative)

**Note:** Firestore TTL is a paid feature. For free tier, use one of these alternatives:

#### Option A: Client-Side Cleanup (Recommended for Free Tier)
Sessions will be deleted by the sender after connection is established or after 15 minutes:
- No server-side cleanup needed
- Handled in app code (Phase 3)
- Free tier compatible

#### Option B: Manual Firestore Rules with Timestamp
Update security rules to prevent reading old sessions:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /sessions/{sessionId} {
      // Only allow reading sessions created in last 15 minutes
      allow read: if request.time < resource.data.expiresAt;
      allow write: if true;
    }
  }
}
```

Sessions older than 15 minutes won't be readable, but will accumulate in Firestore.
Periodically clean up manually or upgrade to paid tier for automatic TTL.

#### Option C: Scheduled Cloud Function (Requires Blaze Plan)
If you upgrade to Blaze (pay-as-you-go, still free under quota):
```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.cleanupSessions = functions.pubsub
  .schedule('every 15 minutes')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const snapshot = await admin.firestore()
      .collection('sessions')
      .where('expiresAt', '<', now)
      .get();
    
    const batch = admin.firestore().batch();
    snapshot.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
    
    console.log(`Deleted ${snapshot.size} expired sessions`);
  });
```

**Recommendation:** Start with Option A (client-side cleanup) on free tier.

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
