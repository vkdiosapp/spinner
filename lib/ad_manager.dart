import 'dart:io';
import 'firebase_remote_config_service.dart';

/// AdMob Ad Manager
///
/// Ad IDs are now fetched dynamically from Firebase Remote Config.
/// If no ad ID is found in Remote Config, static fallback IDs are used for iOS.
class AdManager {
  // Static fallback ad IDs for iOS (used only if Remote Config doesn't provide an ID)
  static const String _iosBannerAdIdFallback = 'ca-app-pub-9475071886046004/3205559202';
  static const String _iosInterstitialAdIdFallback = 'ca-app-pub-9475071886046004/3078895684';
  static const String _iosRewardedAdIdFallback = 'ca-app-pub-9475071886046004/4680408503';
  static const String _iosAppOpenAdIdFallback = 'ca-app-pub-9475071886046004/6177323006';
  static const String _iosNativeAdIdFallback = 'ca-app-pub-9475071886046004/6209112598';
  /// Get Android Banner Ad Unit ID from Firebase Remote Config
  /// Returns empty string if not found (no ads will be shown)
  static String getAndroidBannerAdId() {
    return FirebaseRemoteConfigService.getAdId('android_banner_ad_id');
  }

  /// Get iOS Banner Ad Unit ID from Firebase Remote Config
  /// Falls back to static ID if Remote Config doesn't provide one
  static String getIosBannerAdId() {
    final remoteConfigId = FirebaseRemoteConfigService.getAdId('ios_banner_ad_id');
    return remoteConfigId.isEmpty ? _iosBannerAdIdFallback : remoteConfigId;
  }

  /// Get Android Interstitial Ad Unit ID from Firebase Remote Config
  /// Returns empty string if not found (no ads will be shown)
  static String getAndroidInterstitialAdId() {
    return FirebaseRemoteConfigService.getAdId('android_interstitial_ad_id');
  }

  /// Get iOS Interstitial Ad Unit ID from Firebase Remote Config
  /// Falls back to static ID if Remote Config doesn't provide one
  static String getIosInterstitialAdId() {
    final remoteConfigId = FirebaseRemoteConfigService.getAdId('ios_interstitial_ad_id');
    return remoteConfigId.isEmpty ? _iosInterstitialAdIdFallback : remoteConfigId;
  }

  /// Get Android Native Ad Unit ID from Firebase Remote Config
  /// Returns empty string if not found (no ads will be shown)
  static String getAndroidNativeAdId() {
    return FirebaseRemoteConfigService.getAdId('android_native_ad_id');
  }

  /// Get iOS Native Ad Unit ID from Firebase Remote Config
  /// Falls back to static ID if Remote Config doesn't provide one
  static String getIosNativeAdId() {
    final remoteConfigId = FirebaseRemoteConfigService.getAdId('ios_native_ad_id');
    return remoteConfigId.isEmpty ? _iosNativeAdIdFallback : remoteConfigId;
  }

  /// Get Android Rewarded Ad Unit ID from Firebase Remote Config
  /// Returns empty string if not found (no ads will be shown)
  static String getAndroidRewardedAdId() {
    return FirebaseRemoteConfigService.getAdId('android_rewarded_ad_id');
  }

  /// Get iOS Rewarded Ad Unit ID from Firebase Remote Config
  /// Falls back to static ID if Remote Config doesn't provide one
  static String getIosRewardedAdId() {
    final remoteConfigId = FirebaseRemoteConfigService.getAdId('ios_rewarded_ad_id');
    return remoteConfigId.isEmpty ? _iosRewardedAdIdFallback : remoteConfigId;
  }

  /// Get Android App Open Ad Unit ID from Firebase Remote Config
  /// Returns empty string if not found (no ads will be shown)
  static String getAndroidAppOpenAdId() {
    return FirebaseRemoteConfigService.getAdId('android_app_open_ad_id');
  }

  /// Get iOS App Open Ad Unit ID from Firebase Remote Config
  /// Falls back to static ID if Remote Config doesn't provide one
  static String getIosAppOpenAdId() {
    final remoteConfigId = FirebaseRemoteConfigService.getAdId('ios_app_open_ad_id');
    return remoteConfigId.isEmpty ? _iosAppOpenAdIdFallback : remoteConfigId;
  }

  /// Get the appropriate banner ad ID based on platform
  /// Returns empty string if not found (no ads will be shown)
  static String getBannerAdId() {
    if (Platform.isAndroid) {
      return getAndroidBannerAdId();
    } else if (Platform.isIOS) {
      return getIosBannerAdId();
    }
    return ''; // Default to empty (no ads)
  }

  /// Get the appropriate interstitial ad ID based on platform
  /// Returns empty string if not found (no ads will be shown)
  static String getInterstitialAdId() {
    if (Platform.isAndroid) {
      return getAndroidInterstitialAdId();
    } else if (Platform.isIOS) {
      return getIosInterstitialAdId();
    }
    return ''; // Default to empty (no ads)
  }

  /// Get the appropriate native ad ID based on platform
  /// Returns empty string if not found (no ads will be shown)
  static String getNativeAdId() {
    if (Platform.isAndroid) {
      return getAndroidNativeAdId();
    } else if (Platform.isIOS) {
      return getIosNativeAdId();
    }
    return ''; // Default to empty (no ads)
  }

  /// Get the appropriate rewarded ad ID based on platform
  /// Returns empty string if not found (no ads will be shown)
  static String getRewardedAdId() {
    if (Platform.isAndroid) {
      return getAndroidRewardedAdId();
    } else if (Platform.isIOS) {
      return getIosRewardedAdId();
    }
    return ''; // Default to empty (no ads)
  }

  /// Get the appropriate app open ad ID based on platform
  /// Returns empty string if not found (no ads will be shown)
  static String getAppOpenAdId() {
    if (Platform.isAndroid) {
      return getAndroidAppOpenAdId();
    } else if (Platform.isIOS) {
      return getIosAppOpenAdId();
    }
    return ''; // Default to empty (no ads)
  }
}
