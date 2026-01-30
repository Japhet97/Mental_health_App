# 📱 YONECO Mobile Testing Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Finding Your Computer's IP Address](#finding-your-computers-ip-address)
3. [API Setup for Mobile](#api-setup-for-mobile)
4. [Client App Configuration](#client-app-configuration)
5. [Counsellor App Configuration](#counsellor-app-configuration)
6. [Testing on Different Platforms](#testing-on-different-platforms)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before testing on mobile devices, ensure you have:
- ✅ Python API running on your computer
- ✅ Flutter installed and configured
- ✅ Android Studio (for Android) or Xcode (for iOS/macOS)
- ✅ Physical device OR emulator/simulator set up

---

## Finding Your Computer's IP Address

Your mobile device needs to connect to the API running on your computer. Find your IP address:

### Windows:
```bash
ipconfig
```
Look for "IPv4 Address" under your active network adapter (usually starts with 192.168.x.x or 10.0.x.x)

### macOS/Linux:
```bash
ifconfig
```
or
```bash
ip addr show
```

**Example:** Your IP might be something like `192.168.1.100`

---

## API Setup for Mobile

### 1. Configure API to Accept External Connections

Navigate to your API directory:
```bash
cd D:\Projects\yomehe\python_api
```

### 2. Start the API with External Access

**Option A - Recommended (Bind to all interfaces):**
```bash
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

**Option B - Using specific IP:**
```bash
python -m uvicorn main:app --reload --host YOUR_IP_ADDRESS --port 8080
```
Replace `YOUR_IP_ADDRESS` with your actual IP (e.g., `192.168.1.100`)

### 3. Verify API is Accessible

Test from your browser on the SAME computer:
- `http://localhost:8080/docs` ✅
- `http://YOUR_IP_ADDRESS:8080/docs` ✅ (Should also work)

If the second URL works, your API is ready for mobile testing!

---

## Client App Configuration

### For Android Emulator:
1. Open: `D:\Projects\yomehe\yoneco_app\lib\config\app_config.dart`
2. Change line 9:
```dart
static const String apiBaseUrl = "http://10.0.2.2:8080";
```
(10.0.2.2 is Android emulator's special alias for localhost)

### For iOS Simulator:
1. Open: `D:\Projects\yomehe\yoneco_app\lib\config\app_config.dart`
2. Change line 9:
```dart
static const String apiBaseUrl = "http://localhost:8080";
```

### For Physical Device (Android/iOS):
1. Find your computer's IP address (see above)
2. Open: `D:\Projects\yomehe\yoneco_app\lib\config\app_config.dart`
3. Change line 9:
```dart
static const String apiBaseUrl = "http://YOUR_IP_ADDRESS:8080";
```
Example: `static const String apiBaseUrl = "http://192.168.1.100:8080";`

**Important for Physical Devices:**
- Ensure your phone and computer are on the SAME Wi-Fi network
- Check your firewall allows incoming connections on port 8080

---

## Counsellor App Configuration

### For Android Emulator:
1. Open: `D:\Projects\yomehe\yoneco_counsellor_app\lib\config\app_config.dart`
2. Change line 9:
```dart
static const String apiBaseUrl = "http://10.0.2.2:8080";
```

### For iOS Simulator:
1. Open: `D:\Projects\yomehe\yoneco_counsellor_app\lib\config\app_config.dart`
2. Change line 9:
```dart
static const String apiBaseUrl = "http://localhost:8080";
```

### For Physical Device (Android/iOS):
1. Find your computer's IP address (see above)
2. Open: `D:\Projects\yomehe\yoneco_counsellor_app\lib\config\app_config.dart`
3. Change line 9:
```dart
static const String apiBaseUrl = "http://YOUR_IP_ADDRESS:8080";
```
Example: `static const String apiBaseUrl = "http://192.168.1.100:8080";`

---

## Testing on Different Platforms

### Android Emulator Testing

1. **Start Android Emulator:**
   - Open Android Studio
   - AVD Manager → Start your emulator

2. **Configure app** (use 10.0.2.2 as shown above)

3. **Run Client App:**
   ```bash
   cd D:\Projects\yomehe\yoneco_app
   flutter run
   ```

4. **Run Counsellor App** (in new terminal):
   ```bash
   cd D:\Projects\yomehe\yoneco_counsellor_app
   flutter run
   ```

### Physical Android Device Testing

1. **Enable Developer Options & USB Debugging:**
   - Settings → About Phone → Tap "Build Number" 7 times
   - Settings → Developer Options → Enable "USB Debugging"

2. **Connect device via USB**

3. **Verify device is connected:**
   ```bash
   flutter devices
   ```

4. **Configure app** (use your computer's IP address)

5. **Run the app:**
   ```bash
   cd D:\Projects\yomehe\yoneco_app
   flutter run
   ```

### iOS Simulator Testing (macOS only)

1. **Open Simulator:**
   ```bash
   open -a Simulator
   ```

2. **Configure app** (use localhost:8080)

3. **Run the app:**
   ```bash
   cd D:\Projects\yomehe\yoneco_app
   flutter run
   ```

### Physical iOS Device Testing (macOS only)

1. **Connect iPhone/iPad via USB**

2. **Trust the computer** (on device when prompted)

3. **Configure app** (use your Mac's IP address)

4. **Run with Xcode** (requires Apple Developer account):
   ```bash
   cd D:\Projects\yomehe\yoneco_app
   flutter run
   ```

---

## Troubleshooting

### Issue: "Failed to connect" or "Connection Timeout"

**Solutions:**
1. ✅ Verify API is running: `http://YOUR_IP:8080/docs`
2. ✅ Check both devices on same Wi-Fi network
3. ✅ Disable firewall temporarily (Windows Defender, etc.)
4. ✅ Verify correct IP address in app_config.dart
5. ✅ Restart the API with `--host 0.0.0.0`

### Issue: "ERR_CONNECTION_REFUSED"

**Solutions:**
1. ✅ API might not be running - start it
2. ✅ Wrong port number - verify 8080
3. ✅ Firewall blocking - allow port 8080

### Issue: Windows Firewall Blocking

**Allow Python through firewall:**
1. Windows Security → Firewall & Network Protection
2. Advanced Settings → Inbound Rules
3. New Rule → Port → TCP → 8080
4. Allow the connection → Give it a name

### Issue: Android Emulator Can't Connect

**Solutions:**
1. ✅ Use `10.0.2.2` NOT `localhost` or `127.0.0.1`
2. ✅ Restart emulator after changing config
3. ✅ Hot restart the Flutter app (press 'r' in terminal)

### Issue: WebSocket Errors

**Solutions:**
1. ✅ Ensure WebSocket library installed in API:
   ```bash
   pip install websockets
   ```
2. ✅ Restart API after installing
3. ✅ Check WebSocket URL uses `ws://` not `wss://`

---

## Quick Testing Workflow

### 1. Start API:
```bash
cd D:\Projects\yomehe\python_api
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

### 2. Configure Apps:
- Edit `app_config.dart` in both apps based on your testing platform

### 3. Run Client App:
```bash
cd D:\Projects\yomehe\yoneco_app
flutter run
```

### 4. Run Counsellor App (new terminal):
```bash
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run
```

### 5. Test Flow:
1. **Client App:** Select an issue → Create session
2. **Counsellor App:** Login → See pending sessions → Accept session
3. **Both:** Start chatting in real-time!

---

## Counsellor Login Credentials

Use these credentials to login to the Counsellor app:

**Email:** `dr.smith@yoneco.org`  
**Password:** `password123`

---

## Platform-Specific Configuration Summary

| Platform | API Base URL Configuration |
|----------|---------------------------|
| **Web (Chrome/Edge)** | `http://localhost:8080` |
| **Android Emulator** | `http://10.0.2.2:8080` |
| **iOS Simulator** | `http://localhost:8080` |
| **Physical Device** | `http://YOUR_IP:8080` (e.g., `http://192.168.1.100:8080`) |

---

## Need Help?

Common commands for debugging:

```bash
# Check connected devices
flutter devices

# Clean build
flutter clean
flutter pub get

# Run with verbose logging
flutter run -v

# Hot reload (while app is running)
Press 'r' in terminal

# Hot restart (while app is running)
Press 'R' in terminal
```

---

## Notes

- 🔒 For production, use HTTPS/WSS instead of HTTP/WS
- 📡 Physical devices MUST be on the same network as your computer
- 🔥 Disable firewall or create exceptions for port 8080
- 🔄 After changing `app_config.dart`, do a hot restart (press 'R')
- 💾 Remember to change config back to `localhost` for web testing

---

**Happy Testing! 🎉**
