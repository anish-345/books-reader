import 'dart:io';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../services/unity_ads_service.dart';

class UnityBannerWidget extends StatefulWidget {
  const UnityBannerWidget({super.key});

  @override
  State<UnityBannerWidget> createState() => _UnityBannerWidgetState();
}

class _UnityBannerWidgetState extends State<UnityBannerWidget> {
  bool _adLoaded = false;

  @override
  Widget build(BuildContext context) {
    // Only show on Android
    if (!Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    // Check if SDK is initialized
    final isInitialized = UnityAdsService().isInitialized;

    if (!isInitialized) {
      // SDK not ready yet - hide banner (no loading state)
      return const SizedBox.shrink();
    }

    // SDK is ready - show banner (will animate in when loaded)
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _adLoaded ? 60 : 0,
      child: UnityBannerAd(
        placementId: UnityAdsService.bannerAdUnitId,
        onLoad: (placementId) {
          if (mounted) {
            setState(() {
              _adLoaded = true;
            });
          }
          debugPrint('✅ Unity Banner: Ad loaded successfully');
        },
        onClick: (placementId) {
          debugPrint('👆 Unity Banner: Ad clicked');
        },
        onFailed: (placementId, error, message) {
          debugPrint('❌ Unity Banner: Failed to load');
          debugPrint('   Placement: $placementId');
          debugPrint('   Error: $error');
          debugPrint('   Message: $message');
        },
      ),
    );
  }
}
