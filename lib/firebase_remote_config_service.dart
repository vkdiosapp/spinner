import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Firebase Remote Config Service
/// 
/// Manages fetching and caching ad IDs from Firebase Remote Config
class FirebaseRemoteConfigService {
  static FirebaseRemoteConfig? _remoteConfig;
  static bool _isInitialized = false;

  /// Initialize Firebase Remote Config
  static Future<void> initialize() async {
    if (_isInitialized) {
      // Already initialized, but fetch fresh values on app start
      await fetchFreshValues();
      return;
    }

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      // Set default values (empty strings - will be replaced by Remote Config)
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set defaults for all ad IDs (empty strings)
      await _remoteConfig!.setDefaults({
        'android_banner_ad_id': '',
        'ios_banner_ad_id': '',
        'android_interstitial_ad_id': '',
        'ios_interstitial_ad_id': '',
        'android_native_ad_id': '',
        'ios_native_ad_id': '',
        'android_rewarded_ad_id': '',
        'ios_rewarded_ad_id': '',
        'android_app_open_ad_id': '',
        'ios_app_open_ad_id': '',
      });

      // Fetch fresh values on initialization (bypass cache)
      await fetchFreshValues();
      
      _isInitialized = true;
      debugPrint('Firebase Remote Config initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase Remote Config: $e');
      _isInitialized = false;
    }
  }

  /// Fetch fresh values from Firebase Remote Config (bypasses cache)
  /// This is called every time the app opens to get the latest ad IDs
  static Future<void> fetchFreshValues() async {
    if (!_isInitialized || _remoteConfig == null) {
      debugPrint('Remote Config not initialized, cannot fetch fresh values');
      return;
    }

    try {
      // Temporarily set minimumFetchInterval to 0 to bypass cache
      // This allows us to fetch fresh values every time the app opens
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero, // No cache - fetch fresh values
      ));

      // Fetch and activate fresh values
      final fetched = await _remoteConfig!.fetchAndActivate();
      
      if (fetched) {
        debugPrint('✅ Fresh Remote Config values fetched and activated');
        debugPrint('Ad IDs updated from Firebase Remote Config');
      } else {
        debugPrint('Remote Config fetch completed (using cached or default values)');
      }

      // Restore the normal fetch interval for background fetches
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
    } catch (e) {
      debugPrint('Error fetching fresh Remote Config values: $e');
      // Try to restore settings even if fetch failed
      try {
        await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ));
      } catch (_) {
        // Ignore restore errors
      }
    }
  }

  /// Get ad ID from Remote Config
  /// Returns empty string if not found or not initialized
  static String getAdId(String key) {
    if (!_isInitialized || _remoteConfig == null) {
      debugPrint('Remote Config not initialized, returning empty ad ID');
      return '';
    }

    try {
      final value = _remoteConfig!.getString(key);
      return value.trim();
    } catch (e) {
      debugPrint('Error getting ad ID for key $key: $e');
      return '';
    }
  }

  /// Fetch and activate Remote Config values
  /// Call this periodically to get updated values (respects cache interval)
  static Future<void> fetchAndActivate() async {
    if (!_isInitialized || _remoteConfig == null) {
      return;
    }

    try {
      await _remoteConfig!.fetchAndActivate();
      debugPrint('Remote Config values fetched and activated');
    } catch (e) {
      debugPrint('Error fetching Remote Config: $e');
    }
  }

  /// Check if Remote Config is initialized
  static bool get isInitialized => _isInitialized;
}
