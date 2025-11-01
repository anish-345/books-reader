# 🧪 Testing Native Ads - Step by Step

## Current Status
✅ App is running  
✅ Banner ads working (Creative ID: 4153411311)  
✅ Code updated with native ads  

## 🔄 Step 1: Hot Reload

**In your Flutter terminal, press:**
```
R (capital R for hot restart)
```

This will reload the app with the new native ad code.

## 👀 Step 2: What to Look For

### In the App
1. **Scroll through your book list** (you have 14 books)
2. **Look for native ads** after every 5 books:
   - Books 1-5
   - **[Native Ad]** ← Should appear here
   - Books 6-10
   - **[Native Ad]** ← Should appear here
   - Books 11-14

### Native Ad Appearance
The native ad will look like:
```
┌─────────────────────────────┐
│ Ad                          │ ← Small badge
├─────────────────────────────┤
│ [Image] Title               │
│         Description         │
│         ⭐ 4.5  [Install]   │
└─────────────────────────────┘
```

## 📊 Step 3: Check Logs

### Look for these messages:
```
✅ StartApp: Native ad loaded
✅ StartApp: Native ad impression
✅ StartApp: Native ad clicked (if you click)
```

### If you see errors:
```
❌ StartApp: Native ad error: [message]
```

## 🧪 Step 4: Test Scenarios

### Scenario 1: Library Tab (Main Test)
1. Open app
2. You're on Library tab by default
3. Scroll down slowly
4. Count books: 1, 2, 3, 4, 5...
5. **Native ad should appear after book 5**
6. Continue: 6, 7, 8, 9, 10...
7. **Native ad should appear after book 10**

### Scenario 2: Recent Tab
1. Tap "Recent" tab at bottom
2. If you have recent books, scroll through
3. Native ads should appear every 5 books

### Scenario 3: Refresh
1. Pull down to refresh the list
2. Native ads should reload
3. Check if they appear in same positions

## 🐛 Troubleshooting

### No Native Ads Showing?

**Check 1: Book Count**
- Need at least 6 books to see first native ad
- You have 14 books ✅

**Check 2: Internet Connection**
- Native ads need internet to load
- Check your connection

**Check 3: Ad Fill Rate**
- Native ads may not always fill
- Normal for new apps
- Try scrolling multiple times

**Check 4: Loading Time**
- Native ads take 2-3 seconds to load
- You might see loading indicator first
- Wait a moment and scroll again

### Native Ad Looks Broken?

**This is normal if:**
- Some ads don't have images
- Some ads don't have ratings
- Widget handles this gracefully
- Ad will still show with available data

## 📱 Expected Behavior

### First Load
```
1. App opens
2. Banner ad loads (bottom) ✅ Already working
3. Book list loads (14 books)
4. Native ads start loading
5. After 2-3 seconds, native ads appear
```

### Scrolling
```
1. Scroll to book 5
2. See native ad
3. Scroll to book 10
4. See another native ad
```

## 🎯 Success Criteria

✅ Native ad appears after book 5  
✅ Native ad appears after book 10  
✅ Native ads look good (image, title, description)  
✅ No crashes or errors  
✅ Banner ad still works at bottom  

## 📝 What to Report

After testing, note:
1. ✅ or ❌ Did native ads appear?
2. ✅ or ❌ Did they look correct?
3. ✅ or ❌ Any errors in logs?
4. 📊 How many native ads loaded?
5. 💬 Any visual issues?

## 🔍 Debug Commands

If you need to check logs specifically for native ads:

### Windows PowerShell:
```powershell
# Filter for StartApp native ad logs
adb logcat | Select-String "Native"
```

### Or check all StartApp logs:
```powershell
adb logcat | Select-String "StartApp"
```

## 🎬 Ready to Test!

**Now:**
1. Press **R** in your Flutter terminal
2. Wait for app to reload
3. Scroll through your book list
4. Look for native ads after every 5 books

**Good luck! 🚀**
