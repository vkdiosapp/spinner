# App Store Connect Setup - URGENT

## ✅ What I Just Fixed

1. **Removed StoreKit Configuration** - App now connects to App Store Connect (not local testing)
2. **Increased retry attempts** - 5 retries with longer timeouts (60 seconds)
3. **Better error messages** - Clear requirements shown

## 🚨 CRITICAL: Set Up Products in App Store Connect NOW

### Step 1: Go to App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Sign in with your Apple Developer account
3. Select your app: **PickSpiN** (Bundle ID: `com.vkd.spinner.game`)

### Step 2: Create Subscriptions (Monthly & Yearly)

**IMPORTANT**: Subscriptions are in a DIFFERENT section than regular in-app purchases!

1. In your app page, click **"Features"** in left sidebar
2. Click **"Subscriptions"** (NOT "In-App Purchases")
3. Click **"+"** to create a subscription group
4. **Create Subscription Group**:
   - Name: "Premium Subscriptions"
   - Click **"Create"**

5. **Inside the subscription group**, click **"+"** to add subscriptions

#### Create Monthly Subscription:
- **Reference Name**: Monthly Premium Subscription
- **Product ID**: `monthly_purchase` (MUST match exactly)
- **Subscription Duration**: 1 Month
- **Price**: Set your price (e.g., $4.99)
- **Localization**: Add English (US)
  - Display Name: "Monthly Premium"
  - Description: "Monthly premium subscription with access to all features"
- Click **"Create"**
- **Status**: Must be "Ready to Submit" (not "Missing Metadata")

#### Create Yearly Subscription:
- **Reference Name**: Yearly Premium Subscription
- **Product ID**: `yearly_purchase` (MUST match exactly)
- **Subscription Duration**: 1 Year
- **Price**: Set your price (e.g., $39.99)
- **Localization**: Add English (US)
  - Display Name: "Yearly Premium"
  - Description: "Yearly premium subscription with access to all features"
- Click **"Create"**
- **Status**: Must be "Ready to Submit"

### Step 3: Create Lifetime Purchase (In-App Purchase)

1. In your app page, click **"Features"** in left sidebar
2. Click **"In-App Purchases"** (NOT "Subscriptions")
3. Click **"+"** to create
4. **Select Type**: Choose **"Non-Consumable"**
5. **Create Lifetime Purchase**:
   - **Reference Name**: Lifetime Premium Purchase
   - **Product ID**: `lifetime_purchase` (MUST match exactly)
   - **Price**: Set your price (e.g., $99.99)
   - **Localization**: Add English (US)
     - Display Name: "Lifetime Premium"
     - Description: "One-time lifetime purchase with access to all premium features forever"
   - Click **"Create"**
   - **Status**: Must be "Ready to Submit"

## ✅ Verify Product IDs Match Exactly

Your app uses these EXACT product IDs:
- `monthly_purchase` - Monthly subscription
- `yearly_purchase` - Yearly subscription
- `lifetime_purchase` - Lifetime purchase

**CRITICAL**: Product IDs in App Store Connect MUST match exactly (case-sensitive, no spaces, no typos)

## 📱 Testing Requirements

1. **Real Device**: Must test on a REAL iPhone/iPad (not simulator)
2. **Sign Out**: Sign out of your real Apple ID in Settings → App Store
3. **Sandbox Account**: Use a sandbox test account (create in App Store Connect → Users and Access → Sandbox Testers)
4. **Provisioning Profile**: App must be signed with correct provisioning profile
5. **Bundle ID**: Must match exactly: `com.vkd.spinner.game`

## 🔄 After Setting Up Products

1. **Wait 5-10 minutes** for App Store Connect to process
2. **Clean and rebuild** your app:
   ```bash
   cd ios
   flutter clean
   flutter pub get
   cd ios
   pod install
   ```
3. **Run on real device** (not simulator)
4. **Sign out** of real Apple ID
5. **Test the subscription popup** - products should load

## 🐛 If Still Not Working

1. **Check Product Status**: All products must be "Ready to Submit"
2. **Verify Product IDs**: Must match exactly (no typos)
3. **Check Bundle ID**: Must be `com.vkd.spinner.game`
4. **Real Device**: Simulator won't work
5. **Sign Out**: Must be signed out of real Apple ID
6. **Wait**: App Store Connect can take 5-10 minutes to sync

## 📞 Quick Checklist

- [ ] Products created in App Store Connect
- [ ] Product IDs match exactly: `monthly_purchase`, `yearly_purchase`, `lifetime_purchase`
- [ ] All products are "Ready to Submit"
- [ ] Testing on REAL device
- [ ] Signed out of real Apple ID
- [ ] Using sandbox test account
- [ ] Bundle ID matches: `com.vkd.spinner.game`
- [ ] Clean build and rebuild app

## ⚡ After Setup

Once products are configured and "Ready to Submit", the app will automatically fetch them from App Store Connect. No code changes needed - just rebuild and run!
