import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Ad Unit IDs (using test IDs - replace with your actual IDs from AdMob console)
  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // Test Banner
      : 'ca-app-pub-3940256099942544/2934735716'; // Test Banner iOS

  static String get interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Test Interstitial
      : 'ca-app-pub-3940256099942544/4411468910'; // Test Interstitial iOS

  static String get rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917' // Test Rewarded
      : 'ca-app-pub-3940256099942544/1712485313'; // Test Rewarded iOS

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ AdMob: Already initialized');
      return;
    }

    try {
      debugPrint('🚀 AdMob: Starting initialization...');
      debugPrint('   Platform: ${Platform.isAndroid ? "Android" : "iOS"}');

      await MobileAds.instance.initialize();

      _isInitialized = true;
      debugPrint('✅ AdMob: Initialization COMPLETE');
      debugPrint('   SDK is ready to show ads');

      // Preload first interstitial ad
      loadInterstitialAd();
    } catch (e, stackTrace) {
      debugPrint('❌ AdMob: Exception during initialization');
      debugPrint('   Error: $e');
      debugPrint('   Stack: $stackTrace');
    }
  }

  Future<void> loadInterstitialAd() async {
    if (!_isInitialized) return;

    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            debugPrint('✅ AdMob: Interstitial ad loaded');

            _interstitialAd!.fullScreenContentCallback =
                FullScreenContentCallback(
                  onAdDismissedFullScreenContent: (ad) {
                    debugPrint('AdMob: Interstitial ad dismissed');
                    ad.dispose();
                    _interstitialAd = null;
                    // Preload next ad
                    loadInterstitialAd();
                  },
                  onAdFailedToShowFullScreenContent: (ad, error) {
                    debugPrint('AdMob: Interstitial ad failed to show: $error');
                    ad.dispose();
                    _interstitialAd = null;
                  },
                );
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ AdMob: Interstitial ad failed to load: $error');
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading AdMob Interstitial ad: $e');
    }
  }

  Future<void> showInterstitialAd() async {
    if (!_isInitialized) return;

    if (_interstitialAd == null) {
      debugPrint('⚠️ AdMob: Interstitial ad not ready yet');
      loadInterstitialAd(); // Try to load for next time
      return;
    }

    try {
      await _interstitialAd!.show();
      _interstitialAd = null;
    } catch (e) {
      debugPrint('Error showing AdMob Interstitial ad: $e');
    }
  }

  Future<void> showRewardedAd({required Function() onRewardEarned}) async {
    if (!_isInitialized) return;

    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            debugPrint('✅ AdMob: Rewarded ad loaded');

            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('AdMob: Rewarded ad dismissed');
                ad.dispose();
                _rewardedAd = null;
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('AdMob: Rewarded ad failed to show: $error');
                ad.dispose();
                _rewardedAd = null;
              },
            );

            // Show the ad
            _rewardedAd!.show(
              onUserEarnedReward: (ad, reward) {
                debugPrint(
                  'AdMob: User earned reward: ${reward.amount} ${reward.type}',
                );
                onRewardEarned();
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ AdMob: Rewarded ad failed to load: $error');
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('Error showing AdMob Rewarded ad: $e');
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
