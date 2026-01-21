import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Subscription Service
///
/// Handles in-app purchases for subscriptions and lifetime purchases
class SubscriptionService {
  static const String _subscriptionStatusKey = 'subscription_status';
  static const String _subscriptionTypeKey = 'subscription_type';
  static const String _purchaseDateKey = 'purchase_date';
  static const String _expirationDateKey = 'expiration_date';
  static const String _isCancelledKey = 'is_cancelled';

  // Product IDs - These should match your App Store Connect / Google Play Console product IDs
  static const String monthlyProductId = 'monthly_purchase';
  static const String yearlyProductId = 'yearly_purchase';
  static const String lifetimeProductId = 'lifetime_purchase';

  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  static bool _isAvailable = false;
  static bool _isInitialized = false;

  static bool _isSubscribed = false;
  static String _subscriptionType = '';
  static DateTime? _purchaseDate;
  static DateTime? _expirationDate;
  static bool _isCancelled = false;

  /// Initialize the subscription service
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ SubscriptionService already initialized. Available: $_isAvailable');
      return;
    }

    try {
      debugPrint('🔍 Checking if In-App Purchase is available...');
      _isAvailable = await _inAppPurchase.isAvailable();
      debugPrint('📱 In-App Purchase Available: $_isAvailable');

      if (!_isAvailable) {
        debugPrint('');
        debugPrint('❌ EXACT REASON PLANS NOT SHOWING: In-App Purchase is NOT available');
        debugPrint('');
        debugPrint('POSSIBLE CAUSES:');
        debugPrint('1. ⚠️ Running on iOS Simulator (IAP NOT supported - use REAL device)');
        debugPrint('2. ⚠️ In-App Purchases disabled in device Settings → Screen Time → Content & Privacy Restrictions');
        debugPrint('3. ⚠️ StoreKit not available on this device');
        debugPrint('4. ⚠️ App not properly signed with provisioning profile');
        debugPrint('');
        debugPrint('✅ SOLUTION: Test on REAL iOS device (not simulator)');
        debugPrint('');
      }

      if (_isAvailable) {
        // Load subscription status from local storage
        await _loadSubscriptionStatus();

        // Listen to purchase updates
        _subscription = _inAppPurchase.purchaseStream.listen(
          _handlePurchaseUpdates,
          onDone: () => _subscription?.cancel(),
          onError: (error) => debugPrint('Purchase stream error: $error'),
        );

        // Restore purchases on initialization to verify status
        await restorePurchases();

        // Verify subscription status
        await _verifySubscriptionStatus();
      }

      _isInitialized = true;
      debugPrint('✅ Subscription service initialized. Available: $_isAvailable');
    } catch (e) {
      debugPrint('❌ Error initializing subscription service: $e');
      debugPrint('⚠️ This error may prevent plans from loading');
      _isInitialized = true;
    }
  }

  /// Load subscription status from SharedPreferences
  static Future<void> _loadSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isSubscribed = prefs.getBool(_subscriptionStatusKey) ?? false;
      _subscriptionType = prefs.getString(_subscriptionTypeKey) ?? '';
      _isCancelled = prefs.getBool(_isCancelledKey) ?? false;

      final purchaseDateString = prefs.getString(_purchaseDateKey);
      if (purchaseDateString != null) {
        _purchaseDate = DateTime.parse(purchaseDateString);
      }

      final expirationDateString = prefs.getString(_expirationDateKey);
      if (expirationDateString != null) {
        _expirationDate = DateTime.parse(expirationDateString);
      }
    } catch (e) {
      debugPrint('Error loading subscription status: $e');
    }
  }

  /// Save subscription status to SharedPreferences
  static Future<void> _saveSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_subscriptionStatusKey, _isSubscribed);
      await prefs.setString(_subscriptionTypeKey, _subscriptionType);
      await prefs.setBool(_isCancelledKey, _isCancelled);

      if (_purchaseDate != null) {
        await prefs.setString(
          _purchaseDateKey,
          _purchaseDate!.toIso8601String(),
        );
      }

      if (_expirationDate != null) {
        await prefs.setString(
          _expirationDateKey,
          _expirationDate!.toIso8601String(),
        );
      }
    } catch (e) {
      debugPrint('Error saving subscription status: $e');
    }
  }

  /// Handle purchase updates
  static void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        debugPrint('Purchase pending: ${purchase.productID}');
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('Purchase error: ${purchase.error}');
        _handlePurchaseError(purchase);
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _handleSuccessfulPurchase(purchase);
      }

      // Check for cancelled subscriptions
      _checkSubscriptionStatus(purchase);

      // Complete the purchase
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  /// Handle successful purchase
  static Future<void> _handleSuccessfulPurchase(
    PurchaseDetails purchase,
  ) async {
    debugPrint('Purchase successful: ${purchase.productID}');

    final productId = purchase.productID;

    // Check if it's a subscription or lifetime purchase
    if (productId == monthlyProductId ||
        productId == yearlyProductId ||
        productId == lifetimeProductId) {
      _isSubscribed = true;
      _subscriptionType = productId;
      _purchaseDate = DateTime.now();
      _isCancelled = false;

      // For subscriptions, try to get expiration from purchase details
      // If not available, calculate based on product type
      if (productId == monthlyProductId) {
        // Try to get expiration from purchase transactionDate
        // For monthly, add 30 days from purchase date
        _expirationDate = DateTime.now().add(const Duration(days: 30));
      } else if (productId == yearlyProductId) {
        // For yearly, add 365 days from purchase date
        _expirationDate = DateTime.now().add(const Duration(days: 365));
      } else {
        // Lifetime - NEVER expires, no expiration date
        _expirationDate = null;
      }

      await _saveSubscriptionStatus();
      debugPrint('Subscription activated: $productId');
      if (_expirationDate != null) {
        debugPrint('Expiration date: $_expirationDate');
      } else {
        debugPrint('Lifetime purchase - no expiration');
      }
    }
  }

  /// Check subscription status and handle cancellations
  static Future<void> _checkSubscriptionStatus(PurchaseDetails purchase) async {
    // Check if this is a subscription product (not lifetime)
    if (purchase.productID == monthlyProductId ||
        purchase.productID == yearlyProductId) {
      // For iOS, check if subscription is cancelled
      // Note: Cancelled subscriptions remain active until expiration
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Subscription is still active - verify expiration
        await _verifySubscriptionStatus();
      }
    } else if (purchase.productID == lifetimeProductId) {
      // Lifetime purchase - never expires, always active
      _isSubscribed = true;
      _subscriptionType = lifetimeProductId;
      _expirationDate = null; // Ensure no expiration for lifetime
      await _saveSubscriptionStatus();
      debugPrint('Lifetime purchase confirmed - never expires');
    }
  }

  /// Handle purchase error
  static void _handlePurchaseError(PurchaseDetails purchase) {
    debugPrint('Purchase failed: ${purchase.error}');
  }

  /// Get available products with retry logic
  static Future<List<ProductDetails>> getProducts({int maxRetries = 3}) async {
    if (!_isAvailable) {
      debugPrint('');
      debugPrint('❌ EXACT REASON PLANS NOT SHOWING: In-App Purchase is NOT available');
      debugPrint('   _isAvailable = false');
      debugPrint('');
      debugPrint('This means _inAppPurchase.isAvailable() returned false during initialization.');
      debugPrint('Check the initialization logs above for details.');
      debugPrint('');
      return [];
    }

    final productIds = {monthlyProductId, yearlyProductId, lifetimeProductId};
    debugPrint('Fetching products: $productIds');

    // Retry logic with exponential backoff - reduced retries and faster timeouts
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('Attempt $attempt of $maxRetries to fetch products...');

        // Reduced timeout - StoreKit should respond quickly or not at all
        final response = await _inAppPurchase
            .queryProductDetails(productIds)
            .timeout(
              const Duration(seconds: 15), // Reduced from 60 to 15 seconds
              onTimeout: () {
                throw TimeoutException(
                  'Product query timed out after 15 seconds',
                  const Duration(seconds: 15),
                );
              },
            );

        if (response.error != null) {
          final error = response.error!;
          debugPrint(
            'Error fetching products: ${error.code} - ${error.message}',
          );
          debugPrint('Error details: ${error.details}');
          debugPrint('Error source: ${error.source}');

          // Handle storekit_no_response specifically
          if (error.code == 'storekit_no_response') {
            debugPrint('⚠️ StoreKit Error: storekit_no_response');
            debugPrint('StoreKit cannot connect to App Store Connect.');
            debugPrint('');
            debugPrint('REQUIREMENTS for App Store Connect:');
            debugPrint('1. ✅ Test on REAL device (iOS Simulator does NOT support IAP)');
            debugPrint('2. ✅ Products must exist in App Store Connect');
            debugPrint('   - Product IDs: monthly_purchase, yearly_purchase, lifetime_purchase');
            debugPrint('   - Products must be in "Ready to Submit" or "Approved" status');
            debugPrint('3. ✅ Sign out of real Apple ID (use sandbox test account)');
            debugPrint('4. ✅ Check internet connection');
            debugPrint('5. ✅ App must be signed with correct provisioning profile');
            debugPrint('6. ✅ Bundle ID must match: com.vkd.spinner.game');
            debugPrint('');
            
            // For storekit_no_response, don't retry too many times
            // It usually means simulator or App Store Connect connection issue
            if (attempt >= 2) {
              debugPrint('⚠️ StoreKit not responding. Likely causes:');
              debugPrint('   - Running on iOS Simulator (IAP not supported - use REAL device)');
              debugPrint('   - Products not configured in App Store Connect');
              debugPrint('   - Network/App Store Connect connection issue');
              debugPrint('   - Products not in "Ready to Submit" status');
              return [];
            }

            // Quick retry with short delay
            final delay = Duration(seconds: 2);
            debugPrint('Quick retry in ${delay.inSeconds} seconds...');
            await Future.delayed(delay);
            continue;
          } else if (error.code == 'storekit_product_not_available' ||
              error.code == 'storekit_cloud_service_permission_denied') {
            debugPrint('StoreKit Error: ${error.code}');
            debugPrint('Bundle ID: com.vkd.spinner.game');
            debugPrint('Expected Product IDs: $productIds');
            debugPrint('');
            debugPrint('REQUIREMENTS:');
            debugPrint('1. Products must exist in App Store Connect');
            debugPrint('2. Product IDs must match exactly: $productIds');
            debugPrint('3. Products must be in "Ready to Submit" status');
            debugPrint('4. Testing on REAL device (not simulator)');
            debugPrint('5. Signed out of real Apple ID (use sandbox account)');
            
            if (attempt == maxRetries) {
              debugPrint('All $maxRetries retry attempts failed.');
              return [];
            }

            final delay = Duration(seconds: attempt * 2);
            debugPrint('Retrying in ${delay.inSeconds} seconds...');
            await Future.delayed(delay);
            continue;
          } else {
            // For other errors, don't retry
            debugPrint('Non-retryable error: ${error.code}');
            return [];
          }
        }

        if (response.productDetails.isEmpty) {
          debugPrint(
            'Warning: No products returned. Check product IDs in App Store Connect.',
          );
          debugPrint('Expected IDs: $productIds');

          if (attempt == maxRetries) {
            return [];
          }

          final delay = Duration(seconds: attempt * 2);
          debugPrint('Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
          continue;
        }

        debugPrint(
          '✅ Successfully fetched ${response.productDetails.length} products',
        );
        for (final product in response.productDetails) {
          debugPrint(
            'Product: ${product.id} - ${product.title} - ${product.price}',
          );
        }

        return response.productDetails;
      } on TimeoutException catch (e) {
        debugPrint('⏱️ Timeout getting products (attempt $attempt): $e');
        
        // Timeout usually means StoreKit isn't responding
        if (attempt >= 2) {
          debugPrint('⚠️ StoreKit timeout - cannot connect to App Store Connect');
          debugPrint('   Fix: Run on REAL device (not simulator)');
          debugPrint('   Verify products exist in App Store Connect and are "Ready to Submit"');
          return [];
        }

        final delay = Duration(seconds: 2);
        debugPrint('Quick retry in ${delay.inSeconds} seconds...');
        await Future.delayed(delay);
      } catch (e) {
        debugPrint('Exception getting products (attempt $attempt): $e');

        if (attempt == maxRetries) {
          debugPrint('⚠️ All retry attempts failed');
          return [];
        }

        final delay = Duration(seconds: attempt * 2);
        debugPrint('Retrying in ${delay.inSeconds} seconds...');
        await Future.delayed(delay);
      }
    }

    return [];
  }

  /// Purchase a product
  static Future<bool> purchaseProduct(ProductDetails product) async {
    if (!_isAvailable) {
      debugPrint('In-app purchase not available');
      return false;
    }

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      bool result;

      // For all products (subscriptions and non-consumables), use buyNonConsumable
      // The in_app_purchase package handles subscriptions automatically
      result = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      debugPrint('Purchase initiated for: ${product.id}');
      return result;
    } catch (e) {
      debugPrint('Error purchasing product: $e');
      return false;
    }
  }

  /// Restore purchases
  /// This is called when user reinstalls app or wants to restore previous purchases
  static Future<bool> restorePurchases() async {
    if (!_isAvailable) {
      debugPrint('In-app purchase not available');
      return false;
    }

    try {
      debugPrint('Restoring purchases...');
      await _inAppPurchase.restorePurchases();
      // The purchase stream will handle the restored purchases
      // Wait a bit for the purchase stream to process
      await Future.delayed(const Duration(milliseconds: 500));
      // Verify subscription status after restore
      await _verifySubscriptionStatus();
      debugPrint('Purchase restore completed');
      return true;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }

  /// Verify current subscription status
  static Future<void> _verifySubscriptionStatus() async {
    // Don't check expiration for lifetime purchases
    if (_subscriptionType == lifetimeProductId) {
      // Lifetime purchase never expires
      return;
    }

    // Check if subscription has expired
    if (_expirationDate != null && DateTime.now().isAfter(_expirationDate!)) {
      // Subscription has expired - clear all subscription data
      _isSubscribed = false;
      _subscriptionType = '';
      _isCancelled = false;
      _expirationDate = null;
      _purchaseDate = null;
      await _saveSubscriptionStatus();
      debugPrint(
        'Subscription expired and deactivated - ads will be re-enabled',
      );
    } else if (_expirationDate != null) {
      // Subscription is still active
      final daysRemaining = _expirationDate!.difference(DateTime.now()).inDays;
      debugPrint('Subscription active - $daysRemaining days remaining');
    }
  }

  /// Check subscription status (call this periodically or on app start)
  /// This should be called when app resumes or periodically
  static Future<void> checkSubscriptionStatus() async {
    if (!_isInitialized) {
      await initialize();
    }

    // First restore purchases to get latest status from App Store
    await restorePurchases();

    // Then verify expiration
    await _verifySubscriptionStatus();

    debugPrint(
      'Subscription status checked: ${isSubscriptionActive ? "Active" : "Inactive"}',
    );
  }

  /// Check if user is subscribed
  static bool get isSubscribed => _isSubscribed;

  /// Get subscription type
  static String get subscriptionType => _subscriptionType;

  /// Get purchase date
  static DateTime? get purchaseDate => _purchaseDate;

  /// Check if subscription is active (for subscriptions, check expiration)
  /// This is called by the ad system to determine if ads should be shown
  static bool get isSubscriptionActive {
    if (!_isSubscribed) {
      return false; // Not subscribed - ads should show
    }

    // Lifetime purchase is ALWAYS active - never expires
    if (_subscriptionType == lifetimeProductId) {
      return true; // Lifetime - ads should never show
    }

    // For monthly/yearly subscriptions, check expiration date
    if (_expirationDate != null) {
      final isActive = DateTime.now().isBefore(_expirationDate!);
      if (!isActive) {
        // Subscription expired - clear status
        _isSubscribed = false;
        _subscriptionType = '';
        _expirationDate = null;
        _saveSubscriptionStatus(); // Save asynchronously
        debugPrint('Subscription expired - ads will be re-enabled');
      }
      // Subscription is active if not expired
      // Even if cancelled, it remains active until expiration
      return isActive;
    }

    // If no expiration date for subscription, something is wrong
    // Assume not active for safety (ads will show)
    debugPrint('Warning: Subscription has no expiration date');
    return false;
  }

  /// Check if subscription is cancelled (but may still be active until expiration)
  static bool get isCancelled => _isCancelled;

  /// Get expiration date
  static DateTime? get expirationDate => _expirationDate;

  /// Open subscription management (iOS Settings)
  static Future<void> openSubscriptionManagement() async {
    // For iOS, we can't directly open subscription management
    // Users need to go to Settings → [Name] → Subscriptions
    // We can show a dialog or message guiding them
    debugPrint('User should go to Settings → [Name] → Subscriptions to manage');
  }

  /// Dispose the service
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
