import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admob_service.dart';

class AdFrequencyService {
  static final AdFrequencyService _instance = AdFrequencyService._internal();
  factory AdFrequencyService() => _instance;
  AdFrequencyService._internal();

  static const String _lastInterstitialTimeKey = 'last_interstitial_time';
  static const int _minMinutesBetweenAds =
      5; // Minimum 5 minutes between interstitial ads

  DateTime? _lastInterstitialTime;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTimeMillis = prefs.getInt(_lastInterstitialTimeKey);

    if (lastTimeMillis != null) {
      _lastInterstitialTime = DateTime.fromMillisecondsSinceEpoch(
        lastTimeMillis,
      );
      debugPrint(
        'AdFrequency: Last interstitial shown at: $_lastInterstitialTime',
      );
    } else {
      debugPrint('AdFrequency: No previous interstitial ad shown');
    }
  }

  /// Call this when user exits a reader (after reading)
  Future<void> onReaderExit() async {
    if (!_shouldShowInterstitial()) {
      final minutesSinceLastAd = _getMinutesSinceLastAd();
      if (minutesSinceLastAd != null) {
        final minutesRemaining = _minMinutesBetweenAds - minutesSinceLastAd;
        debugPrint(
          'AdFrequency: Too soon for ad. Wait $minutesRemaining more minutes',
        );
      }
      return;
    }

    debugPrint('AdFrequency: Showing interstitial ad on reader exit');
    await _showInterstitialAd();
  }

  bool _shouldShowInterstitial() {
    if (_lastInterstitialTime == null) {
      // First time - show ad
      return true;
    }

    final minutesSinceLastAd = _getMinutesSinceLastAd();
    if (minutesSinceLastAd == null) return true;

    // Only show if at least X minutes have passed
    return minutesSinceLastAd >= _minMinutesBetweenAds;
  }

  int? _getMinutesSinceLastAd() {
    if (_lastInterstitialTime == null) return null;

    final now = DateTime.now();
    final difference = now.difference(_lastInterstitialTime!);
    return difference.inMinutes;
  }

  Future<void> _showInterstitialAd() async {
    try {
      // Show interstitial ad
      await AdMobService().showInterstitialAd();

      // Update last shown time
      _lastInterstitialTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastInterstitialTimeKey,
        _lastInterstitialTime!.millisecondsSinceEpoch,
      );

      debugPrint(
        'AdFrequency: Interstitial shown, next available in $_minMinutesBetweenAds minutes',
      );
    } catch (e) {
      debugPrint('AdFrequency: Error showing interstitial ad: $e');
    }
  }

  // For testing - reset timer
  Future<void> resetTimer() async {
    _lastInterstitialTime = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastInterstitialTimeKey);
    debugPrint('AdFrequency: Timer manually reset');
  }

  // Get time until next ad (for debugging)
  String getTimeUntilNextAd() {
    if (_lastInterstitialTime == null) {
      return 'Ad available now';
    }

    final minutesSinceLastAd = _getMinutesSinceLastAd();
    if (minutesSinceLastAd == null) return 'Ad available now';

    if (minutesSinceLastAd >= _minMinutesBetweenAds) {
      return 'Ad available now';
    }

    final minutesRemaining = _minMinutesBetweenAds - minutesSinceLastAd;
    return 'Ad available in $minutesRemaining minutes';
  }
}
