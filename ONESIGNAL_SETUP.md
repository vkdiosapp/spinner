# OneSignal Push Notification Setup Guide

## Quick Setup Steps

### 1. Install Dependencies
Run the following command to install the OneSignal Flutter package:
```bash
flutter pub get
```

### 2. Configure OneSignal App ID

1. Go to [OneSignal Dashboard](https://app.onesignal.com/apps)
2. Create a new app or select your existing app
3. Go to **Settings** → **Keys & IDs**
4. Copy your **OneSignal App ID**

5. Open `lib/onesignal_config.dart` and replace `YOUR_ONESIGNAL_APP_ID` with your actual App ID:
```dart
static const String appId = 'your-actual-app-id-here';
```

### 3. iOS Setup (Required for iOS)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Go to **Signing & Capabilities**
3. Enable **Push Notifications** capability
4. Run `pod install` in the `ios` directory:
```bash
cd ios
pod install
cd ..
```

### 4. Android Setup (Already Configured)

The Android configuration is already complete. The app will automatically request notification permissions when first launched.

### 5. Test Notifications

1. Build and run your app on a device (not simulator for push notifications)
2. Send a test notification from OneSignal Dashboard:
   - Go to **Messages** → **New Push**
   - Enter your message
   - Click **Send to Test Device** or select your app

## Files Created/Modified

### New Files:
- `lib/onesignal_config.dart` - Configuration file (replace App ID here)
- `lib/onesignal_service.dart` - OneSignal service handler

### Modified Files:
- `lib/main.dart` - Initializes OneSignal on app start
- `pubspec.yaml` - Added `onesignal_flutter: ^5.0.0` dependency
- `android/app/src/main/AndroidManifest.xml` - Added notification permissions
- `ios/Runner/Info.plist` - Added background modes for notifications

## How It Works

1. **On App Launch**: OneSignal initializes automatically and requests notification permissions
2. **Notification Received**: When a notification arrives:
   - If app is in foreground: Notification is displayed (if enabled in config)
   - If app is in background: Standard notification appears
   - If app is closed: Notification appears in notification tray
3. **Notification Clicked**: The `_handleNotificationClick` method in `onesignal_service.dart` handles the click event

## Customization

### Enable/Disable In-App Notifications
Edit `lib/onesignal_config.dart`:
```dart
static const bool enableInAppNotifications = true; // or false
```

### Handle Notification Clicks
Edit `_handleNotificationClick` method in `lib/onesignal_service.dart` to navigate to specific pages based on notification data.

### Add User Tags
Use the service methods to tag users for targeted notifications:
```dart
await OneSignalService.setUserTag('user_type', 'premium');
await OneSignalService.sendTags({'level': '5', 'score': '1000'});
```

## Troubleshooting

### Notifications not working on iOS?
- Make sure Push Notifications capability is enabled in Xcode
- Check that you've run `pod install`
- Verify your App ID is correct in `onesignal_config.dart`
- Ensure you're testing on a real device (not simulator)

### Notifications not working on Android?
- Check that notification permissions are granted (Android 13+)
- Verify your App ID is correct in `onesignal_config.dart`
- Check device notification settings

### Need Help?
- [OneSignal Flutter Documentation](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [OneSignal Dashboard](https://app.onesignal.com)

