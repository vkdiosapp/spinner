import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'onesignal_config.dart';

/// OneSignal Push Notification Service
/// 
/// Handles initialization and notification callbacks for OneSignal
class OneSignalService {
  /// Initialize OneSignal with configuration
  static Future<void> initialize() async {
    // Set App ID
    OneSignal.initialize(OneSignalConfig.appId);

    // Request permission for notifications
    OneSignal.Notifications.requestPermission(true);

    // Set notification click handler
    OneSignal.Notifications.addClickListener(_handleNotificationClick);

    // Enable logging if configured
    if (OneSignalConfig.enableLogging) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    }
  }

  /// Handle notification click/tap
  static void _handleNotificationClick(OSNotificationClickEvent event) {
    final notification = event.notification;
    
    // Handle notification click data
    if (notification.additionalData != null) {
      // You can handle custom data here
      // Example: Navigate to a specific page based on notification data
      print('Notification clicked with data: ${notification.additionalData}');
    }
    
    // Handle notification action buttons if any
    if (event.result.actionId != null) {
      print('Notification action clicked: ${event.result.actionId}');
    }
  }

  /// Get the current user's OneSignal Player ID
  static Future<String?> getPlayerId() async {
    final deviceState = await OneSignal.User.pushSubscription.id;
    return deviceState;
  }

  /// Set user tags (for targeted notifications)
  static Future<void> setUserTag(String key, String value) async {
    await OneSignal.User.addTags({key: value});
  }

  /// Set user email (for email notifications)
  static Future<void> setUserEmail(String email) async {
    await OneSignal.User.addEmail(email);
  }

  /// Set user external ID (for linking users across systems)
  static Future<void> setExternalUserId(String userId) async {
    await OneSignal.User.addAlias('external_id', userId);
  }

  /// Remove external user ID
  static Future<void> removeExternalUserId() async {
    await OneSignal.User.removeAlias('external_id');
  }

  /// Send a tag to OneSignal
  static Future<void> sendTag(String key, String value) async {
    await OneSignal.User.addTags({key: value});
  }

  /// Send multiple tags to OneSignal
  static Future<void> sendTags(Map<String, String> tags) async {
    await OneSignal.User.addTags(tags);
  }

  /// Delete a tag
  static Future<void> deleteTag(String key) async {
    await OneSignal.User.removeTag(key);
  }

  /// Delete multiple tags
  static Future<void> deleteTags(List<String> keys) async {
    await OneSignal.User.removeTags(keys);
  }
}

