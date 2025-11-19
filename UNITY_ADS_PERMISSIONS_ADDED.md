# Unity Ads Permissions Added ✅

## Changes Made

### AndroidManifest.xml
Added required network permissions for Unity Ads:

```xml
<uses-permission android:name="android.permission.INTERNET" /> <!-- Already present -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" /> <!-- ✅ Added -->
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" /> <!-- ✅ Added -->
```

## Why These Permissions Are Needed

1. **INTERNET** - Required for downloading and displaying ads
2. **ACCESS_NETWORK_STATE** - Unity Ads checks network connectivity before loading ads
3. **ACCESS_WIFI_STATE** - Unity Ads optimizes ad delivery based on connection type

## Next Steps

### 1. Rebuild the App
```bash
flutter clean
flutter pub get
flutter run
```

### 2. Check Logs
When the app starts, look for:
```
Unity Ads: Initializing with Game ID: 5736497 (Test Mode: true)
✅ Unity Ads initialized successfully
✅ Unity Banner: SDK is initialized, showing banner
✅ Unity Banner ad loaded: Banner_Android
```

### 3. Verify Banner Shows
- Open the app
- Go to home screen
- Look at the bottom (above navigation bar)
- You should see a Unity test banner ad

## Troubleshooting

### If Banner Still Doesn't Show

**Check 1: Logs**
Look for error messages:
```
❌ Unity Ads initialization failed: ...
❌ Unity Banner ad failed: ...
```

**Check 2: Internet Connection**
- Ensure device has active internet
- Try on WiFi and mobile data

**Check 3: Complete Rebuild**
```bash
# Clean everything
flutter clean
rm -rf build/

# Rebuild
flutter pub get
flutter run
```

**Check 4: Unity Ads Dashboard**
- Verify Game ID: 5736497 (Android)
- Check if app is approved
- Ensure test mode is enabled

## Expected Behavior

### What You Should See:
1. App starts normally
2. Small loading spinner in banner area (2-5 seconds)
3. Unity test banner ad appears
4. Banner shows Unity logo or test ad content

### Logs You Should See:
```
Unity Ads: Initializing with Game ID: 5736497 (Test Mode: true)
✅ Unity Ads initialized successfully
Unity Banner: Checking initialization...
Unity Banner: Waiting for initialization... (1/10)
Unity Banner: Waiting for initialization... (2/10)
✅ Unity Banner: SDK is initialized, showing banner
Unity Banner: Creating banner with placement: Banner_Android
✅ Unity Banner ad loaded: Banner_Android
```

## Common Issues Fixed

✅ Missing network permissions
✅ Internet permission already present
✅ Clean build performed
✅ Dependencies reinstalled

## If Still Not Working

The issue might be:
1. **Unity Ads plugin version** - Try updating to latest version
2. **Game ID incorrect** - Verify in Unity Ads dashboard
3. **Network blocked** - Check firewall/proxy settings
4. **Android version** - Unity Ads requires Android 4.4+

## Test Mode Enabled

Current configuration:
- Test Mode: **ENABLED** ✅
- Game ID: **5736497** (Android)
- Banner Placement: **Banner_Android**

Test ads will show Unity branding and may be clickable.

## Production Checklist

Before releasing to production:
- [ ] Change `testMode: false` in `unity_ads_service.dart`
- [ ] Verify real ads show correctly
- [ ] Test on multiple devices
- [ ] Check Unity Ads dashboard for impressions
- [ ] Monitor ad performance

## Support

If you continue to have issues:
1. Share the complete logs from app start
2. Check Unity Ads dashboard status
3. Verify internet connectivity
4. Try on a different device/emulator
