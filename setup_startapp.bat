@echo off
echo ========================================
echo StartApp Ads Setup Script
echo ========================================
echo.

echo Step 1: Getting Flutter dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo Error: Failed to get dependencies
    pause
    exit /b 1
)
echo.

echo Step 2: Cleaning build...
call flutter clean
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo IMPORTANT: Before building, you need to:
echo 1. Get your StartApp App ID from https://portal.startapp.com/
echo 2. Edit android/app/src/main/AndroidManifest.xml
echo 3. Replace YOUR_APP_ID_HERE with your actual App ID
echo.
echo Then run: flutter build apk --release
echo.
pause
