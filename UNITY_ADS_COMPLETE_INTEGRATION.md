# Unity Ads Complete Integration ✅

## Summary

Unity Ads has been fully integrated into the Book Reader app with banner ads and interstitial ads.

## Ad Placements

### 1. Banner Ads 📱

#### Home Screen - Bottom Navigation
- **Location**: Above bottom navigation bar
- **Visibility**: Always visible on all tabs
- **Type**: 320x50 banner

#### Library Tab - In List
- **Location**: After every 5 books in the list
- **Type**: 320x50 banner
- **Behavior**: Scrolls with the list

#### Recent Tab - In List
- **Location**: After every 5 books in the list
- **Type**: 320x50 banner
- **Behavior**: Scrolls with the list

#### Bookmarks Tab - In List
- **Location**: After every 5 bookmarks in the list
- **Type**: 320x50 banner
- **Behavior**: Scrolls with the list

#### Search Results - In List
- **Location**: After every 5 results (both book search and bookmark search)
- **Type**: 320x50 banner
- **Behavior**: Scrolls with results

#### PDF Reader
- **Location**: Bottom of screen
- **Visibility**: Only shows when controls are hidden (clean reading mode)
- **Type**: 320x50 banner

#### EPUB Reader
- **Location**: Bottom of screen
- **Visibility**: Only shows when controls are hidden (clean reading mode)
- **Type**: 320x50 banner

### 2. Interstitial Ads 📺

#### Book Opens
- **Trigger**: After every 3 books opened
- **Type**: Full-screen video ad
- **Timing**: Shows when opening a book (PDF or EPUB)
- **Counter**: Persistent across app sessions
- **Behavior**: 
  - Opens book 1: No ad
  - Opens book 2: No ad
  - Opens book 3: Shows interstitial ad, counter resets
  - Opens book 4: No ad
  - Opens book 5: No ad
  - Opens book 6: Shows interstitial ad, counter resets
  - And so on...

## Technical Implementation

### Services Created

1. **UnityAdsService** (`lib/services/unity_ads_service.dart`)
   - Singleton service for Unity Ads SDK
   - Handles initialization
   - Manages banner, interstitial, and rewarded ads
   - Test mode enabled

2. **AdFrequencyService** (`lib/services/ad_frequency_service.dart`)
   - Tracks book open count
   - Shows interstitial ads after every 3 books
   - Persists counter using SharedPreferences
   - Automatic counter reset after showing ad

### Widgets Created

1. **UnityBannerWidget** (`lib/widgets/unity_banner_widget.dart`)
   - Reusable banner ad widget
   - Waits for SDK initialization
   - Shows loading state
   - Handles errors gracefully
   - Android only (Unity Ads works best on Android)

### Configuration

#### Game IDs
- **Android**: 5736497
- **iOS**: 5736496

#### Ad Unit IDs
- **Banner**: Banner_Android / Banner_iOS
- **Interstitial**: Interstitial_Android / Interstitial_iOS
- **Rewarded**: Rewarded_Android / Rewarded_iOS

#### Test Mode
- **Status**: ENABLED ✅
- **Location**: `lib/services/unity_ads_service.dart` line 34
- **Value**: `testMode: true`

## Permissions Added

### AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```

## User Experience

### Banner Ads
- **Non-intrusive**: Placed at natural break points
- **Consistent**: Same size and style throughout app
- **Clean reading**: Hidden when reading (controls hidden)
- **Smooth scrolling**: Integrated into lists naturally

### Interstitial Ads
- **Fair frequency**: Only after every 3 books
- **Predictable**: Users know when to expect ads
- **Persistent tracking**: Counter survives app restarts
- **Quick loading**: Pre-loaded for smooth experience

## Testing

### How to Test Banner Ads
1. Run the app
2. Go to home screen
3. Look at bottom (above navigation) - should see banner
4. Scroll through Library tab - see banners after every 5 books
5. Open a book and tap center to hide controls - see banner at bottom

### How to Test Interstitial Ads
1. Run the app
2. Open any book (PDF or EPUB) - no ad (count: 1)
3. Go back and open another book - no ad (count: 2)
4. Go back and open a third book - **interstitial ad shows!** (count resets to 0)
5. Open another book - no ad (count: 1)
6. Continue pattern...

### Expected Logs

#### Initialization
```
Unity Ads: Initializing with Game ID: 5736497 (Test Mode: true)
✅ Unity Ads initialized successfully
AdFrequency: Initialized with count: 0
```

#### Banner Ads
```
Unity Banner: Checking initialization...
✅ Unity Banner: SDK is initialized, showing banner
Unity Banner: Creating banner with placement: Banner_Android
✅ Unity Banner ad loaded: Banner_Android
```

#### Interstitial Ads
```
AdFrequency: Book opened, count: 1
AdFrequency: 2 more books until next ad

AdFrequency: Book opened, count: 2
AdFrequency: 1 more books until next ad

AdFrequency: Book opened, count: 3
AdFrequency: Showing interstitial ad (count: 3)
✅ Unity Interstitial ad loaded: Interstitial_Android
✅ Unity Interstitial ad started: Interstitial_Android
✅ Unity Interstitial ad completed: Interstitial_Android
AdFrequency: Counter reset to 0
```

## Revenue Optimization

### Current Settings
- **Banner frequency**: Every 5 items in lists
- **Interstitial frequency**: Every 3 books opened
- **Test mode**: Enabled (no revenue)

### For Production
1. Change `testMode: false` in `unity_ads_service.dart`
2. Test with real ads
3. Monitor Unity Ads dashboard
4. Adjust frequencies based on:
   - User feedback
   - Revenue data
   - Retention metrics

### Recommended Adjustments
- **If users complain**: Reduce frequency (every 7 books, every 4 opens)
- **If revenue is low**: Increase frequency (every 3 books, every 2 opens)
- **If retention drops**: Reduce interstitial frequency

## Files Modified

### New Files
- `lib/services/unity_ads_service.dart`
- `lib/services/ad_frequency_service.dart`
- `lib/widgets/unity_banner_widget.dart`

### Modified Files
- `lib/main.dart` - Initialize services
- `lib/presentation/screens/home/home_screen_v2.dart` - Banner ads in lists
- `lib/presentation/screens/reader/pdf_reader_screen.dart` - Banner + tracking
- `lib/presentation/screens/reader/epub_reader_v2.dart` - Banner + tracking
- `android/app/src/main/AndroidManifest.xml` - Permissions
- `pubspec.yaml` - Unity Ads dependency

## Production Checklist

Before releasing to production:

- [ ] Change `testMode: false` in `unity_ads_service.dart`
- [ ] Test real ads on multiple devices
- [ ] Verify Unity Ads dashboard shows impressions
- [ ] Monitor user feedback for ad frequency
- [ ] Check app performance with ads
- [ ] Test on different Android versions
- [ ] Verify ads don't block critical functionality
- [ ] Test with poor network conditions
- [ ] Ensure ads respect user privacy settings

## Troubleshooting

### Banner Ads Not Showing
1. Check logs for initialization success
2. Verify internet connection
3. Wait 5 seconds after app start
4. Check Unity Ads dashboard for app approval

### Interstitial Ads Not Showing
1. Check logs for "AdFrequency: Showing interstitial ad"
2. Verify you've opened 3 books
3. Check Unity Ads initialization
4. Look for error messages in logs

### Ads Showing Too Often
1. Adjust frequency in `ad_frequency_service.dart` (change `_interstitialFrequency`)
2. Adjust banner frequency in list builders (change `% 6` to `% 8` for every 7 items)

### Ads Not Loading
1. Check internet connection
2. Verify Game ID is correct
3. Check Unity Ads dashboard status
4. Try `flutter clean` and rebuild

## Support

- **Unity Ads Dashboard**: https://dashboard.unity3d.com/
- **Unity Ads Documentation**: https://docs.unity.com/ads/
- **Plugin Documentation**: https://pub.dev/packages/unity_ads_plugin

## Notes

- Test ads show Unity branding
- Test ads don't generate revenue
- Real ads require production mode
- Ad fill rate varies by region
- First ad load may be slow
- Subsequent ads load faster
