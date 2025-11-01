# 📊 Check Ads with Logs - Complete Guide

## ✅ Changes Made

### 1. Banner Ads Added to Readers
- ✅ PDF Reader: Banner shows when controls are hidden
- ✅ EPUB Reader: Banner shows when controls are hidden
- ✅ Home Screen: Banner always visible at bottom

### 2. Enhanced Logging
All ads now have emoji-based logs for easy tracking:
- 🔄 = Loading
- ✅ = Success
- ❌ = Error
- ⚠️ = Warning/Skipped
- 👁️ = Impression
- 👆 = Click
- 📺 = Displayed
- 👋 = Closed

## 🔍 How to Check Logs

### Step 1: Hot Restart
```
Press R in Flutter terminal
```

### Step 2: Watch for Initialization
Look for:
```
🔄 StartApp: Initializing SDK...
✅ StartApp: SDK initialized successfully (Test mode: OFF, Real ads enabled)
```

### Step 3: Check Each Ad Type

#### Banner Ads (Home Screen)
```
🔄 StartApp Banner: Loading...
✅ StartApp Banner: Loaded successfully
```

#### Banner Ads (Readers)
Open a PDF/EPUB, tap to hide controls:
```
🔄 StartApp Banner: Loading...
✅ StartApp Banner: Loaded successfully
```

#### Native Ads (Book Lists)
Scroll through book list:
```
🔄 StartApp Native: Loading...
✅ StartApp Native: Loaded successfully
OR
⚠️ StartApp Native: No ad available (low fill rate)
```

#### Interstitial Ads (Reader Exit)
Open a book, then close it:
```
🔄 StartApp Interstitial: Loading...
✅ StartApp Interstitial: Loaded successfully
📺 StartApp Interstitial: Displayed
👋 StartApp Interstitial: Hidden/Closed
```

## 📱 Complete Test Flow

### Test 1: Home Screen Banner
1. Open app
2. Look for logs:
   ```
   ✅ StartApp: SDK initialized successfully
   🔄 StartApp Banner: Loading...
   ✅ StartApp Banner: Loaded successfully
   ```
3. ✅ See banner at bottom of home screen

### Test 2: Native Ads
1. Scroll through book list
2. Look for logs:
   ```
   🔄 StartApp Native: Loading...
   ✅ StartApp Native: Loaded successfully
   OR
   ⚠️ StartApp Native: No ad available (low fill rate)
   ```
3. ✅ See native ad after every 5 books (if available)
4. ⚠️ Or see nothing (if no fill)

### Test 3: PDF Reader Banner
1. Open any PDF
2. Tap screen to hide controls
3. Look for logs:
   ```
   🔄 StartApp Banner: Loading...
   ✅ StartApp Banner: Loaded successfully
   ```
4. ✅ See banner at bottom

### Test 4: Interstitial Ad
1. Open any PDF/EPUB
2. Read for a few seconds
3. Press back to exit
4. Look for logs:
   ```
   🔄 StartApp Interstitial: Loading...
   ✅ StartApp Interstitial: Loaded successfully
   📺 StartApp Interstitial: Displayed
   ```
5. ✅ See full-screen ad
6. Close ad:
   ```
   👋 StartApp Interstitial: Hidden/Closed
   ```

## 🎯 Expected Log Sequence

### App Startup:
```
🔄 StartApp: Initializing SDK...
✅ StartApp: SDK initialized successfully (Test mode: OFF, Real ads enabled)
🔄 StartApp Banner: Loading...
✅ StartApp Banner: Loaded successfully
🔄 StartApp Native: Loading...
⚠️ StartApp Native: No ad available (low fill rate)
```

### Opening PDF:
```
🔄 StartApp Interstitial: Loading...
✅ StartApp Interstitial: Loaded successfully
🔄 StartApp Banner: Loading...
✅ StartApp Banner: Loaded successfully
```

### Closing PDF:
```
📺 StartApp Interstitial: Displayed
👋 StartApp Interstitial: Hidden/Closed
```

## 🐛 Troubleshooting with Logs

### Issue: No logs at all
**Logs**: (nothing)
**Problem**: SDK not initialized
**Solution**: Check if Platform.isAndroid is true

### Issue: Initialization fails
**Logs**: 
```
❌ StartApp: Initialization error: [error]
```
**Problem**: SDK issue
**Solution**: Check App ID in AndroidManifest.xml

### Issue: Banner not loading
**Logs**:
```
🔄 StartApp Banner: Loading...
❌ StartApp Banner: Error - [error]
```
**Problem**: Network or SDK issue
**Solution**: Check internet connection

### Issue: Native ads never show
**Logs**:
```
🔄 StartApp Native: Loading...
⚠️ StartApp Native: No ad available (low fill rate)
```
**Problem**: Low fill rate (NORMAL)
**Solution**: This is expected, native ads have 20-40% fill rate

### Issue: Interstitial not showing
**Logs**:
```
🔄 StartApp Interstitial: Loading...
⚠️ StartApp Interstitial: Not displayed
```
**Problem**: Ad not ready or no fill
**Solution**: Normal, try again later

## 📊 What Success Looks Like

### Minimum Working Setup:
```
✅ SDK initialized
✅ Banner ads loading (home + readers)
✅ Interstitial ads loading
⚠️ Native ads may or may not load (normal)
```

### Full Success:
```
✅ SDK initialized
✅ Banner ads: 3 locations (home, PDF reader, EPUB reader)
✅ Interstitial ads: Working on reader exit
✅ Native ads: Showing occasionally (20-40% fill rate)
```

## 🎯 Current Ad Locations

### Banner Ads (3 locations):
1. ✅ Home screen bottom (always visible)
2. ✅ PDF reader bottom (when controls hidden)
3. ✅ EPUB reader bottom (when controls hidden)

### Native Ads (2 locations):
1. ⚠️ Library tab (every 5 books, if available)
2. ⚠️ Recent tab (every 5 books, if available)

### Interstitial Ads (2 locations):
1. ✅ PDF reader exit
2. ✅ EPUB reader exit

## 📝 Log Filtering Commands

### Windows PowerShell:
```powershell
# See all StartApp logs
adb logcat | Select-String "StartApp"

# See only successful ads
adb logcat | Select-String "✅"

# See only errors
adb logcat | Select-String "❌"

# See banner ads only
adb logcat | Select-String "Banner"

# See native ads only
adb logcat | Select-String "Native"
```

## 🎉 Summary

**After hot restart, you should see:**
1. ✅ SDK initialization
2. ✅ Banner ads loading (home screen)
3. ✅ Interstitial ads preloading
4. ⚠️ Native ads attempting to load (may fail due to low fill)

**This is a successful setup!** Even if native ads don't show, your banner and interstitial ads are working and generating revenue.

---

**Hot restart now and watch the logs!** 🚀
