# Unity Ads Test Guide

## ✅ Test Mode Configuration

Test mode is **ENABLED** - you will see test ads when running the app.

### Current Configuration

```dart
testMode: true  // ✅ Test ads enabled
```

## 🎯 Where to See Test Ads

### 1. Banner Ad (Home Screen)
- **Location**: Bottom of home screen, above navigation bar
- **Type**: 320x50 banner
- **Visibility**: Shows on all tabs (Library, Recent, Bookmarks)

### 2. Interstitial Ad (Coming Soon)
- Can be added to PDF/EPUB reader exit
- Full-screen video ad

### 3. Rewarded Ad (Coming Soon)
- Can be added for premium features
- User watches video to unlock features

## 📱 How to Test

### Step 1: Run the App
```bash
flutter run
```

### Step 2: Check Logs
Look for these messages in the console:

```
✅ Unity Ads initialized successfully
✅ Unity Banner ad loaded: Banner_Android
```

### Step 3: View Banner Ad
1. Open the app
2. Go to home screen
3. Look at the bottom (above navigation bar)
4. You should see a test banner ad

## 🔍 Troubleshooting

### Banner Not Showing?

**Check 1: Initialization**
```
Look for: "Unity Ads initialized successfully"
```

**Check 2: Banner Load**
```
Look for: "Unity Banner ad loaded: Banner_Android"
```

**Check 3: Errors**
```
Look for: "Unity Banner ad failed: ..."
```

### Common Issues

1. **"SDK not initialized"**
   - Wait a few seconds after app starts
   - Unity Ads takes time to initialize

2. **"No fill"**
   - Normal in test mode sometimes
   - Try restarting the app

3. **Banner shows but is blank**
   - This is normal for test ads
   - Test ads may show placeholder content

## 🎨 Banner Appearance

Test banners will show:
- Unity logo
- "Test Ad" text
- Gray/white background
- May be clickable (opens Unity test page)

## 📊 Test Ad IDs

Currently using:
- **Android Game ID**: 5736497
- **iOS Game ID**: 5736496
- **Banner Placement**: Banner_Android / Banner_iOS

## 🚀 Next Steps

### To Add More Ads:

1. **Interstitial Ads** (Full-screen)
   - Add to PDF reader exit
   - Add to EPUB reader exit

2. **Rewarded Ads** (Watch video for reward)
   - Add to search feature
   - Add to bookmark export

### To Switch to Production:

Change in `lib/services/unity_ads_service.dart`:
```dart
testMode: false  // Production ads
```

## 📝 Notes

- Test ads don't generate revenue
- Test ads may not always fill
- Test ads help verify integration
- Switch to production mode before release

## 🔗 Useful Links

- [Unity Ads Dashboard](https://dashboard.unity3d.com/)
- [Unity Ads Documentation](https://docs.unity.com/ads/)
- [Flutter Unity Ads Plugin](https://pub.dev/packages/unity_ads_plugin)
