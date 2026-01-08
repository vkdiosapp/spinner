# How to Share iOS Build

## Method 1: Create IPA File for Ad Hoc Distribution (Recommended for Testing)

### Step 1: Open Xcode
```bash
open ios/Runner.xcworkspace
```

### Step 2: Create Archive
1. In Xcode, select **Product** → **Archive**
2. Wait for the archive to complete
3. The Organizer window will open automatically

### Step 3: Export IPA
1. In the Organizer, select your archive
2. Click **Distribute App**
3. Choose **Ad Hoc** (for testing on registered devices)
4. Select your development team
5. Choose **Automatically manage signing**
6. Click **Export**
7. Choose a location to save the IPA file

### Step 4: Share the IPA
- The IPA file will be saved in the chosen location
- You can share this file via:
  - AirDrop
  - Email
  - Cloud storage (iCloud, Dropbox, Google Drive)
  - TestFlight (see Method 2)

---

## Method 2: Upload to TestFlight (Recommended for Beta Testing)

### Step 1: Create Archive (Same as Method 1, Step 1-2)

### Step 2: Upload to App Store Connect
1. In Organizer, select your archive
2. Click **Distribute App**
3. Choose **App Store Connect**
4. Click **Upload**
5. Select your development team
6. Choose **Automatically manage signing**
7. Click **Upload**
8. Wait for processing (can take 10-30 minutes)

### Step 3: Add to TestFlight
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to your app
3. Go to **TestFlight** tab
4. Add testers (Internal or External)
5. Share the TestFlight link with testers

---

## Method 3: Using Command Line (Quick Method)

### Create IPA directly:
```bash
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath build/Runner.xcarchive \
  archive

xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/ipa
```

### Create ExportOptions.plist:
Create a file `ios/ExportOptions.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string>R6ZQ9273AZ</string>
</dict>
</plist>
```

---

## Current App Information:
- **Bundle ID**: `com.vkd.spinner.game`
- **App Name**: PickSpiN
- **Version**: 1.0.0 (Build 1)
- **Team ID**: R6ZQ9273AZ

---

## Notes:
- For Ad Hoc distribution, devices must be registered in your Apple Developer account
- TestFlight allows up to 10,000 external testers
- IPA files can only be installed on registered devices (Ad Hoc) or via TestFlight
- Make sure you have valid provisioning profiles set up


