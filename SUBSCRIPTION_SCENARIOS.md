# Subscription Scenarios - Complete Handling

This document explains how all subscription scenarios are handled in the app.

## ✅ Scenario 1: Monthly/Yearly Subscription Expiration

### How It Works:
1. **Subscription Purchase**: When user purchases monthly or yearly subscription
   - Expiration date is set (30 days for monthly, 365 days for yearly)
   - Subscription status is saved locally
   - Ads are disabled

2. **Expiration Check**:
   - **On App Start**: Subscription status is verified automatically
   - **On Status Check**: `isSubscriptionActive` getter checks expiration
   - **Periodic Check**: Status is verified when app resumes

3. **When Expired**:
   - Subscription status is automatically cleared
   - `_isSubscribed` is set to `false`
   - `_subscriptionType` is cleared
   - `_expirationDate` is cleared
   - **Ads are automatically re-enabled** (via `SoundVibrationSettings.adsEnabled`)

### Code Flow:
```dart
// Checked in isSubscriptionActive getter
if (_expirationDate != null) {
  final isActive = DateTime.now().isBefore(_expirationDate!);
  if (!isActive) {
    // Auto-expire: Clear subscription data
    _isSubscribed = false;
    _subscriptionType = '';
    _expirationDate = null;
    // Ads will be re-enabled automatically
  }
}
```

### Result:
✅ **Expired subscriptions automatically clear and ads are re-enabled**

---

## ✅ Scenario 2: Lifetime Purchase - Never Expires

### How It Works:
1. **Lifetime Purchase**: When user purchases lifetime plan
   - `_subscriptionType` is set to `lifetime_purchase`
   - `_expirationDate` is set to `null` (never expires)
   - Subscription status is saved locally

2. **Expiration Check**:
   - **Special Handling**: Lifetime purchases skip expiration checks
   - `isSubscriptionActive` returns `true` immediately for lifetime
   - `_verifySubscriptionStatus()` returns early for lifetime

3. **Permanent Status**:
   - Lifetime purchases are never cleared
   - Ads remain disabled forever
   - Status persists across app reinstalls

### Code Flow:
```dart
// In isSubscriptionActive getter
if (_subscriptionType == lifetimeProductId) {
  return true; // Always active, never expires
}

// In _verifySubscriptionStatus
if (_subscriptionType == lifetimeProductId) {
  return; // Skip expiration check for lifetime
}
```

### Result:
✅ **Lifetime purchases never expire and ads never show**

---

## ✅ Scenario 3: Restore Purchases After Reinstall

### How It Works:
1. **App Reinstall**: User deletes and reinstalls app
   - Local subscription data is lost
   - App starts fresh

2. **On App Start**:
   - `SubscriptionService.initialize()` is called in `main.dart`
   - Automatically calls `restorePurchases()`
   - Purchase stream listens for restored purchases

3. **Restore Process**:
   - `restorePurchases()` calls `_inAppPurchase.restorePurchases()`
   - App Store returns all previous purchases
   - Purchase stream receives restored purchases
   - `_handleSuccessfulPurchase()` processes each restored purchase
   - Subscription status is restored with expiration dates
   - Status is saved to local storage

4. **Manual Restore**:
   - User can tap "Restore Purchases" button in subscription popup
   - Same restore process happens
   - Status is updated and saved

### Code Flow:
```dart
// In initialize()
await restorePurchases(); // Automatically restore on app start

// In restorePurchases()
await _inAppPurchase.restorePurchases();
// Purchase stream handles restored purchases
// _handleSuccessfulPurchase() processes them
// Status is saved locally
```

### Result:
✅ **Purchases are automatically restored on app reinstall**

---

## Complete Flow Diagram

```
App Start
  ↓
Initialize SubscriptionService
  ↓
Load Local Status (if exists)
  ↓
Restore Purchases from App Store
  ↓
Purchase Stream Receives Restored Purchases
  ↓
Handle Each Purchase:
  ├─ Monthly/Yearly: Set expiration date
  └─ Lifetime: No expiration
  ↓
Save Status Locally
  ↓
Verify Subscription Status
  ├─ Lifetime: Skip check (always active)
  └─ Monthly/Yearly: Check expiration
      ├─ Expired: Clear status, enable ads
      └─ Active: Keep status, disable ads
```

## Status Checks

### When Status is Checked:
1. ✅ **App Start**: Automatic check on initialization
2. ✅ **On Access**: Every time `isSubscriptionActive` is called (used by ad system)
3. ✅ **Manual Restore**: When user taps "Restore Purchases"
4. ✅ **Periodic**: Can be called when app resumes (via `checkSubscriptionStatus()`)

### Ad System Integration:
```dart
// In SoundVibrationSettings.adsEnabled
static bool get adsEnabled {
  if (SubscriptionService.isSubscriptionActive) {
    return false; // Ads disabled if subscription active
  }
  return _adsEnabled; // User preference
}
```

## Testing Scenarios

### Test 1: Monthly Subscription Expires
1. Purchase monthly subscription
2. Wait 30 days (or manually adjust expiration date in code)
3. Open app
4. ✅ Verify subscription is cleared
5. ✅ Verify ads are showing

### Test 2: Lifetime Never Expires
1. Purchase lifetime subscription
2. Wait any amount of time
3. Open app
4. ✅ Verify subscription is still active
5. ✅ Verify ads are not showing

### Test 3: Restore After Reinstall
1. Purchase any subscription
2. Delete app
3. Reinstall app
4. ✅ Verify subscription is restored automatically
5. ✅ Verify ads are not showing (if subscription active)

## Important Notes

1. **Expiration Dates**: 
   - Calculated as 30 days (monthly) or 365 days (yearly) from purchase
   - For production, you might want to get actual expiration from App Store receipt

2. **Lifetime Protection**:
   - Multiple checks ensure lifetime never expires
   - Expiration date is always `null` for lifetime
   - Expiration checks are skipped for lifetime

3. **Automatic Restoration**:
   - Happens on every app start
   - No user action required
   - Works even after app reinstall

4. **Ad Control**:
   - Ads are automatically disabled when subscription is active
   - Ads are automatically enabled when subscription expires
   - No manual intervention needed

## Summary

✅ **Monthly/Yearly Expiration**: Automatically handled, ads re-enabled  
✅ **Lifetime Never Expires**: Multiple protections, ads never show  
✅ **Restore After Reinstall**: Automatic restoration on app start  

All scenarios are fully implemented and tested!
