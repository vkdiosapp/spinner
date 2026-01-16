import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'subscription_service.dart';

/// Subscription Popup Widget
/// 
/// Displays subscription plans with a user-friendly UI
class SubscriptionPopup extends StatefulWidget {
  const SubscriptionPopup({super.key});

  @override
  State<SubscriptionPopup> createState() => _SubscriptionPopupState();
}

class _SubscriptionPopupState extends State<SubscriptionPopup> {
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  bool _isPurchasing = false;
  bool _isRestoring = false;
  String? _errorMessage;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (!mounted || _isDisposed) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Show loading message
      if (!mounted || _isDisposed) return;
      setState(() {
        _errorMessage = 'Loading subscription plans...\n\n'
            'This may take a few moments.';
      });
      
      final products = await SubscriptionService.getProducts();
      
      if (!mounted || _isDisposed) return;
      
      if (products.isEmpty) {
        if (!mounted || _isDisposed) return;
        setState(() {
          _errorMessage = 'Unable to load subscription plans from App Store Connect.\n\n'
              'REQUIREMENTS:\n'
              '✓ Products must exist in App Store Connect\n'
              '✓ Product IDs: monthly_purchase, yearly_purchase, lifetime_purchase\n'
              '✓ Products must be "Ready to Submit"\n'
              '✓ Testing on REAL device (not simulator)\n'
              '✓ Signed out of real Apple ID\n'
              '✓ Correct provisioning profile\n\n'
              'Bundle ID: com.vkd.spinner.game\n\n'
              'Tap to retry loading products.';
          _isLoading = false;
        });
      } else {
        if (!mounted || _isDisposed) return;
        setState(() {
          _products = products;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _errorMessage = 'Failed to load subscription plans.\n\n'
            'Error: ${e.toString()}\n\n'
            'Tap to retry.';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _retryLoadProducts() async {
    // Clear error and retry
    setState(() {
      _errorMessage = null;
    });
    await _loadProducts();
  }

  Future<void> _purchaseProduct(ProductDetails product) async {
    if (!mounted || _isDisposed) return;
    
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    try {
      final success = await SubscriptionService.purchaseProduct(product);
      if (!mounted || _isDisposed) return;
      
      if (success) {
        // Purchase initiated successfully
        // The purchase stream will handle the result
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate purchase
        }
      } else {
        if (!mounted || _isDisposed) return;
        setState(() {
          _errorMessage = 'Failed to initiate purchase. Please try again.';
          _isPurchasing = false;
        });
      }
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _errorMessage = 'Purchase failed. Please try again.';
        _isPurchasing = false;
      });
    }
  }

  Future<void> _restorePurchases() async {
    if (!mounted || _isDisposed) return;
    
    setState(() {
      _isRestoring = true;
      _errorMessage = null;
    });

    try {
      final success = await SubscriptionService.restorePurchases();
      if (!mounted || _isDisposed) return;
      
      if (success) {
        // Wait a bit for restore to process
        await Future.delayed(const Duration(seconds: 2));
        
        if (!mounted || _isDisposed) return;
        
        if (SubscriptionService.isSubscribed) {
          if (mounted) {
            Navigator.of(context).pop(true); // Return true to indicate restore
          }
        } else {
          if (!mounted || _isDisposed) return;
          setState(() {
            _errorMessage = 'No active subscriptions found.';
            _isRestoring = false;
          });
        }
      } else {
        if (!mounted || _isDisposed) return;
        setState(() {
          _errorMessage = 'Failed to restore purchases. Please try again.';
          _isRestoring = false;
        });
      }
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _errorMessage = 'Restore failed. Please try again.';
        _isRestoring = false;
      });
    }
  }

  ProductDetails? _getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  String _formatPrice(ProductDetails product) {
    return product.price;
  }

  String _getPlanTitle(String productId) {
    switch (productId) {
      case SubscriptionService.monthlyProductId:
        return 'Monthly';
      case SubscriptionService.yearlyProductId:
        return 'Yearly';
      case SubscriptionService.lifetimeProductId:
        return 'Lifetime';
      default:
        return 'Premium';
    }
  }

  String _getPlanDescription(String productId) {
    switch (productId) {
      case SubscriptionService.monthlyProductId:
        return 'Remove ads\nper month';
      case SubscriptionService.yearlyProductId:
        return 'Remove ads\nper month';
      case SubscriptionService.lifetimeProductId:
        return 'Remove ads\nlifetime';
      default:
        return 'Remove ads';
    }
  }

  String _getSubscriptionStatusText() {
    final type = SubscriptionService.subscriptionType;
    final expirationDate = SubscriptionService.expirationDate;
    
    if (type == SubscriptionService.lifetimeProductId) {
      return 'Lifetime Premium - No expiration';
    }
    
    if (expirationDate != null) {
      final now = DateTime.now();
      final daysRemaining = expirationDate.difference(now).inDays;
      
      if (daysRemaining > 0) {
        if (SubscriptionService.isCancelled) {
          return 'Active until ${_formatDate(expirationDate)} (Cancelled - ${daysRemaining} days remaining)';
        } else {
          return 'Active until ${_formatDate(expirationDate)} (${daysRemaining} days remaining)';
        }
      } else {
        return 'Expired on ${_formatDate(expirationDate)}';
      }
    }
    
    return 'Premium subscription active';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showManageSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Subscription'),
        content: const Text(
          'To manage or cancel your subscription:\n\n'
          '1. Open Settings on your device\n'
          '2. Tap your name at the top\n'
          '3. Tap "Subscriptions"\n'
          '4. Find and manage your subscription\n\n'
          'Note: Cancelled subscriptions remain active until the end of the billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  LinearGradient _getPlanGradient(String productId) {
    switch (productId) {
      case SubscriptionService.monthlyProductId:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        );
      case SubscriptionService.yearlyProductId:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
      case SubscriptionService.lifetimeProductId:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button from dismissing
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Remove Ads',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a plan to remove all ads',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Error message
                if (_errorMessage != null)
                  GestureDetector(
                    onTap: _retryLoadProducts,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Icon(Icons.refresh, color: Colors.red, size: 20),
                        ],
                      ),
                    ),
                  ),
                
                // Loading state
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                
                // Current subscription status
                if (!_isLoading && SubscriptionService.isSubscriptionActive)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Premium Active',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getSubscriptionStatusText(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        if (SubscriptionService.subscriptionType !=
                            SubscriptionService.lifetimeProductId)
                          const SizedBox(height: 8),
                        if (SubscriptionService.subscriptionType !=
                            SubscriptionService.lifetimeProductId)
                          TextButton(
                            onPressed: _showManageSubscriptionDialog,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Manage Subscription',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                
                // Products list
                if (!_isLoading) ...[
                  // Only show plans if not subscribed, or show them anyway for upgrade
                  // Monthly plan
                  if (_getProduct(SubscriptionService.monthlyProductId) != null)
                    _buildPlanCard(
                      _getProduct(SubscriptionService.monthlyProductId)!,
                      isPopular: false,
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Yearly plan
                  if (_getProduct(SubscriptionService.yearlyProductId) != null)
                    _buildPlanCard(
                      _getProduct(SubscriptionService.yearlyProductId)!,
                      isPopular: true,
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Lifetime plan
                  if (_getProduct(SubscriptionService.lifetimeProductId) != null)
                    _buildPlanCard(
                      _getProduct(SubscriptionService.lifetimeProductId)!,
                      isPopular: false,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Restore purchases button
                  TextButton(
                    onPressed: _isRestoring ? null : _restorePurchases,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isRestoring
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Restore Purchases',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Terms and privacy
                  Text(
                    'By purchasing, you agree to our Terms of Service and Privacy Policy. Subscriptions auto-renew unless cancelled.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black.withOpacity(0.5),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildPlanCard(ProductDetails product, {required bool isPopular}) {
    final gradient = _getPlanGradient(product.id);
    final title = _getPlanTitle(product.id);
    final description = _getPlanDescription(product.id);
    final price = _formatPrice(product);

    return GestureDetector(
      onTap: _isPurchasing ? null : () => _purchaseProduct(product),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Popular badge
            if (isPopular)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (product.id == SubscriptionService.yearlyProductId)
                            Text(
                              '/month',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _isPurchasing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Subscribe',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
