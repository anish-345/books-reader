# Unity Ads Debug Guide

## What to Check in Logs

When you run the app, look for these messages in order:

### 1. Initialization Start
```
Unity Ads: Initializing with Game ID: 5736497 (Test Mode: true)
```

### 2. Initialization Complete
```
✅ Unity Ads initialized successfully
```

### 3. Banner Check
```
Unity Banner: Checking initialization...
Unity Banner: Waiting for initialization... (1/10)
Unity Banner: Waiting for initialization... (2/10)
...
✅ Unity Banner: SDK is initialized, showing banner
```

### 4. Banner Load
```
Unity Banner: Creating banner with placement: Banner_Android
✅ Unity Banner ad loaded: Banner_Android
```

## Common Issues

### Issue 1: "Loading ad..." Shows Forever

**Symptoms:**
- Circular progress indicator shows
- Never changes to actual ad

**Possible Causes:**
1. Unity Ads not initializing
2. Wrong Game ID
3. Network issue

**Check Logs For:**
```
❌ Unity Ads initialization failed: ...
```

**Solution:**
- Check internet connection
- Verify Game ID is correct
- Check if Unity Ads dashboard shows your app

### Issue 2: "SDK not initialized after 5 seconds"

**Symptoms:**
- Log shows timeout message
- Banner never appears

**Possible Causes:**
1. Unity Ads plugin not properly installed
2. Android configuration missing
3. Network blocked

**Solution:**
```bash
# Reinstall dependencies
flutter clean
flutter pub get
flutter run
```

### Issue 3: Banner Shows But Is Blank

**Symptoms:**
- Gray box appears
- No ad content inside

**Possible Causes:**
1. Test ads not filling
2. Placement ID incorrect
3. Ad not loaded yet

**Check Logs For:**
```
❌ Unity Banner ad failed: ...
```

## Manual Test Steps

### Step 1: Check Initialization
Run the app and immediately check logs for:
```
Unity Ads: Initializing with Game ID: 5736497
```

If you DON'T see this, Unity Ads is not being initialized at all.

### Step 2: Wait for Success
Within 2-3 seconds, you should see:
```
✅ Unity Ads initialized successfully
```

If you see this, initialization worked!

### Step 3: Check Banner
After initialization, you should see:
```
✅ Unity Banner: SDK is initialized, showing banner
Unity Banner: Creating banner with placement: Banner_Android
```

### Step 4: Confirm Load
Finally, you should see:
```
✅ Unity Banner ad loaded: Banner_Android
```

If you see this, the banner ad loaded successfully!

## What Each Log Means

| Log Message | Meaning | Next Step |
|------------|---------|-----------|
| `Unity Ads: Initializing...` | Starting initialization | Wait 2-3 seconds |
| `✅ Unity Ads initialized successfully` | SDK ready | Banner should load |
| `❌ Unity Ads initialization failed` | SDK failed | Check Game ID & network |
| `Unity Banner: Waiting for initialization...` | Banner waiting for SDK | Normal, should complete |
| `✅ Unity Banner: SDK is initialized` | Banner ready to show | Ad should appear |
| `❌ Unity Banner: SDK not initialized after 5 seconds` | Timeout | Check initialization logs |
| `✅ Unity Banner ad loaded` | Ad successfully loaded | You should see the ad! |
| `❌ Unity Banner ad failed` | Ad failed to load | Check error message |

## Quick Fix Checklist

- [ ] Internet connection is active
- [ ] App has internet permission
- [ ] Unity Ads plugin is installed (`flutter pub get`)
- [ ] Game ID is correct (5736497 for Android)
- [ ] Test mode is enabled (`testMode: true`)
- [ ] Running on Android device/emulator
- [ ] Waited at least 5 seconds after app start

## If Nothing Works

Try this complete reset:

```bash
# 1. Clean everything
flutter clean

# 2. Remove build folders
rm -rf build/
rm -rf android/build/
rm -rf android/app/build/

# 3. Reinstall dependencies
flutter pub get

# 4. Rebuild and run
flutter run
```

## Expected Behavior

**What you SHOULD see:**
1. App starts
2. Circular progress indicator in banner area (2-5 seconds)
3. Unity test banner ad appears
4. Banner shows Unity logo or test ad content

**What you should NOT see:**
- "Loading ad..." text forever
- Red error box
- Blank gray box forever
- No banner area at all

## Next Steps

If you're still seeing "Loading ad..." after following this guide:
1. Copy ALL logs from app start
2. Look for any error messages
3. Check if initialization completed successfully
4. Verify banner is trying to load
