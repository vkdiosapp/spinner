# Fix AdMob MissingPluginException on iOS

## The Problem
The error `MissingPluginException(No implementation found for method loadBannerAd)` means the native iOS plugin isn't registered. This happens when:
1. CocoaPods dependencies aren't installed
2. The app needs a full rebuild (not hot reload)

## Solution Steps

### Step 1: Install CocoaPods Dependencies
Open Terminal and run:
```bash
cd ios
pod install
cd ..
```

### Step 2: Clean and Rebuild
**IMPORTANT**: You MUST do a full rebuild, not just hot reload:

1. **Stop the app completely** (not just pause)
2. **Clean the build**:
   ```bash
   flutter clean
   ```
3. **Get dependencies**:
   ```bash
   flutter pub get
   ```
4. **Rebuild and run**:
   ```bash
   flutter run
   ```

### Step 3: Verify Info.plist
I've already added the test AdMob App ID to `ios/Runner/Info.plist`:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```

## Why This Happens
- Hot reload doesn't update native iOS code
- CocoaPods needs to install the native AdMob SDK
- The plugin registration happens at build time, not runtime

## After Fixing
Once you've done the full rebuild, the banner ads should appear at the bottom of all spinner pages when the ads toggle is ON.

## If Still Not Working
1. Make sure you're testing on a **real device** or **simulator** (not just hot reload)
2. Check that ads toggle is ON in the home page
3. Verify the app has internet connection
4. Check Xcode console for any additional errors

