# Unity Ads Troubleshooting - Real Ads Not Showing

## Current Issue

Real ads are not showing in the app. Based on the logs, Unity Ads SDK is not initializing properly.

## Diagnostic Steps

### Step 1: Check Initialization Logs

Run the app and look for these logs in order:

```
🚀 Unity Ads: Starting initialization...
   Game ID: 5975924
   Test Mode: false
   Platform: Android
```

**If you see this:** Unity Ads is attempting to initialize ✅

**If you DON'T see this:** Unity Ads initialization is not being called ❌

### Step 2: Check Initialization Complete

Look for:
```
✅ Unity Ads: Initialization COMPLETE
   SDK is ready to show ads
✅ Unity Ads: Verified initialized = true
```

**If you see this:** Unity Ads initialized successfully ✅

**If you see this instead:**
```
⚠️ Unity Ads: Initialized flag still false after init
   This might indicate initialization callback did not fire
```

**Problem:** The `onComplete` callback is not firing. This could mean:
1. Unity Ads plugin version issue
2. Game ID is incorrect
3. Network connectivity issue
4. Unity Ads server issue

### Step 3: Check for Errors

Look for:
```
❌ Unity Ads: Initialization FAILED
   Error: [error code]
   Message: [error message]
```

**Common Errors:**

| Error | Meaning | Solution |
|-------|---------|----------|
| `INVALID_ARGUMENT` | Game ID is wrong | Check Unity Ads dashboard |
| `INTERNAL_ERROR` | Unity Ads server issue | Wait and retry |
| `NOT_INITIALIZED` | SDK not ready | Increase wait time |
| `NO_FILL` | No ads available | Normal, try again later |
| `NETWORK_ERROR` | No internet | Check connection |

## Possible Causes

### 1. Unity Ads Plugin Version Issue

The `unity_ads_plugin` might have compatibility issues.

**Check current version:**
```yaml
# In pubspec.yaml
unity_ads_plugin: ^0.3.15
```

**Try updating:**
```bash
flutter pub upgrade unity_ads_plugin
flutter clean
flutter pub get
```

### 2. Game ID Not Approved

Your Unity Ads account might need approval.

**Check:**
1. Go to https://dashboard.unity3d.com/
2. Navigate to your game (5975924)
3. Check if status is "Active" or "Pending"
4. Verify ad units are enabled

### 3. Initialization Callback Not Firing

The Unity Ads plugin might not be calling the `onComplete` callback.

**Workaround:** Force initialization flag after delay

```dart
// In unity_ads_service.dart
await UnityAds.init(...);

// Force flag after delay (workaround)
await Future.delayed(const Duration(seconds: 2));
if (!_isInitialized) {
  debugPrint('⚠️ Forcing initialization flag (callback did not fire)');
  _isInitialized = true;
}
```

### 4. Test Mode Confusion

The code says `testMode: false` but logs might show test mode.

**Verify:**
- Check the actual value being passed
- Ensure no caching issues
- Do a clean rebuild

### 5. Platform-Specific Issue

Unity Ads might work differently on Android vs iOS.

**Test:**
- Try on a different Android device
- Try on Android emulator
- Check Android version (Unity Ads requires Android 4.4+)

## Quick Fixes to Try

### Fix 1: Force Initialization Flag

Add this to `unity_ads_service.dart`:

```dart
await UnityAds.init(
  gameId: gameId,
  testMode: testMode,
  onComplete: () {
    _isInitialized = true;
    debugPrint('✅ Unity Ads: Initialization COMPLETE');
  },
  onFailed: (error, message) {
    debugPrint('❌ Unity Ads: Initialization FAILED: $error - $message');
  },
);

// Workaround: Force flag after delay
await Future.delayed(const Duration(seconds: 2));
if (!_isInitialized) {
  debugPrint('⚠️ Unity Ads: Forcing initialization (callback timeout)');
  _isInitialized = true; // Force it
}
```

### Fix 2: Enable Test Mode Temporarily

To verify Unity Ads works at all:

```dart
testMode: true, // Enable test mode temporarily
```

If test ads show but real ads don't:
- Your account might not be approved yet
- Ad fill rate is low in your region
- Ad units need to be configured in dashboard

### Fix 3: Update Plugin

```bash
# Update to latest version
flutter pub upgrade unity_ads_plugin

# Clean everything
flutter clean
rm -rf build/
rm -rf android/build/

# Reinstall
flutter pub get
flutter run
```

### Fix 4: Check Dashboard Configuration

1. Go to Unity Ads Dashboard
2. Verify Game ID: 5975924 (Android)
3. Check Ad Units:
   - Banner_Android (should be active)
   - Interstitial_Android (should be active)
   - Rewarded_Android (should be active)
4. Verify app is approved (not pending)

## Expected Behavior

### When Working Correctly

**Logs should show:**
```
🚀 Unity Ads: Starting initialization...
   Game ID: 5975924
   Test Mode: false
   Platform: Android
✅ Unity Ads: Initialization COMPLETE
   SDK is ready to show ads
✅ Unity Ads: Verified initialized = true
✅ Unity Banner: Ad loaded successfully
```

**App should show:**
- Banner ads at bottom of home screen
- Banner ads in lists (after every 5 items)
- Interstitial ads when exiting reader (every 5 minutes)

### When Not Working

**Logs show:**
```
🚀 Unity Ads: Starting initialization...
   Game ID: 5975924
   Test Mode: false
   Platform: Android
⚠️ Unity Ads: Initialized flag still false after init
   This might indicate initialization callback did not fire
```

**App shows:**
- No banner ads (hidden)
- No interstitial ads
- No errors (just silent failure)

## Next Steps

1. **Run the app** with new logging
2. **Copy all logs** from app start
3. **Look for the specific messages** above
4. **Identify which step fails**
5. **Apply the appropriate fix**

## Contact Unity Support

If none of these fixes work:

1. Go to https://support.unity.com/
2. Create a ticket with:
   - Game ID: 5975924
   - Platform: Android
   - Issue: "Unity Ads SDK not initializing, onComplete callback not firing"
   - Logs: (paste your logs)
   - Plugin version: 0.3.15
   - Flutter version: (your version)

## Temporary Workaround

While debugging, you can force initialization:

```dart
// In unity_ads_service.dart, after UnityAds.init()
await Future.delayed(const Duration(seconds: 2));
_isInitialized = true; // Force it for testing
debugPrint('⚠️ Forced initialization for testing');
```

This will allow banners to show (if Unity Ads is actually working but just not calling the callback).
