# Mobile Build & Network Setup Guide

## Prerequisites
- Flutter installed on your PC
- Android Studio or Android SDK installed
- USB debugging enabled on Android device OR Android emulator
- Your PC and mobile devices on the same WiFi network

## Step 1: Find Your PC's IP Address

### On Windows (PowerShell):
```powershell
ipconfig
```
Look for "IPv4 Address" under your WiFi adapter (e.g., `192.168.1.100`)

## Step 2: Update API Configuration Files

### Client App (yoneco_app)
**File:** `yoneco_app\lib\services\api_service.dart`

Update the base URL:
```dart
static const String baseUrl = 'http://YOUR_PC_IP:8080';
```

Example: `http://192.168.1.100:8080`

### Counsellor App (yoneco_counsellor_app)
**File:** `yoneco_counsellor_app\lib\services\api_service.dart`

Update the base URL:
```dart
static const String baseUrl = 'http://YOUR_PC_IP:8080';
```

Example: `http://192.168.1.100:8080`

## Step 3: Update Python API for Network Access

**File:** `python_api\main.py`

The API is already configured to accept connections from any IP:
```python
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
```

## Step 4: Configure Windows Firewall

Run PowerShell as Administrator:

```powershell
# Allow Python API through firewall
New-NetFirewallRule -DisplayName "YONECO API" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
```

## Step 5: Build Android APKs

### Build Client App
```powershell
cd D:\Projects\yomehe\yoneco_app
flutter clean
flutter pub get
flutter build apk --release
```

APK location: `yoneco_app\build\app\outputs\flutter-apk\app-release.apk`

### Build Counsellor App
```powershell
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter clean
flutter pub get
flutter build apk --release
```

APK location: `yoneco_counsellor_app\build\app\outputs\flutter-apk\app-release.apk`

## Step 6: Start the API

```powershell
cd D:\Projects\yomehe\python_api
python -m uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

## Step 7: Install APKs on Android Devices

### Option A: USB Transfer
1. Connect phone via USB
2. Copy APK to phone's Downloads folder
3. Use file manager to install APK
4. Enable "Install from Unknown Sources" if prompted

### Option B: ADB Install
```powershell
# For client app
adb install yoneco_app\build\app\outputs\flutter-apk\app-release.apk

# For counsellor app
adb install yoneco_counsellor_app\build\app\outputs\flutter-apk\app-release.apk
```

## Network Configuration Summary

### Your Setup:
- **API Server:** `http://YOUR_PC_IP:8080` (running on PC)
- **Client App:** Android device/emulator (connects to API)
- **Counsellor App:** Android device/emulator (connects to API)
- **Network:** All devices on same WiFi

### Test API Connection:
From your phone's browser, visit: `http://YOUR_PC_IP:8080/docs`

If you see the API documentation, network is configured correctly!

## Troubleshooting

### Can't Connect to API
1. **Check PC IP:** Make sure IP hasn't changed
2. **Check Firewall:** Verify port 8080 is allowed
3. **Same Network:** Ensure all devices on same WiFi
4. **API Running:** Verify API is running with `0.0.0.0` host

### Build Errors
```powershell
# Clean and rebuild
flutter clean
flutter pub get
flutter doctor
flutter build apk --release
```

### Permission Issues
Enable these in `AndroidManifest.xml` (already configured):
- INTERNET
- ACCESS_NETWORK_STATE

## Quick Start Commands

### Complete Build Process:
```powershell
# 1. Find your IP
ipconfig

# 2. Update IP in both apps' api_service.dart files
# Replace "localhost" or "10.0.2.2" with your PC IP

# 3. Build client app
cd D:\Projects\yomehe\yoneco_app
flutter build apk --release

# 4. Build counsellor app
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter build apk --release

# 5. Start API
cd D:\Projects\yomehe\python_api
python -m uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

## Test Credentials

### Counsellor Login:
- Email: `dr.smith@yoneco.org`
- Password: `password123`

### Client:
- No login required
- Just select an issue and start chatting!

## Important Notes

1. **Keep API Running:** The API must be running on your PC for apps to work
2. **Same Network:** All devices must be on the same WiFi network
3. **Firewall:** Windows Firewall must allow port 8080
4. **IP Changes:** If your PC IP changes, update the apps and rebuild
5. **Production:** For production, deploy API to a cloud server with fixed IP/domain

## Advanced: Using ngrok (Optional)

For testing without same network requirement:

```powershell
# Install ngrok
choco install ngrok

# Start tunnel
ngrok http 8080

# Use the ngrok URL in your apps
# Example: https://abc123.ngrok.io
```

Update `baseUrl` in both apps to the ngrok URL.
