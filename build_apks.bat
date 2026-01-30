@echo off
echo Building YONECO Mental Health APKs...

REM Set Flutter path
set PATH=%PATH%;C:\Src\flutter_windows_3.38.3-stable\flutter\bin

echo.
echo Building yoneco_app...
cd "d:\Work\YONECO Mental Health App\yomehe\yoneco_app"
flutter clean
flutter pub get
flutter build apk --release

echo.
echo Building yoneco_counsellor_app...
cd "d:\Work\YONECO Mental Health App\yomehe\yoneco_counsellor_app"
flutter clean
flutter pub get
flutter build apk --release

echo.
echo Build complete!
echo yoneco_app APK: d:\Work\YONECO Mental Health App\yomehe\yoneco_app\build\app\outputs\flutter-apk\app-release.apk
echo counsellor_app APK: d:\Work\YONECO Mental Health App\yomehe\yoneco_counsellor_app\build\app\outputs\flutter-apk\app-release.apk

pause