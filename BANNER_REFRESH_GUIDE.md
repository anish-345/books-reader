# 🔄 Banner Ad Refresh Guide

## Current Behavior

**Banner ads load once and stay:**
- Home screen: Until app closes
- PDF reader: Until reader closes  
- EPUB reader: Until reader closes

**StartApp SDK may auto-refresh internally** (every 30-60 seconds), but this is handled by the SDK.

## Why Current Setup Is Good

### For Readers (PDF/EPUB):
- ✅ No distracting ad changes while reading
- ✅ Stable layout
- ✅ Better user experience
- ✅ Less data usage

### For Home Screen:
- ✅ Consistent experience
- ✅ No layout shifts
- ✅ SDK handles refresh internally

## If You Want Manual Refresh

### Option 1: Periodic Refresh (Home Screen Only)

Add a timer to refresh home screen banner every 60 seconds:

```dart
// In startapp_banner_widget.dart

import 'dart:async';

class _StartAppBannerWidgetState extends State<StartAppBannerWidget> {
  StartAppBannerAd? _bannerAd;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadBanner();
    
    // Refresh every 60 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _loadBanner(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }
  
  // ... rest of code
}
```

### Option 2: Refresh on User Action

Refresh banner when user returns to home screen:

```dart
// In home_screen_v2.dart

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Refresh banner when screen becomes visible
  _refreshBanner();
}
```

### Option 3: Let SDK Handle It (Recommended ⭐)

**Do nothing!** StartApp SDK automatically refreshes banners internally.

## Recommended Setup

### Home Screen:
- **Current**: Load once
- **Recommendation**: Keep as is, SDK handles refresh
- **Why**: Simple, stable, works well

### Readers (PDF/EPUB):
- **Current**: Load once per session
- **Recommendation**: Keep as is, NO refresh
- **Why**: Better reading experience

## StartApp SDK Auto-Refresh

The StartApp SDK has built-in auto-refresh:
- **Frequency**: Every 30-60 seconds (SDK controlled)
- **Automatic**: No code needed
- **Smart**: Only refreshes when appropriate
- **Invisible**: Smooth transitions

## Testing Refresh

To see if SDK is auto-refreshing:

1. Open app
2. Stay on home screen
3. Watch banner for 60 seconds
4. SDK may refresh automatically
5. Check logs for new banner loads

## Revenue Impact

### With Auto-Refresh:
- **More impressions**: New ad every 30-60 seconds
- **Higher revenue**: More impressions = more money
- **SDK optimized**: StartApp handles timing

### Without Manual Refresh:
- **Fewer impressions**: One ad per session
- **Lower revenue**: But better UX
- **Still good**: SDK may refresh internally

## Recommendation

**Keep current setup!** ✅

**Why:**
1. StartApp SDK handles refresh automatically
2. Better user experience (no jarring changes)
3. Simpler code (less to maintain)
4. Stable layout (no shifts)
5. Good balance of revenue and UX

**Only add manual refresh if:**
- You see no revenue from banners
- StartApp support recommends it
- You want to test different refresh rates

## Summary

**Current**: Banner loads once per screen/session  
**SDK**: May auto-refresh every 30-60 seconds internally  
**Recommendation**: Keep as is, let SDK handle it  
**Result**: Good balance of revenue and UX  

---

**Your current setup is optimal!** 🚀
