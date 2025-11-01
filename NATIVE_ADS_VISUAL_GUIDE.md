# 📱 Native Ads Visual Guide

## Where Native Ads Appear

Based on your 14 books, here's exactly where native ads will show:

```
┌─────────────────────────────────────┐
│  📚 Book Reader - Library           │
├─────────────────────────────────────┤
│                                     │
│  📄 Book 1: pdfcoffee.com_books... │
│  📄 Book 2: cc-6th-edition.pdf     │
│  📄 Book 3: romantische-lieder...  │
│  📄 Book 4: awaken-the-giant...    │
│  📄 Book 5: pg77137-images.epub    │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Ad                          │   │ ← NATIVE AD #1
│  ├─────────────────────────────┤   │
│  │ [📱] Amazing App            │   │
│  │      Download now and...    │   │
│  │      ⭐ 4.5    [Install]    │   │
│  └─────────────────────────────┘   │
│                                     │
│  📄 Book 6: siddhartha-by-her...   │
│  📄 Book 7: GANDHI-A Biography...  │
│  📄 Book 8: pdfcoffee.com_books... │
│  📄 Book 9: cc-6th-edition.pdf     │
│  📄 Book 10: romantische-lieder... │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Ad                          │   │ ← NATIVE AD #2
│  ├─────────────────────────────┤   │
│  │ [🎮] Cool Game              │   │
│  │      Play the best...       │   │
│  │      ⭐ 4.8    [Play Now]   │   │
│  └─────────────────────────────┘   │
│                                     │
│  📄 Book 11: awaken-the-giant...   │
│  📄 Book 12: pg77137-images.epub   │
│  📄 Book 13: siddhartha-by-her...  │
│  📄 Book 14: GANDHI-A Biography... │
│                                     │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │ [Banner Ad]                 │   │ ← BANNER AD
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  📚 Library  📖 Recent  🔖 Bookmarks│
└─────────────────────────────────────┘
```

## Native Ad Design

### Full Native Ad Example

```
┌─────────────────────────────────────┐
│ Ad                                  │ ← Gray badge (top-left)
├─────────────────────────────────────┤
│                                     │
│  ┌────────┐  Amazing Photo Editor  │ ← Title (bold)
│  │        │                         │
│  │ [IMG]  │  Edit your photos with  │ ← Description
│  │        │  professional tools...  │
│  │        │                         │
│  └────────┘  ⭐ 4.7  [Download]     │ ← Rating + CTA
│                                     │
└─────────────────────────────────────┘
```

### Components

1. **Ad Badge** (Top-left corner)
   - Text: "Ad"
   - Color: Gray background
   - Size: Small

2. **Image** (Left side)
   - Size: 80x80 pixels
   - Rounded corners
   - App icon or screenshot

3. **Title** (Top-right)
   - Font: Bold, 16px
   - Color: Black
   - Max: 2 lines

4. **Description** (Middle-right)
   - Font: Regular, 13px
   - Color: Gray
   - Max: 2 lines

5. **Rating** (Bottom-left)
   - Star icon + number
   - Example: ⭐ 4.5

6. **CTA Button** (Bottom-right)
   - Text: "Install", "Download", "Play", etc.
   - Color: Blue
   - Style: Rounded button

## Comparison: Native vs Banner

### Native Ad (In List)
```
┌─────────────────────────────────────┐
│ Ad                                  │
│ [IMG] Title                         │
│       Description                   │
│       ⭐ 4.5    [Install]           │
└─────────────────────────────────────┘
```
- **Height**: ~100px
- **Blends**: Looks like content
- **Engagement**: High (2-3% CTR)
- **Revenue**: High

### Banner Ad (Bottom)
```
┌─────────────────────────────────────┐
│ [Standard Banner Ad - 320x50]       │
└─────────────────────────────────────┘
```
- **Height**: 50px
- **Blends**: Separate from content
- **Engagement**: Low (0.5% CTR)
- **Revenue**: Low

## Loading States

### 1. Initial Load (0-2 seconds)
```
┌─────────────────────────────────────┐
│                                     │
│         ⏳ Loading...               │ ← Loading indicator
│                                     │
└─────────────────────────────────────┘
```

### 2. Ad Loaded (After 2-3 seconds)
```
┌─────────────────────────────────────┐
│ Ad                                  │
│ [IMG] Title                         │
│       Description                   │
│       ⭐ 4.5    [Install]           │
└─────────────────────────────────────┘
```

### 3. No Ad Available (Sometimes)
```
(Nothing shows - list continues normally)
```

## Mobile View (Actual Size)

On a typical phone screen:

```
┌─────────────────┐
│ 📚 Book Reader  │
├─────────────────┤
│ 📄 Book 1       │
│ 📄 Book 2       │
│ 📄 Book 3       │
│ 📄 Book 4       │
│ 📄 Book 5       │
│                 │
│ ┌─────────────┐ │
│ │Ad           │ │
│ │[📱] App     │ │
│ │    Desc...  │ │
│ │⭐4.5 [Get]  │ │
│ └─────────────┘ │
│                 │
│ 📄 Book 6       │
│ 📄 Book 7       │
└─────────────────┘
```

## Color Scheme

### Native Ad Colors
- **Background**: White (#FFFFFF)
- **Border**: Light Gray (#E0E0E0)
- **Ad Badge**: Gray (#F5F5F5)
- **Title**: Black (#000000)
- **Description**: Dark Gray (#666666)
- **CTA Button**: Blue (#1976D2)
- **CTA Text**: White (#FFFFFF)
- **Star**: Amber (#FFA000)

### Matches Your App
The native ad design matches your book cards:
- Same rounded corners
- Same shadow style
- Same padding
- Blends seamlessly

## User Experience

### Good UX ✅
- Ads clearly labeled with "Ad" badge
- Blends with content but distinguishable
- Not too frequent (every 5 books)
- Loads smoothly without blocking
- Doesn't interrupt reading flow

### What Users See
1. Scrolling through books
2. See interesting app ad
3. Looks like a recommendation
4. Can tap to learn more
5. Or scroll past to continue

## Testing Checklist

When you test, verify:

- [ ] Native ad appears after book 5
- [ ] Native ad appears after book 10
- [ ] Ad has image (or placeholder)
- [ ] Ad has title
- [ ] Ad has description
- [ ] Ad has CTA button
- [ ] "Ad" badge is visible
- [ ] Design matches book cards
- [ ] No layout issues
- [ ] Tapping ad works
- [ ] Banner ad still works at bottom

## Expected Timeline

```
0s  → App opens
1s  → Books load (14 books)
2s  → Banner ad loads ✅
3s  → Native ads start loading
5s  → First native ad appears
6s  → Second native ad appears
```

## Summary

**You should see:**
- 2 native ads in your 14-book list
- Position: After books 5 and 10
- Design: Image + Title + Description + CTA
- Style: Matches your book cards
- Plus: Banner ad at bottom (already working)

**Total ads visible:**
- 1 Banner ad (bottom)
- 2 Native ads (in list)
- = 3 ads total on home screen

**Ready to test! Press R to hot reload! 🚀**
