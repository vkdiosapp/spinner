import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_manager.dart';
import 'sound_vibration_settings.dart';

/// Helper class for managing AdMob banner ads
class AdHelper {
  /// Get the appropriate banner ad unit ID based on platform
  static String getBannerAdUnitId() {
    if (AdManager.useTestAds) {
      return AdManager.testBannerAdId;
    }
    
    if (Platform.isAndroid) {
      return AdManager.androidBannerAdId;
    } else if (Platform.isIOS) {
      return AdManager.iosBannerAdId;
    }
    return AdManager.testBannerAdId; // Default to test ad
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

    _bannerAd = BannerAd(
      adUnitId: AdHelper.getBannerAdUnitId(),
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

    _isLoading = true;

    final adUnitId = AdManager.useTestAds
        ? AdManager.testInterstitialAdId
        : (Platform.isAndroid
            ? AdManager.testAndroidInterstitialAdId // TODO: Replace with actual Android interstitial ID when available
            : AdManager.testIosInterstitialAdId); // TODO: Replace with actual iOS interstitial ID when available

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

    _isLoading = true;

    final adUnitId = AdManager.useTestAds
        ? AdManager.testRewardedAdId
        : (Platform.isAndroid
            ? AdManager.testAndroidRewardedAdId // TODO: Replace with actual Android rewarded ID when available
            : AdManager.testIosRewardedAdId); // TODO: Replace with actual iOS rewarded ID when available

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

