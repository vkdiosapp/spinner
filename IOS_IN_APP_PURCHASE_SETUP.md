# iOS In-App Purchase Setup Guide

This guide will walk you through setting up in-app purchases in App Store Connect for your iOS app.

## Product IDs Used in the App

The app uses the following product IDs (defined in `lib/subscription_service.dart`):
- `monthly_subscription` - Monthly subscription
- `yearly_subscription` - Yearly subscription  
- `lifetime_purchase` - One-time lifetime purchase

## Step-by-Step Setup in App Store Connect

### ⚠️ Important: Two Different Sections!

- **Subscriptions** (Monthly & Yearly): Go to **Features → Subscriptions**
  - This is where you create Auto-Renewable Subscriptions
  - You'll create a "Subscription Group" first, then add subscriptions to it
  
- **In-App Purchases** (Lifetime): Go to **Features → In-App Purchases**
  - This is where you create Non-Consumable purchases (one-time)
  - Select "Non-Consumable" as the type

### 1. Access App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Sign in with your Apple Developer account
3. Select your app from the "My Apps" section

### 2. Create Subscriptions (Monthly & Yearly)

**Important**: Auto-Renewable Subscriptions are created in a **different section** than regular in-app purchases!

1. In your app's page, click on **"Features"** in the left sidebar
2. Click on **"Subscriptions"** (NOT "In-App Purchases")
3. Click the **"+"** button to create a new subscription group
4. **Create Subscription Group**:
   - Enter a name: "Premium Subscriptions" (or your preferred name)
   - Click **"Create"**

5. **Inside the subscription group**, click **"+"** to add a subscription

#### Create Monthly Subscription:

1. **Reference Name**: Enter "Monthly Subscription" (for your reference)
2. **Product ID**: Enter `monthly_subscription` (must match exactly)
3. **Subscription Duration**: Select "1 Month"
4. **Price**: Set your desired monthly price
5. **Localization**:
   - Click "Add Localization"
   - Select your primary language (e.g., English)
   - **Display Name**: "Monthly Subscription" (shown to users)
   - **Description**: "Remove all ads for one month. Auto-renews unless cancelled."
6. Click **"Create"**

#### Create Yearly Subscription:

1. **In the same subscription group**, click **"+"** again
2. **Reference Name**: Enter "Yearly Subscription"
3. **Product ID**: Enter `yearly_subscription` (must match exactly)
4. **Subscription Duration**: Select "1 Year"
5. **Price**: Set your desired yearly price
6. **Localization**:
   - Click "Add Localization"
   - Select your primary language
   - **Display Name**: "Yearly Subscription"
   - **Description**: "Remove all ads for one year. Auto-renews unless cancelled."
7. Click **"Create"**

### 3. Create Lifetime Purchase (Non-Consumable)

**This one IS in the In-App Purchases section:**

1. In your app's page, click on **"Features"** in the left sidebar
2. Click on **"In-App Purchases"**
3. Click the **"+"** button (or "Create" button)
4. **Select Type**: Choose **"Non-Consumable"** (this is the one-time purchase option)
5. **Reference Name**: Enter "Lifetime Purchase"
6. **Product ID**: Enter `lifetime_purchase` (must match exactly)
7. **Price**: Set your desired lifetime price
8. **Localization**:
   - Click "Add Localization"
   - Select your primary language
   - **Display Name**: "Lifetime Premium"
   - **Description**: "Remove all ads forever. One-time purchase."
9. Click **"Save"**

1. **Select Type**: Choose **"Non-Consumable"** (one-time purchase)
2. **Reference Name**: Enter "Lifetime Purchase"
3. **Product ID**: Enter `lifetime_purchase` (must match exactly)
4. **Price**: Set your desired lifetime price
5. **Localization**:
   - Click "Add Localization"
   - Select your primary language
   - **Display Name**: "Lifetime Premium"
   - **Description**: "Remove all ads forever. One-time purchase."
6. Click **"Save"**

### 4. Configure Subscription Group (Important!)

If you created a subscription group:

1. Go to your subscription group settings
2. **Set Display Order**: 
   - Arrange subscriptions in the order you want them displayed
   - Typically: Yearly (best value), Monthly, Lifetime
3. **Subscription Group Localization**:
   - Add a name for the subscription group (e.g., "Premium Features")
   - This appears in the App Store

### 5. Submit for Review

1. All in-app purchases must be submitted for review along with your app
2. Go to your app's **"App Store"** tab
3. When submitting a new version, make sure to include the in-app purchases
4. Apple will review both your app and the in-app purchases

## Important Notes

### Product ID Matching
- The Product IDs in App Store Connect **must exactly match** the ones in your code:
  - `monthly_subscription`
  - `yearly_subscription`
  - `lifetime_purchase`

### Testing In-App Purchases

1. **Sandbox Testing**:
   - Create test accounts in App Store Connect → Users and Access → Sandbox Testers
   - Sign out of your Apple ID on the device
   - When testing, you'll be prompted to sign in with a sandbox account
   - Sandbox purchases are free and don't charge real money

2. **Test on Device**:
   - In-app purchases don't work in the iOS Simulator
   - You must test on a real device
   - Use a sandbox test account

### Subscription Management

- Users can manage subscriptions in Settings → [Your Name] → Subscriptions
- Auto-renewable subscriptions will automatically renew unless cancelled
- You should provide a way for users to manage subscriptions in your app (restore purchases button is already implemented)

### Pricing

- Set competitive prices for your market
- Consider offering the yearly subscription at a discount (e.g., 2 months free)
- Lifetime purchase should be priced higher than yearly but offer good value

## Verification Checklist

Before submitting your app:

- [ ] All three product IDs are created in App Store Connect
- [ ] Product IDs match exactly with code (`monthly_subscription`, `yearly_subscription`, `lifetime_purchase`)
- [ ] Monthly subscription is set to "Auto-Renewable Subscription" with 1 month duration
- [ ] Yearly subscription is set to "Auto-Renewable Subscription" with 1 year duration
- [ ] Lifetime purchase is set to "Non-Consumable"
- [ ] All products have proper localization (display name and description)
- [ ] Prices are set appropriately
- [ ] Subscription group is configured (if using subscriptions)
- [ ] Tested with sandbox accounts on a real device
- [ ] Restore purchases functionality works correctly

## Troubleshooting

### "Product not found" error
- Verify Product IDs match exactly (case-sensitive)
- Make sure products are in "Ready to Submit" or "Approved" status
- Ensure you're testing with a sandbox account

### Subscriptions not appearing
- Check that subscriptions are in the same subscription group
- Verify subscription status in App Store Connect
- Make sure you're testing on a real device (not simulator)

### Purchase not completing
- Check device internet connection
- Verify sandbox test account is signed in
- Check App Store Connect for any pending issues

## Additional Resources

- [Apple In-App Purchase Documentation](https://developer.apple.com/in-app-purchase/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Testing In-App Purchases](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox)
