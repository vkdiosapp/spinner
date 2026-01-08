# OneSignal Setup Steps - Quick Guide

## Step 1: OneSignal Dashboard Setup

### 1.1 Create/Select Your App
1. Go to **https://app.onesignal.com/apps**
2. Click **"New App/Website"** (if creating new) or select existing app
3. Enter app name: **"PickSpiN"** (or your preferred name)
4. Select platform: **"Apple iOS (APNs)"** and **"Google Android (FCM)"**

### 1.2 Get Your App ID
1. After creating the app, go to **Settings** → **Keys & IDs**
2. Copy your **OneSignal App ID** (looks like: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)
3. Open `lib/onesignal_config.dart` in your project
4. Replace `YOUR_ONESIGNAL_APP_ID` with your actual App ID:
   ```dart
   static const String appId = 'your-actual-app-id-here';
   ```

### 1.3 Configure iOS Platform (APNs)
1. In OneSignal Dashboard, go to **Settings** → **Platforms** → **Apple iOS (APNs)**
2. You have two options:

   **Option A: Automatic Setup (Recommended)**
   - Click **"Configure"** or **"Upload Your .p8 Key"**
   - Follow the instructions to upload your APNs Auth Key (.p8 file)
   - Or use automatic setup if available

   **Option B: Manual Setup**
   - You'll need to upload your APNs certificate or .p8 key
   - Get this from Apple Developer Portal

### 1.4 Configure Android Platform (FCM)
1. In OneSignal Dashboard, go to **Settings** → **Platforms** → **Google Android (FCM)**
2. Click **"Configure"**
3. Upload your **Firebase Server Key** (from Firebase Console)
   - If you don't have Firebase setup, OneSignal can guide you through it

## Step 2: iOS Setup in Xcode

### 2.1 Open Project in Xcode
```bash
cd ios
open Runner.xcworkspace
```

### 2.2 Enable Push Notifications Capability
1. In Xcode, select **Runner** project in the left sidebar
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Click **"+ Capability"** button
5. Search for and add **"Push Notifications"**
6. This will automatically add the Push Notifications capability

### 2.3 Configure Signing
1. Still in **Signing & Capabilities** tab
2. Under **Signing**, select your **Team** (your Apple Developer account)
3. Make sure **"Automatically manage signing"** is checked
4. Xcode will automatically configure certificates

### 2.4 Install CocoaPods Dependencies
```bash
cd ios
pod install
cd ..
```

## Step 3: Test Your Setup

### 3.1 Build and Run
1. Make sure you've updated the App ID in `lib/onesignal_config.dart`
2. Run the app on a **real iOS device** (push notifications don't work on simulator):
   ```bash
   flutter run
   ```
   Or build and run from Xcode

### 3.2 Grant Permissions
- When the app launches, it will ask for notification permissions
- Tap **"Allow"** to enable notifications

### 3.3 Send Test Notification
1. Go to OneSignal Dashboard → **Messages** → **New Push**
2. Enter a test message: **"Hello from OneSignal!"**
3. Under **Send To**, select:
   - **"Send to Test Device"** (if you've added your device)
   - OR **"Send to All Subscribed Users"**
4. Click **"Send Message"**
5. You should receive the notification on your device!

## Step 4: Verify Setup

### Check Device Registration
1. In OneSignal Dashboard, go to **Audience** → **All Users**
2. You should see your device listed there
3. If you see your device, setup is successful!

## Troubleshooting

### Notifications not working?
1. **Check App ID**: Make sure it's correct in `onesignal_config.dart`
2. **Check Permissions**: Go to iOS Settings → PickSpiN → Notifications → Make sure enabled
3. **Check Xcode**: Make sure Push Notifications capability is added
4. **Check Device**: Must be a real device, not simulator
5. **Check OneSignal Dashboard**: Make sure iOS platform is configured with APNs key

### iOS Build Errors?
1. Run `pod install` in the `ios` directory
2. Clean build: `flutter clean && flutter pub get`
3. In Xcode: Product → Clean Build Folder

### Need APNs Key?
1. Go to Apple Developer Portal → Certificates, Identifiers & Profiles
2. Go to Keys → Create a new key
3. Enable "Apple Push Notifications service (APNs)"
4. Download the .p8 key file
5. Upload it to OneSignal Dashboard

## Quick Checklist

- [ ] Created app in OneSignal Dashboard
- [ ] Copied App ID to `lib/onesignal_config.dart`
- [ ] Configured iOS platform in OneSignal (APNs key)
- [ ] Configured Android platform in OneSignal (FCM key)
- [ ] Opened project in Xcode
- [ ] Added Push Notifications capability in Xcode
- [ ] Ran `pod install`
- [ ] Built and ran app on real device
- [ ] Granted notification permissions
- [ ] Sent test notification from OneSignal Dashboard
- [ ] Received notification successfully!

## Next Steps

Once setup is complete, you can:
- Send notifications to all users from OneSignal Dashboard
- Use tags to send targeted notifications
- Schedule notifications
- Track notification delivery and opens
- Use OneSignal API to send programmatic notifications

