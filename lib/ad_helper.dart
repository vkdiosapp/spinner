import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_manager.dart';
import 'sound_vibration_settings.dart';

/// Helper class for managing AdMob banner ads
class AdHelper {
  /// Get the appropriate banner ad unit ID based on platform
  /// Returns empty string if no ad ID is configured (no ads will be shown)
  static String getBannerAdUnitId() {
    return AdManager.getBannerAdId();
  }
}

/// Banner Ad Widget
/// 
/// This widget displays a banner ad at the bottom of the screen
/// It automatically checks if ads are enabled before showing
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // Only load ad if ads are enabled
    if (!SoundVibrationSettings.adsEnabled) {
      return;
    }

    final adUnitId = AdHelper.getBannerAdUnitId();
    
    // Don't load ad if ad ID is empty (not configured in Remote Config)
    if (adUnitId.isEmpty) {
      debugPrint('Banner ad ID is empty, skipping ad load');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Dispose the ad if it fails to load
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
          debugPrint('Banner ad failed to load: $error');
        },
        onAdOpened: (_) {
          debugPrint('Banner ad opened');
        },
        onAdClosed: (_) {
          debugPrint('Banner ad closed');
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show ad widget if ads are disabled
    if (!SoundVibrationSettings.adsEnabled) {
      return const SizedBox.shrink();
    }

    // Only show ad container if ad is loaded
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// Interstitial Ad Helper
/// 
/// Manages loading and showing interstitial ads
class InterstitialAdHelper {
  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;

  /// Load an interstitial ad
  static Future<void> loadInterstitialAd() async {
    // Don't load if ads are disabled
    if (!SoundVibrationSettings.adsEnabled) {
      return;
    }

    // Don't load if already loading or loaded
    if (_isLoading || _interstitialAd != null) {
      return;
    }

    final adUnitId = AdManager.getInterstitialAdId();
    
    // Don't load ad if ad ID is empty (not configured in Remote Config)
    if (adUnitId.isEmpty) {
      debugPrint('Interstitial ad ID is empty, skipping ad load');
      return;
    }

    _isLoading = true;

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
          debugPrint('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _isLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Show interstitial ad and execute callback when ad is closed
  /// Returns true if ad was shown, false if ad was not available
  static Future<bool> showInterstitialAd({
    required VoidCallback onAdClosed,
  }) async {
    // Don't show if ads are disabled
    if (!SoundVibrationSettings.adsEnabled) {
      onAdClosed();
      return false;
    }

    // If ad is not loaded, try to load it first
    if (_interstitialAd == null) {
      await loadInterstitialAd();
      // Wait a bit for ad to load
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // If still no ad, just execute callback
    if (_interstitialAd == null) {
      onAdClosed();
      return false;
    }

    // Show the ad
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        // Load next ad for future use
        loadInterstitialAd();
        // Execute callback after ad is closed
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial ad failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        // Load next ad for future use
        loadInterstitialAd();
        // Execute callback even if ad failed
        onAdClosed();
      },
    );

    await _interstitialAd!.show();
    return true;
  }

  /// Dispose the current interstitial ad
  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

/// Back Arrow Ad Counter
/// 
/// Tracks back button presses on config/level pages and shows interstitial ad every 3 presses
class BackArrowAd {
  static int _count = 0;

  /// Increment the counter and show ad if needed
  /// Returns true if ad was shown, false otherwise
  static Future<bool> handleBackButton({
    required BuildContext context,
    required VoidCallback onBack,
  }) async {
    _count++;
    
    // If count reaches 3, show interstitial ad and reset counter
    if (_count >= 3) {
      _count = 0;
      
      // Show interstitial ad, then navigate back
      await InterstitialAdHelper.showInterstitialAd(
        onAdClosed: () {
          if (context.mounted) {
            onBack();
          }
        },
      );
      return true;
    } else {
      // Just go back without ad
      onBack();
      return false;
    }
  }

  /// Reset the counter (optional, for testing)
  static void reset() {
    _count = 0;
  }

  /// Get current count (for debugging)
  static int get count => _count;
}

/// Rewarded Ad Helper
/// 
/// Manages loading and showing rewarded ads
class RewardedAdHelper {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;

  /// Load a rewarded ad
  static Future<void> loadRewardedAd() async {
    // Don't load if ads are disabled
    if (!SoundVibrationSettings.adsEnabled) {
      return;
    }

    // Don't load if already loading or loaded
    if (_isLoading || _rewardedAd != null) {
      return;
    }

    final adUnitId = AdManager.getRewardedAdId();
    
    // Don't load ad if ad ID is empty (not configured in Remote Config)
    if (adUnitId.isEmpty) {
      debugPrint('Rewarded ad ID is empty, skipping ad load');
      return;
    }

    _isLoading = true;

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          debugPrint('Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _isLoading = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  /// Show rewarded ad and execute callback when ad is closed
  /// onRewarded: callback when user earns reward
  /// onAdClosed: callback when ad is closed (regardless of reward)
  /// Returns true if ad was shown, false if ad was not available
  static Future<bool> showRewardedAd({
    required VoidCallback onRewarded,
    required VoidCallback onAdClosed,
  }) async {
    // Don't show if ads are disabled
    if (!SoundVibrationSettings.adsEnabled) {
      onAdClosed();
      return false;
    }

    // If ad is not loaded, try to load it first
    if (_rewardedAd == null) {
      await loadRewardedAd();
      // Wait a bit for ad to load
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // If still no ad, just execute callback
    if (_rewardedAd == null) {
      onAdClosed();
      return false;
    }

    // Show the ad
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        // Load next ad for future use
        loadRewardedAd();
        // Execute callback after ad is closed
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        // Load next ad for future use
        loadRewardedAd();
        // Execute callback even if ad failed
        onAdClosed();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        onRewarded();
      },
    );
    return true;
  }

  /// Dispose the current rewarded ad
  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}

/// Native Ad Widget
/// 
/// This widget displays a native-style ad that matches the app's design
/// Uses BannerAd styled to look like a native ad for simplicity
class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // Only load ad if ads are enabled
    if (!SoundVibrationSettings.adsEnabled) {
      return;
    }

    // Use banner ad ID since we're using BannerAd with medium rectangle size
    // Native ad IDs require NativeAd class, not BannerAd
    final adUnitId = AdManager.getBannerAdId();
    
    // Don't load ad if ad ID is empty (not configured in Remote Config)
    if (adUnitId.isEmpty) {
      debugPrint('Banner ad ID is empty, skipping native-style ad load');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
          // Only log errors that are not "no ad available" (code 1 is normal when no ads in inventory)
          // Code 1 = ERROR_CODE_NO_FILL - No ad available to show
          if (error.code != 1) {
            debugPrint('Native-style ad failed to load: $error');
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show ad widget if ads are disabled
    if (!SoundVibrationSettings.adsEnabled) {
      return const SizedBox.shrink();
    }

    // Only show ad container if ad is loaded
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    // Return native-style ad in a styled container matching the app design
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D5C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 250,
          width: double.infinity,
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}

/// App Open Ad Helper
/// 
/// Manages loading and showing app open ads
/// App Open Ads are shown when the app is opened or comes to the foreground
class AppOpenAdHelper {
  static AppOpenAd? _appOpenAd;
  static bool _isLoading = false;
  static bool _isShowingAd = false;

  /// Load an app open ad
  static Future<void> loadAppOpenAd() async {
    // Don't load if ads are disabled
    if (!SoundVibrationSettings.adsEnabled) {
      return;
    }

    // Don't load if already loading or loaded
    if (_isLoading || _appOpenAd != null) {
      return;
    }

    final adUnitId = AdManager.getAppOpenAdId();
    
    // Don't load ad if ad ID is empty (not configured in Remote Config)
    if (adUnitId.isEmpty) {
      debugPrint('App Open ad ID is empty, skipping ad load');
      return;
    }

    _isLoading = true;

    await AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isLoading = false;
          debugPrint('App Open ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('App Open ad failed to load: $error');
          _isLoading = false;
          _appOpenAd = null;
        },
      ),
    );
  }

  /// Show app open ad
  /// Returns true if ad was shown, false if ad was not available
  static Future<bool> showAppOpenAd() async {
    // Don't show if ads are disabled
    if (!SoundVibrationSettings.adsEnabled) {
      return false;
    }

    // Don't show if already showing an ad
    if (_isShowingAd) {
      return false;
    }

    // If ad is not loaded, try to load it first
    if (_appOpenAd == null) {
      await loadAppOpenAd();
      // Wait a bit for ad to load
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // If still no ad, return false
    if (_appOpenAd == null) {
      return false;
    }

    _isShowingAd = true;

    // Show the ad
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _isShowingAd = false;
        // Load next ad for future use
        loadAppOpenAd();
        debugPrint('App Open ad dismissed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('App Open ad failed to show: $error');
        ad.dispose();
        _appOpenAd = null;
        _isShowingAd = false;
        // Load next ad for future use
        loadAppOpenAd();
      },
      onAdShowedFullScreenContent: (ad) {
        debugPrint('App Open ad showed');
      },
    );

    await _appOpenAd!.show();
    return true;
  }

  /// Dispose the current app open ad
  static void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isShowingAd = false;
  }
}
