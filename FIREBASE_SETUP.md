# Firebase Setup Guide for Remote Config

This guide will help you set up Firebase Remote Config to manage your ad IDs dynamically.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or select an existing project
3. Enter your project name (e.g., "Spinner App")
4. Follow the setup wizard:
   - Enable/disable Google Analytics (optional)
   - Complete the project creation

## Step 2: Add Android App to Firebase

1. In Firebase Console, click the **Android icon** (or "Add app")
2. Enter your Android package name: `com.spinner.game`
   - You can find this in `android/app/build.gradle.kts` (applicationId)
3. Enter app nickname (optional): "Spinner Android"
4. Enter SHA-1 (optional for now, needed for some features)
5. Click **"Register app"**
6. **Download** `google-services.json` file
7. Place the file in: `android/app/google-services.json`

## Step 3: Add iOS App to Firebase

1. In Firebase Console, click the **iOS icon** (or "Add app")
2. Enter your iOS bundle ID: Check in Xcode or `ios/Runner.xcodeproj`
   - Usually looks like: `com.spinner.game` or similar
3. Enter app nickname (optional): "Spinner iOS"
4. Enter App Store ID (optional, can add later)
5. Click **"Register app"**
6. **Download** `GoogleService-Info.plist` file
7. Place the file in: `ios/Runner/GoogleService-Info.plist`

## Step 4: Configure Android Build Files

### Update `android/build.gradle.kts`:

Add the Google Services plugin at the top:

```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

### Update `android/app/build.gradle.kts`:

Add this at the bottom of the file:

```kotlin
plugins {
    // ... existing plugins
    id("com.google.gms.google-services")
}
```

## Step 5: Configure iOS (Xcode)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Right-click on `Runner` folder in the project navigator
3. Select **"Add Files to Runner"**
4. Navigate to and select `GoogleService-Info.plist`
5. Make sure **"Copy items if needed"** is checked
6. Click **"Add"**

## Step 6: Install Dependencies

Run these commands:

```bash
# Install Flutter packages
flutter pub get

# Install iOS pods
cd ios
pod install
cd ..
```

## Step 7: Set Up Remote Config Parameters

1. In Firebase Console, go to **Remote Config** (in the left sidebar)
2. Click **"Create configuration"** or **"Add parameter"**

### Add the following parameters:

#### Banner Ads:
- **Parameter key**: `android_banner_ad_id`
  - **Default value**: Your Android banner ad ID (or leave empty)
  - **Description**: Android Banner Ad Unit ID

- **Parameter key**: `ios_banner_ad_id`
  - **Default value**: Your iOS banner ad ID (or leave empty)
  - **Description**: iOS Banner Ad Unit ID

#### Interstitial Ads:
- **Parameter key**: `android_interstitial_ad_id`
  - **Default value**: Your Android interstitial ad ID (or leave empty)
  - **Description**: Android Interstitial Ad Unit ID

- **Parameter key**: `ios_interstitial_ad_id`
  - **Default value**: Your iOS interstitial ad ID (or leave empty)
  - **Description**: iOS Interstitial Ad Unit ID

#### Native Ads:
- **Parameter key**: `android_native_ad_id`
  - **Default value**: Your Android native ad ID (or leave empty)
  - **Description**: Android Native Ad Unit ID

- **Parameter key**: `ios_native_ad_id`
  - **Default value**: Your iOS native ad ID (or leave empty)
  - **Description**: iOS Native Ad Unit ID

#### Rewarded Ads:
- **Parameter key**: `android_rewarded_ad_id`
  - **Default value**: Your Android rewarded ad ID (or leave empty)
  - **Description**: Android Rewarded Ad Unit ID

- **Parameter key**: `ios_rewarded_ad_id`
  - **Default value**: Your iOS rewarded ad ID (or leave empty)
  - **Description**: iOS Rewarded Ad Unit ID

#### App Open Ads:
- **Parameter key**: `android_app_open_ad_id`
  - **Default value**: Your Android app open ad ID (or leave empty)
  - **Description**: Android App Open Ad Unit ID

- **Parameter key**: `ios_app_open_ad_id`
  - **Default value**: Your iOS app open ad ID (or leave empty)
  - **Description**: iOS App Open Ad Unit ID

### After adding all parameters:

1. Click **"Publish changes"** to activate the configuration
2. The app will fetch these values when it starts

## Step 8: Test the Setup

1. Build and run your app:
   ```bash
   flutter run
   ```

2. Check the debug console for:
   - `Firebase Remote Config initialized successfully`
   - Ad loading messages

3. If you see `ad ID is empty, skipping ad load` messages, that's normal if you haven't added ad IDs yet in Remote Config.

## Step 9: Update Ad IDs in Remote Config

1. Go back to Firebase Console → Remote Config
2. Click on any parameter to edit it
3. Enter your actual AdMob Ad Unit ID (format: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`)
4. Click **"Publish changes"**
5. The app will fetch the new values (may take up to 1 hour due to caching, or restart the app)

## Important Notes:

- **Empty values**: If you leave a parameter empty, that ad type won't be shown (no errors)
- **Caching**: Remote Config caches values for 1 hour by default. You can change this in `firebase_remote_config_service.dart`
- **Testing**: You can use test ad IDs from AdMob during development
- **Production**: Replace with your actual production ad IDs before releasing

## Troubleshooting:

### If Firebase initialization fails:
- Make sure `google-services.json` is in `android/app/`
- Make sure `GoogleService-Info.plist` is in `ios/Runner/`
- Run `flutter clean` and rebuild

### If Remote Config values aren't updating:
- Check that you clicked "Publish changes" in Firebase Console
- The app caches values for 1 hour (see `minimumFetchInterval` in `firebase_remote_config_service.dart`)
- Restart the app to force a fresh fetch

### If you get build errors:
- Make sure you added the Google Services plugin to `android/build.gradle.kts`
- Run `flutter pub get` and `cd ios && pod install`

## Quick Reference - Parameter Names:

```
android_banner_ad_id
ios_banner_ad_id
android_interstitial_ad_id
ios_interstitial_ad_id
android_native_ad_id
ios_native_ad_id
android_rewarded_ad_id
ios_rewarded_ad_id
android_app_open_ad_id
ios_app_open_ad_id
```
