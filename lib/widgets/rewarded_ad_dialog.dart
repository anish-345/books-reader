import 'dart:io';
import 'package:flutter/material.dart';
import '../services/startapp_ad_service.dart';

class RewardedAdDialog {
  static Future<bool> showForFeature({
    required BuildContext context,
    required String featureName,
    required VoidCallback onAdWatched,
  }) async {
    if (!Platform.isAndroid) {
      // On non-Android platforms, just allow the feature
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.video_library, color: Colors.blue[600]),
            const SizedBox(width: 8),
            const Text('Watch Ad'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Watch a short video to use $featureName',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This helps keep the app free!',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context, true);
              await _showRewardedAd(context, onAdWatched);
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Watch Video'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  static Future<void> _showRewardedAd(
    BuildContext context,
    VoidCallback onAdWatched,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading ad...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final adService = StartAppAdService();

      // Ensure SDK is initialized
      if (!adService.isInitialized) {
        await adService.initialize();
      }

      // Load rewarded video
      await adService.loadRewardedVideoAd();

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show the rewarded video
      await adService.showRewardedVideoAd(
        onRewardEarned: () {
          onAdWatched();
        },
      );

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Thanks for watching! Feature unlocked.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.pop(context);

        // Show error and allow feature anyway
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad not available. Feature unlocked anyway!'),
            backgroundColor: Colors.orange,
          ),
        );
        onAdWatched();
      }
    }
  }

  // Alternative: Simple version without dialog
  static Future<void> showQuick({
    required BuildContext context,
    required VoidCallback onAdWatched,
  }) async {
    if (!Platform.isAndroid) {
      onAdWatched();
      return;
    }

    try {
      final adService = StartAppAdService();

      if (!adService.isInitialized) {
        await adService.initialize();
      }

      await adService.loadRewardedVideoAd();
      await adService.showRewardedVideoAd(onRewardEarned: onAdWatched);
    } catch (e) {
      onAdWatched(); // Allow feature anyway if ad fails
    }
  }
}
