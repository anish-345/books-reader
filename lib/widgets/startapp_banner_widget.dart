import 'dart:io';
import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';
import '../services/startapp_ad_service.dart';

class StartAppBannerWidget extends StatefulWidget {
  const StartAppBannerWidget({super.key});

  @override
  State<StartAppBannerWidget> createState() => _StartAppBannerWidgetState();
}

class _StartAppBannerWidgetState extends State<StartAppBannerWidget> {
  StartAppBannerAd? _bannerAd;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    if (!Platform.isAndroid) {
      setState(() => _isLoading = false);
      return;
    }

    final adService = StartAppAdService();
    if (!adService.isInitialized) {
      await adService.initialize();
    }

    final banner = await adService.loadBannerAd();
    if (mounted) {
      setState(() {
        _bannerAd = banner;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return Container(
        height: 50,
        color: Colors.grey[200],
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(height: 50, child: StartAppBanner(_bannerAd!));
  }

  @override
  void dispose() {
    _bannerAd = null;
    super.dispose();
  }
}
