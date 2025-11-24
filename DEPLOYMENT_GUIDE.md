# Deployment Guide: Android Release & GitHub Actions

This guide explains how to set up the signing keys and GitHub Secrets required for the automated CI/CD pipeline to build your Android App Bundle (AAB) for the Play Store.

## 1. Generate an Upload Keystore
If you haven't already generated a keystore for signing your app, run the following command in your terminal:

**Windows (PowerShell):**
```powershell
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Mac/Linux:**
```bash
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

*   **Keep this file safe!** If you lose it, you won't be able to update your app on the Play Store.
*   Remember the **password** and **alias** you used.

## 2. Base64 Encode the Keystore
GitHub Secrets cannot store binary files, so we need to convert the keystore to a Base64 string.

**Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Out-File keystore_base64.txt
```

**Mac/Linux:**
```bash
base64 -i upload-keystore.jks > keystore_base64.txt
```

Open `keystore_base64.txt` and copy the entire long string.

## 3. Add Secrets to GitHub
Go to your GitHub repository -> **Settings** -> **Secrets and variables** -> **Actions** -> **New repository secret**.

Add the following 4 secrets:

| Name | Value |
| :--- | :--- |
| `KEYSTORE_BASE64` | The long Base64 string you copied from step 2. |
| `KEYSTORE_PASSWORD` | The password you set for the keystore store. |
| `KEY_PASSWORD` | The password you set for the key (usually the same as store). |
| `KEY_ALIAS` | The alias you used (default is `upload`). |

## 4. Trigger a Build
Once these secrets are set:
1.  Push a commit to the `main` branch.
2.  Go to the **Actions** tab in your GitHub repository.
3.  You will see the **PeerLink CI/CD** workflow running.
4.  Once finished, click on the workflow run, and under **Artifacts**, you can download `app-release-bundle`.

## 5. Upload to Play Console
1.  Take the downloaded `app-release.aab`.
2.  Go to the **Google Play Console**.
3.  Create a new release (Internal, Closed, or Production) and upload the AAB file.
