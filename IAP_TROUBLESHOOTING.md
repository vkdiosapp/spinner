# In-App Purchase Troubleshooting Guide

## Error: "storekit_no_response" or "Failed to get response from platform"

This error means StoreKit cannot connect to the App Store. Here's how to fix it:

## ✅ Quick Fixes

### 1. **Test on Real Device (Most Common Issue)**
- ❌ **iOS Simulator does NOT support in-app purchases**
- ✅ **You MUST test on a real iPhone/iPad**
- Build and run on a physical device

### 2. **Check Product IDs Match Exactly**
Verify your product IDs in App Store Connect match the code:
- Code expects: `monthly_purchase`, `yearly_purchase`, `lifetime_purchase`
- App Store Connect must have EXACTLY these IDs (case-sensitive)

### 3. **Product Status in App Store Connect**
Products must be in "Ready to Submit" or "Approved" status:
- Go to App Store Connect → Your App → Features
- Check Subscriptions (for monthly/yearly)
- Check In-App Purchases (for lifetime)
- Status should be "Ready to Submit" or "Approved"

### 4. **Sign Out of Real Apple ID**
- Go to Settings → [Your Name] → Sign Out
- When testing, you'll be prompted to sign in with sandbox account
- Sandbox accounts are free test accounts

### 5. **Create Sandbox Test Account**
- App Store Connect → Users and Access → Sandbox Testers
- Create a test account (email can be fake)
- Use this account when testing purchases

## Step-by-Step Debugging

### Step 1: Verify Product IDs
```dart
// In subscription_service.dart, these IDs must match App Store Connect:
static const String monthlyProductId = 'monthly_purchase';
static const String yearlyProductId = 'yearly_purchase';
static const String lifetimeProductId = 'lifetime_purchase';
```

### Step 2: Check App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app
3. Go to Features → Subscriptions
4. Verify subscription group exists
5. Verify both `monthly_purchase` and `yearly_purchase` exist
6. Go to Features → In-App Purchases
7. Verify `lifetime_purchase` exists
8. Check all have status "Ready to Submit" or "Approved"

### Step 3: Test on Real Device
1. Connect your iPhone/iPad via USB
2. In Xcode/Flutter, select your device (not simulator)
3. Build and run the app
4. Open subscription popup
5. Products should load

### Step 4: Check Console Logs
Look for these messages:
```
flutter: Fetching products: {monthly_purchase, yearly_purchase, lifetime_purchase}
flutter: Successfully fetched X products
```

If you see errors, check:
- Product IDs match
- Products are approved
- Testing on real device

## Common Issues & Solutions

### Issue: "No products returned"
**Solution:**
- Verify product IDs match exactly
- Check products are "Ready to Submit" in App Store Connect
- Wait a few minutes after creating products (they need to propagate)

### Issue: "storekit_no_response"
**Solution:**
- ✅ Test on real device (not simulator)
- ✅ Sign out of real Apple ID
- ✅ Check internet connection
- ✅ Verify products exist in App Store Connect

### Issue: Products load but purchase fails
**Solution:**
- Use sandbox test account
- Verify sandbox account is created
- Check device has internet connection

### Issue: "Product not found"
**Solution:**
- Product IDs must match exactly (case-sensitive)
- Products must be in "Ready to Submit" status
- Wait for products to propagate (can take a few minutes)

## Testing Checklist

Before testing in-app purchases:

- [ ] Products created in App Store Connect
- [ ] Product IDs match exactly: `monthly_purchase`, `yearly_purchase`, `lifetime_purchase`
- [ ] All products show "Ready to Submit" or "Approved"
- [ ] Testing on **real device** (not simulator)
- [ ] Signed out of real Apple ID on device
- [ ] Sandbox test account created
- [ ] Internet connection available
- [ ] App built with correct bundle ID

## Debug Information

The app now provides detailed error messages:
- Check console logs for specific error codes
- Error messages show what to check
- Retry button available in subscription popup

## Still Not Working?

1. **Double-check Product IDs**: They must match EXACTLY
2. **Wait**: Products can take 5-10 minutes to propagate after creation
3. **Restart Device**: Sometimes helps with StoreKit connection
4. **Check App Store Connect**: Ensure products are not in "Missing Metadata" status
5. **Verify Bundle ID**: Must match your app's bundle ID in App Store Connect

## Production vs Sandbox

- **Sandbox**: For testing, uses test accounts
- **Production**: For App Store releases
- Products work the same in both, but sandbox is free for testing

## Need More Help?

Check the console logs - they now provide detailed information about:
- Which products are being requested
- What error occurred
- What to check

The subscription popup also shows helpful error messages with retry option.
