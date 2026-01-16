# Quick Fix: StoreKit Configuration Setup

## Problem
Getting `storekit_no_response` error and plans not showing.

## Solution: Enable StoreKit Configuration in Xcode

The StoreKit configuration file (`Products.storekit`) exists but needs to be enabled in Xcode scheme settings.

### Steps:

1. **Open Xcode**
   ```bash
   cd ios
   open Runner.xcworkspace
   ```

2. **Edit Scheme**
   - Click on the scheme selector (next to the Run/Stop buttons)
   - Select **"Edit Scheme..."**

3. **Configure StoreKit**
   - In the left sidebar, select **"Run"**
   - Click the **"Options"** tab
   - Under **"StoreKit Configuration"**, select **"Products.storekit"**
   - Click **"Close"**

4. **Run from Xcode**
   - **IMPORTANT**: Run the app directly from Xcode (click the Play button)
   - Do NOT use `flutter run` - it won't use the StoreKit configuration
   - The app will now use the local StoreKit config file for testing

### What This Does:

- Uses the local `Products.storekit` file instead of connecting to App Store Connect
- Allows testing in-app purchases without real products in App Store Connect
- Products will load immediately from the local configuration

### After Setup:

- Products should load successfully
- You can test purchases locally
- No need for products to be "Ready to Submit" in App Store Connect
- Works on both simulator and real devices when run from Xcode

### If Still Not Working:

1. **Verify the file exists**: Check that `ios/Products.storekit` exists
2. **Clean build**: In Xcode, Product → Clean Build Folder (Shift+Cmd+K)
3. **Rebuild**: Run again from Xcode
4. **Check console**: Look for "Successfully fetched X products" message

### For Production:

When ready for production, you'll need to:
- Configure products in App Store Connect
- Remove or deselect the StoreKit configuration
- Use real product IDs that match App Store Connect
