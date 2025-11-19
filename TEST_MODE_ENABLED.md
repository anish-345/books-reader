# Unity Ads - Test Mode Enabled ✅

## Configuration

### Test Game IDs (Unity Official)
- **Android**: `5736465`
- **iOS**: `5736464`
- **Test Mode**: `true` ✅

### Ad Unit IDs
- **Banner**: `Banner_Android`
- **Interstitial**: `Interstitial_Android`
- **Rewarded**: `Rewarded_Android`

## Why Test Mode?

Test ads load **instantly** and are guaranteed to show. This helps verify:
1. ✅ Unity Ads SDK is working
2. ✅ Banner widgets are rendering correctly
3. ✅ Ad placements are correct
4. ✅ No integration issues

## Expected Behavior

### Test Ads
- **Load Time**: Instant (< 1 second)
- **Fill Rate**: 100% (always available)
- **Content**: "Unity Ads Test" banners
- **Revenue**: $0 (test ads don't generate revenue)

### Where Ads Appear
1. **Home Screen Bottom** - Above navigation bar
2. **Book List** - Every 6 items
3. **PDF Reader** - At bottom when controls visible

## Testing Steps

1. **Hot Reload** - Press 'r' in terminal
2. **Wait 2-3 seconds** - For SDK initialization
3. **Check Home Screen** - Banner should appear at bottom
4. **Scroll Book List** - Banners every 6 items
5. **Open PDF** - Banner at bottom

## Console Output

### Success
```
✅ Unity Ads initialized successfully
✅ Banner loaded: Banner_Android
```

### Failure
```
❌ Unity Ads init failed: [message]
❌ Banner failed: [message]
```

## After Testing

Once test ads work, switch back to production:

```dart
// Change in lib/services/unity_ads_service.dart
static const String _androidGameId = '5975924'; // Your production ID
testMode: false, // Disable test mode
```

---

**Status**: Test Mode Active
**Game ID**: 5736465 (Unity Test)
**Expected**: Instant ad loading
**Next**: Hot reload and verify ads appear
