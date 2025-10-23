# 🚨 URGENT: Firebase API Keys Exposed - Action Required

## Issue
Firebase API keys were committed in `b7d0e57` and pushed to GitHub.
Detected keys:
- `AIzaSyAsrpLZ0H-d0nInCyIiTJpvrcba8kUAgDM` (Android/iOS)
- `AIzaSyCk5-BdF-lDIiKv_x5E4o1geqe1kRUr8W0` (Windows)
- `AIzaSyDWcVqrqBj4Kso85OxS3d8j4LApkICjidA` (macOS)

## Immediate Actions Required

### 1. Restrict API Keys in Firebase Console (Do This NOW)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your `peerlink` project
3. Go to **APIs & Services** → **Credentials**
4. For each exposed API key:
   - Click the key
   - Under **Application restrictions**: Select **Android apps** or **iOS apps** or **Websites**
   - Under **API restrictions**: Select **Restrict key** and choose only:
     - Cloud Firestore API
     - Firebase Cloud Messaging API
   - Click **Save**

This will prevent abuse even though keys are public (Firebase API keys are meant to be public but restricted).

### 2. Clean Git History (Optional but Recommended)

#### Option A: Using BFG Repo-Cleaner (Easiest)
```bash
# Download BFG: https://rtyley.github.io/bfg-repo-cleaner/
# Or: choco install bfg-repo-cleaner

# Backup your repo first!
cd ..
git clone --mirror https://github.com/jhonny1994/peerlink.git peerlink-backup.git

cd peerlink
bfg --delete-files firebase_options.dart
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

#### Option B: Using git filter-branch
```bash
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch lib/firebase_options.dart" \
  --prune-empty --tag-name-filter cat -- --all

git push origin --force --all
git push origin --force --tags
```

#### Option C: Start Fresh (Nuclear Option)
If the repo is new and no one else has cloned:
```bash
# Delete remote repo on GitHub
# Create new repo
git remote set-url origin <new-repo-url>
git push -u origin master
```

### 3. Verify Protection
After restricting keys, verify:
- Keys only work from your registered app bundle IDs
- Keys only access Firestore and FCM APIs
- No billing API access (prevent abuse)

## Why This Is OK (But Still Needs Action)

Firebase API keys are **meant to be public** in client apps - they're not like secret keys. However:
- ✅ They should be **restricted** to your app and specific APIs
- ✅ They should be in `.gitignore` for cleanliness
- ❌ They shouldn't give billing access

Once you restrict the keys in Google Cloud Console, they can't be abused even if public.

## Prevention (Already Done)
- ✅ `firebase_options.dart` added to `.gitignore`
- ✅ Template file created (`firebase_options.dart.example`)
- ✅ Documentation updated

## References
- [Firebase Security Best Practices](https://firebase.google.com/docs/projects/api-keys)
- [Restricting API Keys](https://cloud.google.com/docs/authentication/api-keys#securing_an_api_key)
