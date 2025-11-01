# 🧪 Test All Ads - Quick Guide

## 🔄 Step 1: Hot Restart

**In your Flutter terminal, press:**
```
R (capital R)
```

Wait for app to reload (~10 seconds)

## ✅ Step 2: Test Each Ad Type

### Test 1: Banner Ad (Already Working ✅)
**Location**: Bottom of home screen

**Steps**:
1. Open app
2. Look at bottom of screen
3. ✅ See banner ad above navigation bar

**Expected**: Banner ad visible with "StartApp" branding

---

### Test 2: Native Ads (Fixed ⭐)
**Location**: Every 5 books in list

**Steps**:
1. On home screen (Library tab)
2. Scroll down through book list
3. Count: Book 1, 2, 3, 4, 5...
4. ✅ See native ad after book 5
5. Continue: Book 6, 7, 8, 9, 10...
6. ✅ See native ad after book 10

**Expected**: 
```
┌─────────────────────────┐
│ Ad                      │
│ [📱] App Title          │
│      Description...     │
│      ⭐ 4.5  [Install]  │
└─────────────────────────┘
```

**If not showing**:
- Wait 5 seconds (loading)
- Scroll up and down again
- Check internet connection
- Normal if some don't load (fill rate)

---

### Test 3: Rewarded Video Ad (New 🎁)
**Location**: Search button

**Steps**:
1. Tap **Search icon** (🔍) at top-right
2. ✅ Dialog appears: "Watch a short video to use Search"
3. Tap **"Watch Video"** button
4. ✅ Loading: "Loading ad..."
5. ✅ Video ad plays (15-30 seconds)
6. ✅ Success: "Thanks for watching! Feature unlocked."
7. ✅ Search screen opens

**Expected Dialog**:
```
┌─────────────────────────────┐
│ 📺 Watch Ad                 │
├─────────────────────────────┤
│ Watch a short video to use  │
│ Search                      │
│                             │
│ ℹ️ This helps keep the app  │
│   free!                     │
│                             │
│    [Cancel] [▶ Watch Video] │
└─────────────────────────────┘
```

**If video doesn't play**:
- Normal - ad fill rate varies
- Feature unlocks anyway
- Try again later

---

### Test 4: Bookmark Rewarded Ad (New 🎁)
**Location**: Bookmarks tab search

**Steps**:
1. Tap **"Bookmarks"** tab at bottom
2. Tap **Search icon** (🔍) at top-right
3. ✅ Same dialog as Test 3
4. ✅ Watch video
5. ✅ Bookmark search opens

---

### Test 5: Interstitial Ad (Already Working ✅)
**Location**: When exiting reader

**Steps**:
1. Tap any book to open
2. Read for a few seconds
3. Tap **back button** to exit
4. ✅ Full-screen interstitial ad appears
5. Wait or close ad
6. Return to home screen

**Expected**: Full-screen ad with close button

---

## 📊 Check Logs

Look for these messages in your Flutter terminal:

### Banner Ads
```
✅ StartApp: Banner ad loaded
✅ Loaded BANNER ad with creative ID - [number]
✅ Sending impression
```

### Native Ads
```
✅ StartApp: Native ad loaded
✅ StartApp: Native ad impression
```

### Rewarded Ads
```
✅ StartApp: Rewarded video loaded
✅ StartApp: Rewarded video displayed
✅ StartApp: Rewarded video completed
✅ Reward earned!
```

### Interstitial Ads
```
✅ StartApp: Interstitial ad loaded
✅ StartApp: Interstitial ad displayed
```

## ✅ Success Checklist

After testing, verify:

- [ ] Banner ad visible at bottom
- [ ] Native ads appear after every 5 books
- [ ] Search shows rewarded ad dialog
- [ ] Rewarded video plays
- [ ] Search unlocks after watching
- [ ] Bookmark search shows rewarded ad
- [ ] Interstitial ad shows when exiting reader
- [ ] No crashes or errors
- [ ] All features work correctly

## 🎯 Expected Results

### Total Ads Visible

**On Home Screen**:
- 1 Banner ad (bottom)
- 2 Native ads (in 14-book list)
- = 3 ads visible

**During Usage**:
- 1 Rewarded ad (if using search)
- 1 Interstitial ad (per reading session)
- = 2 more ads

**Total**: 5 ads per typical session

## 🐛 Troubleshooting

### No Native Ads?
1. Wait 10 seconds
2. Scroll up and down
3. Check internet
4. Normal if some don't load

### Rewarded Video Won't Play?
1. Check internet
2. Wait 10 seconds
3. Try again
4. Normal - feature unlocks anyway

### App Crashes?
1. Check logs for errors
2. Run `flutter clean`
3. Run `flutter pub get`
4. Restart app

## 📱 What You Should See

### Home Screen
```
┌─────────────────────────┐
│ 📚 Book Reader          │
├─────────────────────────┤
│ 📄 Book 1               │
│ 📄 Book 2               │
│ 📄 Book 3               │
│ 📄 Book 4               │
│ 📄 Book 5               │
│ ┌─────────────────────┐ │
│ │ Ad [Native Ad]      │ │ ← Native Ad
│ └─────────────────────┘ │
│ 📄 Book 6               │
│ 📄 Book 7               │
│ 📄 Book 8               │
│ 📄 Book 9               │
│ 📄 Book 10              │
│ ┌─────────────────────┐ │
│ │ Ad [Native Ad]      │ │ ← Native Ad
│ └─────────────────────┘ │
│ 📄 Book 11              │
├─────────────────────────┤
│ [Banner Ad]             │ ← Banner Ad
├─────────────────────────┤
│ 📚 Library 📖 Recent 🔖 │
└─────────────────────────┘
```

## 🎉 All Tests Complete!

If all tests pass:
- ✅ All 4 ad types working
- ✅ Good user experience
- ✅ Ready to earn revenue
- ✅ Production ready!

**Check StartApp dashboard**: https://portal.startapp.com/

You should see impressions counting up! 💰

---

**Happy Testing! 🚀**
