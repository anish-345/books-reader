# Quick Start: StartApp Ads

## 3 Steps to Get Ads Running

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Get Your App ID
1. Go to https://portal.startapp.com/
2. Sign up and create a new app
3. Copy your App ID

### Step 3: Configure App ID
Open `android/app/src/main/AndroidManifest.xml` and find this line:
```xml
android:value="YOUR_APP_ID_HERE"
```

Replace with your actual App ID:
```xml
android:value="123456789"
```

### Done! Test It
```bash
flutter run
```

You should see:
- Banner ad at bottom of home screen
- Interstitial ad when exiting PDF/EPUB reader

---

## Before Production Release

Edit `lib/services/startapp_ad_service.dart` line 28:
```dart
_startAppSdk!.setTestAdsEnabled(false);  // Change to false
```

Then build:
```bash
flutter build apk --release
```

---

For detailed documentation, see **STARTAPP_ADS_SETUP.md**
