# Android Keystore Setup Guide

## ⚠️ IMPORTANT SECURITY NOTICE

The Android keystore file (`key.keystore`) contains your app's signing key and should **NEVER** be committed to version control or shared publicly.

## Initial Setup

### 1. Generate a Keystore (First Time Only)

```bash
keytool -genkey -v -keystore key.keystore -alias psychport -keyalg RSA -keysize 2048 -validity 10000
```

When prompted, create a **strong password** (not "novaFlare"!) and store it securely.

### 2. Set Environment Variables

Before building the Android release, set these environment variables:

#### On Windows (PowerShell):
```powershell
$env:ANDROID_KEYSTORE_PASSWORD = "your-keystore-password"
$env:ANDROID_KEY_ALIAS = "psychport"
$env:ANDROID_KEY_PASSWORD = "your-key-password"
```

#### On Linux/Mac:
```bash
export ANDROID_KEYSTORE_PASSWORD="your-keystore-password"
export ANDROID_KEY_ALIAS="psychport"
export ANDROID_KEY_PASSWORD="your-key-password"
```

#### For CI/CD:
Store these as encrypted secrets in your CI/CD system:
- GitHub Actions: Repository Settings → Secrets
- GitLab CI: Settings → CI/CD → Variables
- Jenkins: Credentials Manager

### 3. Secure Storage

Store your keystore file in a secure location:
- **Local Development:** Outside the repository (e.g., `~/.android/keystores/`)
- **CI/CD:** Encrypted secrets or secure file storage
- **Backup:** Encrypted backup in a secure location (you cannot recover a lost keystore!)

### 4. Build Release APK

```bash
# Make sure environment variables are set first
lime build android -release
```

## Security Best Practices

1. ✅ **Never** commit the keystore to version control
2. ✅ Use a **strong, unique password** (20+ characters recommended)
3. ✅ **Back up** your keystore securely (encrypted)
4. ✅ Use **different keystores** for different apps
5. ✅ Store passwords in a **password manager**
6. ✅ Rotate keys periodically (when possible)
7. ✅ Limit access to the keystore (only necessary team members)

## What If I Lose My Keystore?

If you lose your keystore or password:
- ❌ You **cannot** update existing apps on Google Play Store
- ❌ You will need to publish as a new app
- ❌ Users will need to uninstall and reinstall
- ⚠️ This is why backups are critical!

## Debug vs Release Keystores

### Debug Keystore
- Used for development/testing
- Can use weak password or default Android debug keystore
- Can be in version control (separate file: `debug.keystore`)

### Release Keystore
- Used for production builds
- **MUST** use strong password
- **NEVER** in version control
- Same keystore required for all future updates

## For Open Source Projects

If this is an open-source project:
1. Provide a debug keystore in the repo for contributors
2. Keep the release keystore private (maintained by project owner)
3. Document the build process clearly
4. Use CI/CD to build releases securely

## Additional Resources

- [Android App Signing Documentation](https://developer.android.com/studio/publish/app-signing)
- [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)
