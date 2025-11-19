# AdMob Quick Start Guide

## Current Status
✅ Unity Ads has been completely replaced with Google AdMob
✅ App is using AdMob test ads (safe for development)
✅ All code compiles without errors

## What's Working Now

### Test Ads Active
The app currently shows **test ads** from Google AdMob:
- Banner ads in home screen and readers
- Interstitial ads when exiting readers (every 5 minutes)
- All ads are clearly labeled as "Test Ad"

### Where Ads Appear
1. **Home Screen** - Banner at bottom
2. **Library/Recent/Bookmarks** - Banners every 5 items
3. **PDF/EPUB Readers** - Banner at bottom (when controls hidden)
4. **Reader Exit** - Interstitial ad (time-controlled)

## To Use Your Own Ads (3 Steps)

### Step 1: Get AdMob Account
1. Go to https://admob.google.com/
2. Sign in and create an app
3. Create 3 ad units: Banner, Interstitial, Rewarded

### Step 2: Update App ID
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Replace this line -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_ACTUAL_APP_ID_HERE"/>
```

### Step 3: Update Ad Unit IDs
Edit `lib/services/admob_service.dart`:
```dart
// Replace these test IDs with your actual Ad Unit IDs
static String get bannerAdUnitId => Platform.isAndroid
    ? 'YOUR_BANNER_ID_HERE'
    : 'YOUR_IOS_BANNER_ID_HERE';

static String get interstitialAdUnitId => Platform.isAndroid
    ? 'YOUR_INTERSTITIAL_ID_HERE'
    : 'YOUR_IOS_INTERSTITIAL_ID_HERE';
```

## Testing

### Test Current Setup
```bash
flutter run
```
You should see test ads with "Test Ad" label.

### Build Release APK
```bash
flutter build apk --release
```

## Important Warnings

⚠️ **Before Publishing:**
- Replace ALL test IDs with your actual AdMob IDs
- Test ads in production violate AdMob policies
- Can result in account suspension

⚠️ **During Development:**
- Use test ads only
- Never click your own real ads
- Monitor AdMob dashboard for issues

## Need Help?

See `ADMOB_MIGRATION.md` for detailed documentation.

## Files Changed

**New Files:**
- `lib/services/admob_service.dart`
- `lib/widgets/admob_banner_widget.dart`

**Updated Files:**
- `lib/main.dart`
- `lib/services/ad_frequency_service.dart`
- All screen files (home, readers)
- `android/app/src/main/AndroidManifest.xml`

**Removed Files:**
- `lib/services/unity_ads_service.dart`
- `lib/widgets/unity_banner_widget.dart`

## Next Steps

1. ✅ Migration complete
2. ⏳ Create AdMob account
3. ⏳ Get your Ad Unit IDs
4. ⏳ Replace test IDs
5. ⏳ Test with real ads
6. ⏳ Publish to Play Store
