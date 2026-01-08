/// AdMob Ad Manager
///
/// Replace the placeholder values below with your actual AdMob Ad Unit IDs
/// You can find your Ad Unit IDs in the AdMob dashboard:
/// https://apps.admob.com -> Select your app -> Ad units
class AdManager {
  /// Your AdMob App ID (required for both Android and iOS)
  /// Replace 'YOUR_ADMOB_APP_ID' with your actual App ID from AdMob dashboard
  /// Format: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
  static const String appId = 'YOUR_ADMOB_APP_ID';

  /// Android Banner Ad Unit ID
  /// Replace 'YOUR_ANDROID_BANNER_AD_ID' with your actual Android Banner Ad Unit ID
  /// Format: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
  static const String androidBannerAdId = 'YOUR_ANDROID_BANNER_AD_ID';

  /// iOS Banner Ad Unit ID
  /// Replace 'YOUR_IOS_BANNER_AD_ID' with your actual iOS Banner Ad Unit ID
  /// Format: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
  static const String iosBannerAdId = 'YOUR_IOS_BANNER_AD_ID';

  /// Get the appropriate banner ad ID based on platform
  static String getBannerAdId() {
    // This will be determined at runtime based on the platform
    // For now, return Android ID as default (will be overridden in ad_helper)
    return androidBannerAdId;
  }

  /// Test Ad Unit IDs (for testing - use these during development)
  /// These are Google's official test ad IDs that always return test ads
  /// Remove these in production and use your actual Ad Unit IDs above

  /// Android Test Ad Unit IDs
  static const String testAndroidBannerAdId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testAndroidInterstitialAdId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testAndroidRewardedAdId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String testAndroidRewardedInterstitialAdId =
      'ca-app-pub-3940256099942544/5354046379';
  static const String testAndroidAppOpenAdId =
      'ca-app-pub-3940256099942544/3419835294';
  static const String testAndroidNativeAdId =
      'ca-app-pub-3940256099942544/2247696110';

  /// iOS Test Ad Unit IDs
  static const String testIosBannerAdId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String testIosInterstitialAdId =
      'ca-app-pub-3940256099942544/4411468910';
  static const String testIosRewardedAdId =
      'ca-app-pub-3940256099942544/1712485313';
  static const String testIosRewardedInterstitialAdId =
      'ca-app-pub-3940256099942544/6978759866';
  static const String testIosAppOpenAdId =
      'ca-app-pub-3940256099942544/5662855259';
  static const String testIosNativeAdId =
      'ca-app-pub-3940256099942544/3986624511';

  /// Universal Test Ad Unit IDs (work on both platforms)
  static const String testBannerAdId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String testRewardedInterstitialAdId =
      'ca-app-pub-3940256099942544/5354046379';
  static const String testAppOpenAdId =
      'ca-app-pub-3940256099942544/3419835294';
  static const String testNativeAdId = 'ca-app-pub-3940256099942544/2247696110';

  /// Test App ID (for testing - use this during development)
  static const String testAppId = 'ca-app-pub-3940256099942544~3347511713';

  /// Use test ads during development (set to false when using real ads)
  static const bool useTestAds = true; // Set to false when using real ads

  /// Get test banner ad ID based on platform
  static String getTestBannerAdId() {
    // For testing, you can use platform-specific test IDs or the universal one
    return testBannerAdId; // Universal test banner ad ID
  }
}
