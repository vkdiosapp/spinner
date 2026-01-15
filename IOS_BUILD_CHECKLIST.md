# iOS Build Sharing Checklist

## ✅ Configuration Status

### 1. App Identity & Signing
- ✅ **Bundle ID**: `com.vkd.spinner.game` (consistent across all configs)
- ✅ **App Name**: PickSpiN (display name set correctly)
- ✅ **Team ID**: R6ZQ9273AZ (configured in Xcode project)
- ✅ **Code Signing**: Automatic signing enabled
- ✅ **Entitlements**: Push notifications configured (aps-environment: production)

### 2. Version Information
- ⚠️ **Version Mismatch Detected**:
  - `pubspec.yaml`: `1.0.0+1` (version 1.0.0, build 1)
  - `Xcode project`: Marketing Version 1.0.0, Build 7
  - **Note**: Flutter will use pubspec.yaml values during build, but Xcode shows build 7
  - **Recommendation**: Ensure consistency or let Flutter override during build

### 3. Export Configuration
- ✅ **ExportOptions.plist**: Configured for App Store distribution
  - Method: `app-store` (correct for TestFlight/App Store)
  - Team ID: R6ZQ9273AZ
  - Automatic signing enabled
  - Bitcode disabled (correct for modern builds)
  - Symbols upload enabled

### 4. Required Permissions & Info.plist
- ✅ **Location Permission**: `NSLocationWhenInUseUsageDescription` present
- ✅ **Background Modes**: Remote notifications enabled
- ✅ **AdMob**: Test App ID configured (`ca-app-pub-3940256099942544~1458002511`)
  - ⚠️ **IMPORTANT**: This is a TEST AdMob ID. Replace with production ID before App Store submission
- ✅ **Encryption**: `ITSAppUsesNonExemptEncryption` set to `false` (correct for most apps)

### 5. Build Settings
- ✅ **iOS Deployment Target**: 13.0 (configured in Podfile)
- ✅ **Bitcode**: Disabled (required for modern Flutter apps)
- ✅ **Swift Version**: 5.0
- ✅ **App Icons**: Present in Assets.xcassets

### 6. Dependencies
- ✅ **CocoaPods**: Podfile configured correctly
- ✅ **Flutter Plugins**: All dependencies in pubspec.yaml
  - share_plus, screenshot, path_provider
  - audioplayers, vibration
  - onesignal_flutter (push notifications)
  - google_mobile_ads (AdMob)
  - confetti, shared_preferences

### 7. Push Notifications (OneSignal)
- ✅ **OneSignal App ID**: Configured (`057453e0-68da-4c0f-8923-4b3fc065d73f`)
- ✅ **Push Notifications Capability**: Enabled in entitlements (aps-environment: production)
- ✅ **Background Modes**: Remote notifications enabled in Info.plist
- ✅ **OneSignal Dependencies**: Installed via CocoaPods
- ⚠️ **OneSignal Logging**: Currently enabled (`enableLogging = true`)
  - **Recommendation**: Set to `false` for production builds to reduce log noise

## ⚠️ Pre-Build Actions Required

### Before Creating Archive:

1. **Update AdMob App ID** (if sharing for production):
   ```xml
   <!-- In ios/Runner/Info.plist -->
   <key>GADApplicationIdentifier</key>
   <string>YOUR_PRODUCTION_ADMOB_APP_ID</string>
   ```
   Currently using test ID: `ca-app-pub-3940256099942544~1458002511`

2. **Verify Version Numbers**:
   - Ensure `pubspec.yaml` version matches your intended release
   - Current: `1.0.0+1`
   - Flutter will use this during build

3. **Disable OneSignal Logging** (for production):
   ```dart
   // In lib/onesignal_config.dart
   static const bool enableLogging = false; // Change from true to false
   ```

4. **Clean Build** (recommended):
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   cd ..
   ```

5. **Verify Signing**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Go to Runner target → Signing & Capabilities
   - Ensure "Automatically manage signing" is checked
   - Verify Team is set to your team (R6ZQ9273AZ)

## 📋 Build & Share Steps

### Option 1: TestFlight (Recommended for Beta Testing)

1. **Create Archive in Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```
   - Product → Archive
   - Wait for archive to complete

2. **Distribute to App Store Connect**:
   - In Organizer, select archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Select "Upload"
   - Follow prompts (automatic signing recommended)

3. **Process in App Store Connect**:
   - Wait 10-30 minutes for processing
   - Go to App Store Connect → TestFlight
   - Add internal/external testers
   - Share TestFlight link

### Option 2: Ad Hoc Distribution (For Testing on Registered Devices)

1. **Update ExportOptions.plist**:
   Change method from `app-store` to `ad-hoc`:
   ```xml
   <key>method</key>
   <string>ad-hoc</string>
   ```

2. **Create Archive** (same as above)

3. **Export IPA**:
   - In Organizer → Distribute App
   - Choose "Ad Hoc"
   - Export to location
   - Share IPA file (devices must be registered in Apple Developer account)

## ✅ Final Verification

Before sharing, verify:
- [ ] App builds without errors
- [ ] All features work correctly
- [ ] AdMob ID updated (if production) - currently using test ID
- [ ] OneSignal logging disabled (set to false) - currently enabled
- [ ] Version number is correct (1.0.0+1)
- [ ] Signing certificates are valid
- [ ] Push notifications configured (OneSignal App ID verified)
- [ ] App icons display correctly
- [ ] No console errors during build
- [ ] Tested on real device (push notifications require real device)

## 🚨 Common Issues & Solutions

### Issue: "No signing certificate found"
**Solution**: 
- Ensure you're logged into Xcode with your Apple Developer account
- Check Team ID is correct in project settings

### Issue: "MissingPluginException" for AdMob
**Solution**: 
- Run `cd ios && pod install`
- Do a full rebuild (not hot reload)
- See `FIX_ADMOB_IOS.md` for details

### Issue: Archive fails
**Solution**:
- Clean build folder: Product → Clean Build Folder (Shift+Cmd+K)
- Delete DerivedData
- Run `flutter clean` and rebuild

### Issue: Upload to App Store Connect fails
**Solution**:
- Verify ExportOptions.plist method is `app-store`
- Check internet connection
- Ensure App Store Connect app record exists
- Verify bundle ID matches App Store Connect

## 📝 Notes

- **TestFlight**: Best for beta testing, supports up to 10,000 external testers
- **Ad Hoc**: Limited to 100 registered devices per year
- **App Store**: Final distribution method after testing
- Current ExportOptions.plist is configured for App Store/TestFlight distribution
- For Ad Hoc, you'll need to change the method in ExportOptions.plist

---

**Last Checked**: Configuration verified for iOS build sharing
**Status**: ✅ Ready for build (with AdMob ID update if needed)
