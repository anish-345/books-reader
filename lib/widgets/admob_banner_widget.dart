import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';

class AdMobBannerWidget extends StatefulWidget {
  const AdMobBannerWidget({super.key});

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    // Only show on Android and iOS
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    // Check if SDK is initialized
    if (!AdMobService().isInitialized) {
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
          debugPrint('✅ AdMob Banner: Ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ AdMob Banner: Failed to load');
          debugPrint('   Error: $error');
          ad.dispose();
        },
        onAdOpened: (ad) {
          debugPrint('👆 AdMob Banner: Ad clicked');
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show on Android and iOS
    if (!Platform.isAndroid && !Platform.isIOS) {
      return const SizedBox.shrink();
    }

    // Check if SDK is initialized
    if (!AdMobService().isInitialized) {
      return const SizedBox.shrink();
    }

    // Show banner when loaded
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
