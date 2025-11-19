# Unity Ads Placement Complete ✅

## Banner Ads Added to All Screens

### 1. Home Screen - Bottom Navigation Bar
**Location:** Above the bottom navigation bar
**Visibility:** Always visible on all tabs (Library, Recent, Bookmarks)

```dart
bottomNavigationBar: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    const UnityBannerWidget(),  // ✅ Banner ad
    BottomNavigationBar(...)
  ],
)
```

### 2. Home Screen - Library Tab (In List)
**Location:** After every 5 books in the list
**Pattern:** Book 1-5, Ad, Book 6-10, Ad, Book 11-15, Ad...

```dart
// Shows banner ad at positions 5, 11, 17, 23, etc.
if (_shouldShowBannerAd(index)) {
  return const UnityBannerWidget();
}
```

### 3. Home Screen - Recent Tab (In List)
**Location:** After every 5 books in the list
**Pattern:** Same as Library tab

### 4. PDF Reader Screen
**Location:** Bottom of screen
**Visibility:** Only shows when controls are hidden (for clean reading experience)

```dart
bottomNavigationBar: !_showControls ? const UnityBannerWidget() : null,
```

**User Experience:**
- User taps center of screen → Controls hide → Banner ad appears
- User taps again → Controls show → Banner ad hides
- Clean reading experience with monetization

### 5. EPUB Reader Screen
**Location:** Bottom of screen
**Visibility:** Only shows when controls are hidden (for clean reading experience)

Same behavior as PDF reader.

## Ad Placement Strategy

### Home Screen
- **Bottom Banner**: Always visible, consistent revenue
- **In-List Banners**: Every 5 items, non-intrusive, increases impressions

### Reader Screens
- **Hidden Controls Banner**: Only shows during reading
- **Clean UX**: Doesn't interfere with reading controls
- **Smart Placement**: Appears when user is focused on content

## Expected Ad Impressions

### Per User Session (Example)

**Home Screen:**
- Bottom banner: 1 impression (always visible)
- Library list (20 books): 4 banner ads
- Recent list (10 books): 2 banner ads
- **Total Home**: ~7 impressions per session

**Reading Session:**
- PDF/EPUB reader: 1 impression when controls hidden
- Average reading time: 10 minutes
- **Total Reading**: ~1 impression per book

**Daily Estimate (Active User):**
- 3 home screen visits: 21 impressions
- 2 books read: 2 impressions
- **Total**: ~23 banner impressions per day per user

## Ad Frequency

| Screen | Frequency | User Impact |
|--------|-----------|-------------|
| Home Bottom | Always | Low - Expected location |
| Library List | Every 5 items | Low - Natural spacing |
| Recent List | Every 5 items | Low - Natural spacing |
| PDF Reader | When controls hidden | Very Low - Clean reading |
| EPUB Reader | When controls hidden | Very Low - Clean reading |

## User Experience Considerations

### ✅ Good UX Decisions:
1. **Reader ads only when controls hidden** - Doesn't interfere with navigation
2. **List ads every 5 items** - Not too frequent, natural spacing
3. **Consistent bottom placement** - Users know where to expect ads
4. **Test mode enabled** - Can verify placement before production

### 🎯 Optimization Opportunities:
1. Monitor click-through rates per placement
2. Adjust list frequency if needed (every 3 or 7 items)
3. A/B test reader ad visibility
4. Track user engagement vs ad impressions

## Testing Checklist

### Home Screen
- [ ] Bottom banner shows on Library tab
- [ ] Bottom banner shows on Recent tab
- [ ] Bottom banner shows on Bookmarks tab
- [ ] Banner ad appears after 5 books in Library list
- [ ] Banner ad appears after 5 books in Recent list
- [ ] Scrolling is smooth with ads

### PDF Reader
- [ ] No banner when controls are visible
- [ ] Banner appears when controls are hidden
- [ ] Banner hides when controls show again
- [ ] Reading experience is not disrupted

### EPUB Reader
- [ ] No banner when controls are visible
- [ ] Banner appears when controls are hidden
- [ ] Banner hides when controls show again
- [ ] Page turning works smoothly

## Logs to Check

When testing, look for these logs:

```
✅ Unity Ads initialized successfully
✅ Unity Banner: SDK is initialized, showing banner
✅ Unity Banner ad loaded: Banner_Android
```

You should see multiple "Banner ad loaded" messages as you scroll through lists.

## Revenue Optimization

### Current Setup (Conservative):
- Bottom banner: Always visible
- List banners: Every 5 items
- Reader banners: When controls hidden

### Potential Adjustments:
1. **Increase frequency**: Every 3 items (more impressions, slightly more intrusive)
2. **Decrease frequency**: Every 7 items (fewer impressions, better UX)
3. **Reader always show**: Always show banner in reader (more revenue, worse UX)

**Recommendation**: Start with current setup, monitor metrics, adjust based on:
- User retention
- Click-through rate
- Revenue per user
- User feedback

## Production Checklist

Before releasing:
- [ ] Test all ad placements
- [ ] Verify ads load correctly
- [ ] Check scrolling performance
- [ ] Test on multiple devices
- [ ] Monitor crash reports
- [ ] Set `testMode: false` in `unity_ads_service.dart`
- [ ] Verify real ads show correctly
- [ ] Monitor Unity Ads dashboard

## Files Modified

1. ✅ `lib/presentation/screens/home/home_screen_v2.dart`
   - Added banner to bottom navigation
   - Added banners in Library list (every 5 items)
   - Added banners in Recent list (every 5 items)

2. ✅ `lib/presentation/screens/reader/pdf_reader_screen.dart`
   - Added banner when controls are hidden

3. ✅ `lib/presentation/screens/reader/epub_reader_v2.dart`
   - Added banner when controls are hidden

## Next Steps

1. **Run the app** and test all placements
2. **Check logs** for successful ad loading
3. **Monitor performance** - ensure smooth scrolling
4. **Gather feedback** - check if ads are too intrusive
5. **Adjust frequency** if needed based on metrics

## Support

If ads don't show:
1. Check Unity Ads initialization logs
2. Verify internet connection
3. Check Unity Ads dashboard
4. Review UNITY_ADS_DEBUG.md for troubleshooting
