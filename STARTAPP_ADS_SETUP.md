# StartApp Ads Integration Guide

This document explains how StartApp ads have been integrated into the Book Reader app for Android only.

## What's Been Added

### 1. Dependencies
- **pubspec.yaml**: Added `startapp_sdk: ^0.3.1` dependency
- **android/app/build.gradle.kts**: Added StartApp SDK implementation

### 2. Android Configuration
- **AndroidManifest.xml**: 
  - Added required permissions (INTERNET, ACCESS_NETWORK_STATE, ACCESS_WIFI_STATE)
  - Added StartApp App ID metadata (needs to be configured)

### 3. Ad Service
- **lib/services/startapp_ad_service.dart**: 
  - Singleton service to manage all ad operations
  - Supports Banner, Interstitial, and Rewarded Video ads
  - Android-only implementation (automatically skips on other platforms)

### 4. Banner Widget
- **lib/widgets/startapp_banner_widget.dart**: 
  - Reusable widget for displaying banner ads
  - Shows loading indicator while ad loads
  - Automatically handles Android-only display

### 5. Integration Points

#### Home Screen
- Banner ad displayed above bottom navigation bar
- Visible on all tabs (Library, Recent, Bookmarks)

#### PDF Reader
- Interstitial ad preloaded when reader opens
- Displayed when user exits the reader

#### EPUB Reader
- Interstitial ad preloaded when reader opens
- Displayed when user exits the reader

## Setup Instructions

### 1. Get Your StartApp App ID
1. Sign up at [StartApp Dashboard](https://portal.startapp.com/)
2. Create a new app
3. Get your App ID

### 2. Configure App ID
Edit `android/app/src/main/AndroidManifest.xml` and replace `YOUR_APP_ID_HERE` with your actual App ID:

```xml
<meta-data
    android:name="com.startapp.sdk.APPLICATION_ID"
    android:value="YOUR_ACTUAL_APP_ID" />
```

### 3. Test vs Production Mode
In `lib/services/startapp_ad_service.dart`, line 28:

```dart
// Set to true for testing, false for production
_startAppSdk!.setTestAdsEnabled(true);
```

Change to `false` before releasing to production.

### 4. Build and Run
```bash
flutter pub get
flutter build apk --release
```

## Ad Types Implemented

### Banner Ads
- Displayed at the bottom of the home screen
- Always visible while browsing
- Non-intrusive, standard banner size

### Interstitial Ads
- Full-screen ads
- Shown when exiting PDF/EPUB readers
- Preloaded for smooth display

### Rewarded Video Ads (Available but not integrated)
- Can be added to unlock premium features
- User watches video to earn rewards
- Use `StartAppAdService().showRewardedVideoAd()` to implement

## Customization

### Change Ad Frequency
To show interstitial ads less frequently, add a counter in the reader screens:

```dart
static int _readSessionCount = 0;

@override
void dispose() {
  _readSessionCount++;
  
  // Show ad every 3rd session
  if (Platform.isAndroid && _readSessionCount % 3 == 0) {
    StartAppAdService().showInterstitialAd();
  }
  
  super.dispose();
}
```

### Add Banner to Other Screens
Simply add the widget to any screen:

```dart
import '../../../widgets/startapp_banner_widget.dart';

// In your build method:
Column(
  children: [
    Expanded(child: YourContent()),
    const StartAppBannerWidget(),
  ],
)
```

### Remove Ads from Specific Screens
Remove the `StartAppBannerWidget()` or the interstitial ad calls from the screens where you don't want ads.

## Troubleshooting

### Ads Not Showing
1. Check that you've set your App ID correctly
2. Ensure test mode is enabled during development
3. Check logcat for StartApp SDK messages: `adb logcat | grep StartApp`
4. Verify internet connection is available

### Build Errors
1. Run `flutter clean`
2. Run `flutter pub get`
3. Rebuild the app

### iOS Compatibility
The implementation automatically skips ad loading on iOS. No ads will be shown on iOS devices.

## Revenue Optimization Tips

1. **Banner Placement**: Keep banners visible but not intrusive
2. **Interstitial Timing**: Show at natural break points (exiting reader is ideal)
3. **Frequency Capping**: Don't show interstitials too often (every 3-5 sessions)
4. **User Experience**: Balance monetization with user satisfaction

## Support

For StartApp SDK issues, visit:
- [StartApp Documentation](https://support.start.io/hc/en-us)
- [StartApp Flutter Plugin](https://pub.dev/packages/startapp_sdk)
