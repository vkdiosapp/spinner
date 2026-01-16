# iOS In-App Purchase Verification Checklist

## ✅ Product IDs Updated

Your product IDs in the code now match App Store Connect:
- ✅ `monthly_purchase` - Monthly subscription
- ✅ `yearly_purchase` - Yearly subscription  
- ✅ `lifetime_purchase` - Lifetime purchase

## Next Steps to Show Plans in App

### 1. Verify Product Status in App Store Connect

For each product, make sure:

1. **Subscriptions** (monthly_purchase, yearly_purchase):
   - Go to **Features → Subscriptions**
   - Click on your subscription group
   - Verify both subscriptions show status as **"Ready to Submit"** or **"Approved"**
   - Make sure they have:
     - ✅ Product ID set correctly
     - ✅ Price configured
     - ✅ Display name and description added
     - ✅ Localization completed

2. **In-App Purchase** (lifetime_purchase):
   - Go to **Features → In-App Purchases**
   - Verify it shows status as **"Ready to Submit"** or **"Approved"**
   - Make sure it has:
     - ✅ Product ID: `lifetime_purchase`
     - ✅ Type: Non-Consumable
     - ✅ Price configured
     - ✅ Display name and description added

### 2. Test on Real Device (Required!)

**Important**: In-app purchases don't work in the iOS Simulator. You MUST test on a real device.

#### Setup Sandbox Testing:

1. **Create Sandbox Test Accounts**:
   - Go to App Store Connect → **Users and Access** → **Sandbox Testers**
   - Click **"+"** to add a new sandbox tester
   - Enter email (can be fake, like `test@example.com`)
   - Enter password
   - Select country/region
   - Click **"Save"**

2. **Sign Out on Test Device**:
   - On your iPhone/iPad, go to **Settings → [Your Name]**
   - Scroll down and tap **"Sign Out"**
   - This is important! You need to be signed out of your real Apple ID

3. **Run Your App**:
   - Build and run your app on the device
   - Tap the subscription icon (star icon) on the home page
   - The subscription popup should appear

4. **Test Purchase Flow**:
   - When you tap "Subscribe" on any plan, iOS will prompt you to sign in
   - Sign in with your **sandbox test account** (the one you created)
   - Complete the purchase (it's free in sandbox)
   - Verify the purchase completes successfully

### 3. Verify Products Load Correctly

When you open the subscription popup, you should see:

1. **Loading State**: Brief loading indicator while fetching products
2. **Three Plans Displayed**:
   - Monthly plan with price
   - Yearly plan with "BEST VALUE" badge
   - Lifetime plan with price
3. **Prices**: Should show the actual prices you set in App Store Connect

### 4. Common Issues & Solutions

#### Issue: "Product not found" or products don't load

**Solutions**:
- ✅ Verify Product IDs match exactly (case-sensitive)
  - Code: `monthly_purchase`, `yearly_purchase`, `lifetime_purchase`
  - App Store Connect: Must match exactly
- ✅ Check product status is "Ready to Submit" or "Approved"
- ✅ Make sure you're testing on a **real device** (not simulator)
- ✅ Verify you're signed out of your real Apple ID
- ✅ Wait a few minutes after creating products (they need to propagate)

#### Issue: Products load but purchase fails

**Solutions**:
- ✅ Make sure you're using a **sandbox test account**
- ✅ Verify sandbox account is created in App Store Connect
- ✅ Check device has internet connection
- ✅ Try signing out and back in with sandbox account

#### Issue: Subscription popup shows but is empty

**Solutions**:
- ✅ Check console logs for errors
- ✅ Verify all three products exist in App Store Connect
- ✅ Make sure products are in the same subscription group (for monthly/yearly)
- ✅ Check product status is not "Missing Metadata" or "Developer Action Needed"

### 5. Testing Checklist

Before submitting to App Store:

- [ ] All three products created in App Store Connect
- [ ] Product IDs match exactly: `monthly_purchase`, `yearly_purchase`, `lifetime_purchase`
- [ ] All products show "Ready to Submit" or "Approved" status
- [ ] Sandbox test account created
- [ ] Tested on real device (not simulator)
- [ ] Signed out of real Apple ID on test device
- [ ] Subscription popup opens correctly
- [ ] All three plans display with correct prices
- [ ] Monthly subscription purchase works
- [ ] Yearly subscription purchase works
- [ ] Lifetime purchase works
- [ ] "Restore Purchases" button works
- [ ] Ads are disabled after successful purchase
- [ ] Subscription status persists after app restart

### 6. Debug Information

If products aren't loading, check the console logs. The app will print:
- `Subscription service initialized. Available: true/false`
- `Error getting products: [error message]`
- `Purchase successful: [product_id]`

### 7. Production Deployment

Once testing is complete:

1. **Submit Products for Review**:
   - Products must be submitted along with your app
   - Go to your app's **App Store** tab
   - When submitting a new version, include the in-app purchases
   - Apple will review both app and purchases together

2. **After Approval**:
   - Products will be available to all users
   - Real purchases will work (not just sandbox)
   - Users can purchase and restore subscriptions

## Quick Test Commands

To verify the setup is working, you can add debug prints in your code or check the console output when:
- Opening the subscription popup
- Attempting a purchase
- Restoring purchases

The subscription service will log important events to help you debug.
