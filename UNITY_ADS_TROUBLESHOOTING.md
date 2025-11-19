# Unity Ads Troubleshooting & Status

## Current Status
✅ Unity Ads SDK integrated (v0.3.15)
✅ Test mode enabled with Game ID: 5736465
✅ Banner ads configured for home screen and PDF reader
✅ Interstitial ads configured (every 3rd book open)
✅ Rewarded ads configured (search feature)

## Recent Changes

### Fixed Issues
1. **Initialization Timing**: Added 2-second delay after Unity Ads init to ensure SDK is fully ready
2. **Banner Widget**: Updated to wait for initialization before showing ads
3. **List Banner Widget**: Added initialization check with retry logic
4. **Removed Unused Code**: Cleaned up unused banner loading methods

### Banner Ad Placement
- **Home Screen Bottom**: Banner above navigation bar
- **PDF Reader**: Banner at bottom when controls are visible
- **In Book List**: Banner every 6 items (after 6th, 13th, 20th book, etc.)

## Why Ads Might Not Show

### 1. Initialization Delay
Unity Ads needs time to initialize. The app now waits 2 seconds after initialization before showing banner ads.

**Solution**: Wait a few seconds after app launch for ads to appear.

### 2. Test Ad Fill Rate
Even in test mode, Unity Ads may not always fill banner requests immediately.

**Solution**: 
- Scroll through the book list
- Navigate between tabs
- Wait 10-30 seconds for first ad load

### 3. Multiple Initialization Calls
The logs show Unity Ads initializing multiple times, which can cause issues.

**Solution**: The service now uses singleton pattern to prevent multiple inits.

### 4. Platform View Issues
Banner ads use Android Platform Views which need proper rendering.

**Solution**: 
- Try hot restart (not hot reload)
- Ensure device has good internet connection
- Check if device supports WebView (required for Unity Ads)

## Testing Steps

### 1. Test Banner Ads
```
1. Launch app
2. Wait 5 seconds on home screen
3. Look for banner at bottom (above navigation)
4. Scroll through book list
5. Look for banner after every 6 books
```

### 2. Test Interstitial Ads
```
1. Open a book (1st time - no ad)
2. Go back, open another book (2nd time - no ad)
3. Go back, open another book (3rd time - AD SHOWS!)
```

### 3. Test Rewarded Ads
```
1. Tap search icon in Library tab
2. Rewarded ad should show
3. Watch ad or skip
4. Search opens regardless
```

## Logs to Check

### Success Indicators
```
I/UnityAds: Initializing Unity Services 4.16.3 with game id 5736465 in test mode
I/PlatformViewsController: Hosting view in view hierarchy for platform view
```

### Error Indicators
```
E/UnityAds: Failed to load ad
E/BLASTBufferQueue: Can't acquire next buffer
W/ImageReader_JNI: Unable to acquire a buffer item
```

## Quick Fixes

### If No Ads Show
1. **Hot Restart**: Press 'R' in Flutter terminal or stop and restart app
2. **Clear Cache**: Uninstall app and reinstall
3. **Check Internet**: Ensure device has active internet connection
4. **Wait Longer**: First ad load can take 30-60 seconds

### If Ads Show But Look Wrong
1. **Check Placement ID**: Should be 'Banner_Android' for test ads
2. **Check Game ID**: Should be '5736465' for Android test
3. **Verify Test Mode**: Should be `testMode: true` in init

### If App Crashes
1. **Check Logs**: Look for Unity Ads errors
2. **Update Plugin**: Ensure unity_ads_plugin is latest version
3. **Clean Build**: Run `flutter clean && flutter pub get`

## Expected Behavior

### Banner Ads
- **Size**: 320x50 pixels (standard banner)
- **Position**: Bottom of screen
- **Refresh**: Automatically refreshes every 30-60 seconds
- **Test Content**: Shows "Unity Ads Test" banner

### Interstitial Ads
- **Trigger**: Every 3rd book open
- **Type**: Full-screen video or static ad
- **Duration**: 5-30 seconds
- **Skippable**: After 5 seconds

### Rewarded Ads
- **Trigger**: Search button tap
- **Type**: Video ad
- **Duration**: 15-30 seconds
- **Reward**: Access to search feature

## Production Checklist

Before releasing to production:

- [ ] Replace test Game IDs with production IDs
- [ ] Set `testMode: false` in Unity Ads init
- [ ] Test on multiple devices
- [ ] Verify ads show correctly
- [ ] Check Unity Dashboard for impressions
- [ ] Ensure GDPR compliance (if targeting EU)
- [ ] Add privacy policy mentioning Unity Ads

## Support Resources

- **Unity Ads Dashboard**: https://dashboard.unity3d.com/
- **Unity Ads Documentation**: https://docs.unity.com/ads/
- **Plugin GitHub**: https://github.com/unity-ads/unity-ads-flutter
- **Test Game IDs**: https://docs.unity.com/ads/en-us/manual/TestMode

## Current Implementation Files

- `lib/services/unity_ads_service.dart` - Main ad service
- `lib/widgets/unity_banner_widget.dart` - Banner for bottom navigation
- `lib/widgets/unity_banner_list_widget.dart` - Banner for lists
- `lib/main.dart` - Initialization on app start
- `lib/presentation/screens/home/home_screen_v2.dart` - Banner placement
- `lib/presentation/screens/reader/pdf_reader_screen.dart` - PDF reader banner

---

**Last Updated**: Now
**Status**: Testing in progress
**Next Step**: Wait for ads to load and verify display
