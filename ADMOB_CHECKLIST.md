# AdMob Integration Checklist

## ✅ Completed (Migration Done)

- [x] Removed Unity Ads plugin from pubspec.yaml
- [x] Added Google Mobile Ads plugin to pubspec.yaml
- [x] Created AdMobService to replace UnityAdsService
- [x] Created AdMobBannerWidget to replace UnityBannerWidget
- [x] Updated all screen files to use AdMob widgets
- [x] Updated main.dart to initialize AdMob
- [x] Updated ad_frequency_service.dart to use AdMob
- [x] Added AdMob App ID to AndroidManifest.xml
- [x] Deleted old Unity Ads files
- [x] Verified code compiles without errors
- [x] App is using AdMob test ads

## ⏳ To Do (Before Production Release)

### 1. AdMob Account Setup
- [ ] Create AdMob account at https://admob.google.com/
- [ ] Add your app to AdMob
- [ ] Note your App ID (format: ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX)

### 2. Create Ad Units
- [ ] Create Banner ad unit
- [ ] Create Interstitial ad unit
- [ ] Create Rewarded ad unit (optional, for future features)
- [ ] Note all Ad Unit IDs

### 3. Update Android Configuration
- [ ] Replace test App ID in `android/app/src/main/AndroidManifest.xml`
  ```xml
  <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="YOUR_ACTUAL_APP_ID"/>
  ```

### 4. Update Ad Unit IDs
- [ ] Open `lib/services/admob_service.dart`
- [ ] Replace banner test ID with your Banner Ad Unit ID
- [ ] Replace interstitial test ID with your Interstitial Ad Unit ID
- [ ] Replace rewarded test ID with your Rewarded Ad Unit ID (if using)

### 5. iOS Configuration (If Supporting iOS)
- [ ] Add App ID to `ios/Runner/Info.plist`:
  ```xml
  <key>GADApplicationIdentifier</key>
  <string>YOUR_ACTUAL_APP_ID</string>
  ```
- [ ] Update iOS Ad Unit IDs in `admob_service.dart`

### 6. Testing
- [ ] Test app with test ads (current setup)
- [ ] Replace with real Ad Unit IDs
- [ ] Test app with real ads
- [ ] Verify ads load correctly
- [ ] Check AdMob dashboard for impressions
- [ ] Test on multiple devices
- [ ] Test with different network conditions

### 7. Pre-Release Verification
- [ ] Confirm NO test Ad Unit IDs remain in code
- [ ] Confirm App ID is your actual AdMob App ID
- [ ] Test interstitial ad frequency (5-minute minimum)
- [ ] Verify banner ads show in all locations
- [ ] Check app performance with ads
- [ ] Review AdMob policies compliance

### 8. Build & Release
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Build release APK: `flutter build apk --release`
- [ ] Test release build
- [ ] Upload to Play Store
- [ ] Monitor AdMob dashboard after release

## Important Reminders

### ⚠️ Critical
- **NEVER** use test ads in production
- **NEVER** click your own ads
- **ALWAYS** test with test ads during development
- **ALWAYS** replace test IDs before release

### 📊 Monitoring
After release, monitor:
- Ad fill rate in AdMob dashboard
- Ad impressions and clicks
- Revenue (if monetization is enabled)
- User complaints about ads
- App performance metrics

### 🔧 Troubleshooting
If ads don't show:
1. Check internet connection
2. Verify Ad Unit IDs are correct
3. Check AdMob account status
4. Review app logs for errors
5. Wait 24-48 hours for ad inventory to fill
6. Check AdMob policy compliance

## Test Ad Unit IDs (Current)

### Android
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`

### iOS
- Banner: `ca-app-pub-3940256099942544/2934735716`
- Interstitial: `ca-app-pub-3940256099942544/4411468910`
- Rewarded: `ca-app-pub-3940256099942544/1712485313`

### App ID (Test)
- Android: `ca-app-pub-3940256099942544~3347511713`
- iOS: `ca-app-pub-3940256099942544~1458002511`

## Resources

- [AdMob Console](https://admob.google.com/)
- [AdMob Documentation](https://developers.google.com/admob)
- [Flutter Google Mobile Ads](https://pub.dev/packages/google_mobile_ads)
- [AdMob Policies](https://support.google.com/admob/answer/6128543)

## Support

For detailed information, see:
- `ADMOB_MIGRATION.md` - Complete migration documentation
- `ADMOB_QUICK_START.md` - Quick reference guide
