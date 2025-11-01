# 🚀 StartApp Ads - Quick Reference Card

## 📱 What's Integrated

✅ **Banner Ads** - Bottom of home screen  
✅ **Native Ads** - Every 5 books in lists (NEW!)  
✅ **Interstitial Ads** - When exiting readers  

## 🎯 App ID

```
209362856
```

## 🔧 Test Mode

```
DISABLED ✅ (Real ads active)
```

## 📊 Ad Locations

```
Home Screen
├── Banner Ad (always visible)
└── Book List
    ├── Books 1-5
    ├── Native Ad ← Every 5 books
    ├── Books 6-10
    ├── Native Ad
    └── ...

Reader
└── Interstitial Ad (on exit)
```

## 💰 Revenue Potential

| Ad Type | Revenue Share |
|---------|---------------|
| Banner | 30% |
| Native | **40%** ⭐ |
| Interstitial | 30% |

## 🚀 Quick Actions

### Test Now
```bash
# Hot restart
Press 'R' in Flutter terminal
```

### Monitor Revenue
```
https://portal.startapp.com/
```

### Adjust Native Ad Frequency
```dart
// File: lib/presentation/screens/home/home_screen_v2.dart

// Current: Every 5 books
return (index + 1) % 6 == 0;

// Every 3 books:
return (index + 1) % 4 == 0;

// Every 10 books:
return (index + 1) % 11 == 0;
```

### Disable Test Mode (Already Done ✅)
```dart
// File: lib/services/startapp_ad_service.dart
await startAppSdk.setTestAdsEnabled(false);
```

## 📈 Expected Logs

```
✅ StartApp: SDK initialized successfully
✅ StartApp: Banner ad loaded
✅ StartApp: Native ad loaded
✅ StartApp: Interstitial ad loaded
✅ Sending impression
```

## 🐛 Troubleshooting

**No ads showing?**
1. Check internet connection
2. Wait 5-10 minutes
3. Verify App ID: 209362856
4. Check StartApp dashboard

**Ads look broken?**
1. Normal - some ads missing fields
2. Widget handles gracefully
3. Customize in `startapp_native_widget.dart`

## 📚 Full Documentation

- `QUICK_START_ADS.md` - Setup guide
- `NATIVE_ADS_GUIDE.md` - Native ads details
- `ADS_COMPLETE_SUMMARY.md` - Full overview

## ✅ Status

| Component | Status |
|-----------|--------|
| Banner Ads | ✅ Active |
| Native Ads | ✅ Active |
| Interstitial Ads | ✅ Active |
| Test Mode | ✅ Disabled |
| App ID | ✅ Configured |

**Ready to earn! 💰**
