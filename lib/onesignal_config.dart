/// OneSignal Push Notification Configuration
///
/// Replace the placeholder values below with your actual OneSignal App ID
/// You can find your App ID in the OneSignal dashboard:
/// https://app.onesignal.com/apps -> Select your app -> Settings -> Keys & IDs
class OneSignalConfig {
  /// Your OneSignal App ID
  /// Replace 'YOUR_ONESIGNAL_APP_ID' with your actual App ID from OneSignal dashboard
  static const String appId = '057453e0-68da-4c0f-8923-4b3fc065d73f';

  /// Enable logging for debugging (set to false in production)
  static const bool enableLogging = true;

  /// Require user consent for privacy (set to true if you need GDPR compliance)
  static const bool requireUserConsent = false;

  /// Enable in-app notifications (shows notification banner when app is open)
  static const bool enableInAppNotifications = true;

  /// Enable notification badges on app icon
  static const bool enableNotificationBadges = true;

  /// Enable sound for notifications
  static const bool enableSound = true;

  /// Enable vibration for notifications
  static const bool enableVibration = true;
}
