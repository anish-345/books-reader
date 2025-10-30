# Device Troubleshooting Guide

## 🔧 App Works on Emulator but Not Real Device

This is a common issue. Here are the fixes implemented and additional steps to try:

### ✅ Fixes Applied (v2.0.1)

1. **Architecture Compatibility**
   - Fixed minSdk to explicit value (21) instead of flutter.minSdkVersion
   - Removed x86_64 architecture (rare on real devices)
   - Added vector drawable support for older devices

2. **Device-Specific Compatibility**
   - Added largeHeap support for memory-intensive devices
   - Enhanced hardware acceleration settings
   - Added RTL support for international devices
   - Improved activity configuration for various screen sizes

3. **Enhanced Error Handling**
   - Added comprehensive try-catch blocks in main initialization
   - Safe fallback mode if main app fails to start
   - Detailed logging for debugging device-specific issues
   - Graceful handling of permission failures

4. **MainActivity Improvements**
   - Added error handling in onCreate method
   - Better intent handling for device variations
   - Improved file URI processing

### 📱 Testing Steps

#### Step 1: Install Debug APK First
```bash
# Install debug version for better error reporting
adb install build/app/outputs/flutter-apk/app-debug.apk
```

#### Step 2: Check Device Logs
```bash
# View app logs to identify specific issues
adb logcat | grep -E "(MainActivity|Flutter|BookReader)"
```

#### Step 3: Device-Specific Checks

**Check Android Version:**
```bash
adb shell getprop ro.build.version.release
```

**Check Device Architecture:**
```bash
adb shell getprop ro.product.cpu.abi
```

**Check Available Memory:**
```bash
adb shell cat /proc/meminfo | grep MemTotal
```

### 🔍 Common Device Issues & Solutions

#### Issue 1: App Crashes on Startup
**Symptoms:** App icon appears but immediately closes
**Solutions:**
- Install debug APK to see crash logs
- Check if device has sufficient RAM (minimum 2GB)
- Verify Android version is 5.0+ (API 21+)

#### Issue 2: App Doesn't Start at All
**Symptoms:** Nothing happens when tapping app icon
**Solutions:**
- Check if APK architecture matches device
- Try installing with `adb install -r app-release.apk`
- Clear device cache and restart

#### Issue 3: Permission Issues
**Symptoms:** App starts but can't access files
**Solutions:**
- Manually grant storage permissions in Settings
- For Android 11+: Enable "All files access" permission
- Check if device has custom permission manager

#### Issue 4: OEM-Specific Issues
**Symptoms:** Works on stock Android but not Samsung/Xiaomi/etc.
**Solutions:**
- Disable battery optimization for the app
- Add app to "Auto-start" whitelist
- Check OEM-specific permission settings

### 📋 Device Compatibility Matrix

| Device Type | Android Version | Status | Notes |
|-------------|----------------|--------|-------|
| Stock Android | 5.0-14 | ✅ Full | Reference implementation |
| Samsung Galaxy | 7.0+ | ✅ Full | May need battery optimization disabled |
| Xiaomi/MIUI | 8.0+ | ⚠️ Partial | Check auto-start permissions |
| Huawei/EMUI | 8.0+ | ⚠️ Partial | May need manual permission grants |
| OnePlus | 7.0+ | ✅ Full | Usually works well |
| Oppo/ColorOS | 8.0+ | ⚠️ Partial | Check background app permissions |

### 🛠️ Advanced Troubleshooting

#### Method 1: ADB Debugging
1. Enable Developer Options on device
2. Enable USB Debugging
3. Connect device to computer
4. Run: `adb logcat | grep Flutter`
5. Install and launch app
6. Check logs for specific error messages

#### Method 2: Safe Mode Installation
1. Install the debug APK first
2. If it works, the issue is in release configuration
3. If debug also fails, it's a device compatibility issue

#### Method 3: Minimal Test
1. Try installing the safe mode version (main_safe.dart)
2. If safe mode works, the issue is in app dependencies
3. Gradually enable features to identify the problem

### 📞 Getting Help

If the app still doesn't work on your device:

1. **Collect Information:**
   - Device model and Android version
   - Error logs from `adb logcat`
   - Whether debug APK works
   - Any error messages shown

2. **Try Alternative Installation:**
   - Use different APK (arm64 vs arm32)
   - Install via file manager instead of ADB
   - Try on different user account

3. **Device-Specific Solutions:**
   - Check manufacturer's app compatibility guidelines
   - Look for device-specific Android modifications
   - Try disabling device security features temporarily

### 🔄 Updated APK Files (v2.0.1)

**Release APK:** `build/app/outputs/flutter-apk/app-release.apk`
- Optimized for production use
- Smaller file size
- Better performance

**Debug APK:** `build/app/outputs/flutter-apk/app-debug.apk`
- Includes debugging information
- Better error reporting
- Larger file size but more informative

### ✅ Success Indicators

The app should now work on most real devices. You'll know it's working when:
- App icon launches successfully
- You see the Book Reader splash screen
- Home screen loads with file scanning
- No immediate crashes or force closes

If you're still having issues, the debug APK will provide detailed logs to help identify the specific problem with your device.