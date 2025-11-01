import 'dart:io';
import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';

class StartAppAdService {
  static final StartAppAdService _instance = StartAppAdService._internal();
  factory StartAppAdService() => _instance;
  StartAppAdService._internal();

  var startAppSdk = StartAppSdk();
  StartAppBannerAd? _bannerAd;
  StartAppInterstitialAd? _interstitialAd;
  StartAppRewardedVideoAd? _rewardedVideoAd;
  StartAppNativeAd? _nativeAd;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (!Platform.isAndroid || _isInitialized) return;
    try {
      await startAppSdk.setTestAdsEnabled(false);
      _isInitialized = true;
    } catch (e) {
      // Silent fail
    }
  }

  Future<StartAppBannerAd?> loadBannerAd() async {
    if (!Platform.isAndroid || !_isInitialized) return null;
    try {
      _bannerAd = await startAppSdk.loadBannerAd(
        StartAppBannerType.BANNER,
        onAdClicked: () {},
      );
      return _bannerAd;
    } catch (e) {
      return null;
    }
  }

  Future<void> loadInterstitialAd() async {
    if (!Platform.isAndroid || !_isInitialized) return;
    try {
      _interstitialAd = await startAppSdk.loadInterstitialAd(
        onAdNotDisplayed: () {
          _interstitialAd?.dispose();
          _interstitialAd = null;
        },
        onAdHidden: () {
          _interstitialAd?.dispose();
          _interstitialAd = null;
        },
        onAdDisplayed: () {},
        onAdClicked: () {},
      );
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> showInterstitialAd() async {
    if (!Platform.isAndroid || !_isInitialized) return;
    try {
      if (_interstitialAd != null) {
        await _interstitialAd!.show();
        loadInterstitialAd();
      } else {
        await loadInterstitialAd();
        _interstitialAd?.show();
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<StartAppNativeAd?> loadNativeAd() async {
    if (!Platform.isAndroid || !_isInitialized) return null;
    try {
      _nativeAd = await startAppSdk.loadNativeAd(
        onAdImpression: () {},
        onAdClicked: () {},
      );
      return _nativeAd;
    } catch (e) {
      return null;
    }
  }

  Future<void> loadRewardedVideoAd() async {
    if (!Platform.isAndroid || !_isInitialized) return;
    try {
      _rewardedVideoAd = await startAppSdk.loadRewardedVideoAd(
        onAdNotDisplayed: () {
          _rewardedVideoAd?.dispose();
          _rewardedVideoAd = null;
        },
        onAdHidden: () {
          _rewardedVideoAd?.dispose();
          _rewardedVideoAd = null;
        },
        onAdDisplayed: () {},
        onAdClicked: () {},
        onVideoCompleted: () {},
      );
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> showRewardedVideoAd({Function? onRewardEarned}) async {
    if (!Platform.isAndroid || !_isInitialized) return;
    try {
      if (_rewardedVideoAd != null) {
        await _rewardedVideoAd!.show();
        onRewardEarned?.call();
        loadRewardedVideoAd();
      } else {
        await loadRewardedVideoAd();
      }
    } catch (e) {
      // Silent fail
    }
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedVideoAd?.dispose();
    _nativeAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedVideoAd = null;
    _nativeAd = null;
  }
}
