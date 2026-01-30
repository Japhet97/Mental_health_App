# 📱 Configuration Examples for Different Platforms

## File to Edit:
Both apps have the same configuration file:
- **Client App:** `yoneco_app\lib\config\app_config.dart`
- **Counsellor App:** `yoneco_counsellor_app\lib\config\app_config.dart`

---

## 🌐 Web Browser (Chrome, Edge, Firefox)

```dart
class AppConfig {
  static const String apiBaseUrl = "http://localhost:8080";
  
  // ... rest of the file stays the same
}
```

**Use Case:** Testing on Chrome during development

---

## 📱 Android Emulator

```dart
class AppConfig {
  static const String apiBaseUrl = "http://10.0.2.2:8080";
  
  // ... rest of the file stays the same
}
```

**Why 10.0.2.2?** This is Android Emulator's special address that points to your computer's localhost.

**Use Case:** Testing on Android Virtual Device (AVD)

---

## 📱 iOS Simulator (macOS only)

```dart
class AppConfig {
  static const String apiBaseUrl = "http://localhost:8080";
  
  // ... rest of the file stays the same
}
```

**Use Case:** Testing on iPhone/iPad Simulator

---

## 📱 Physical Android/iOS Device

### Example 1 - Home Wi-Fi
```dart
class AppConfig {
  static const String apiBaseUrl = "http://192.168.1.100:8080";
  
  // ... rest of the file stays the same
}
```

### Example 2 - Office Wi-Fi
```dart
class AppConfig {
  static const String apiBaseUrl = "http://10.0.0.45:8080";
  
  // ... rest of the file stays the same
}
```

### Example 3 - Hotspot
```dart
class AppConfig {
  static const String apiBaseUrl = "http://192.168.43.1:8080";
  
  // ... rest of the file stays the same
}
```

**How to find YOUR IP:**
```bash
# Windows
ipconfig

# macOS/Linux
ifconfig
# or
ip addr show
```

**Requirements:**
- ✅ Phone and computer on SAME Wi-Fi network
- ✅ Firewall allows connections on port 8080
- ✅ API started with `--host 0.0.0.0`

---

## 🚀 Quick Change Script

Instead of manually editing files, use the helper script:

```powershell
# For Web
.\configure-mobile.ps1 -Platform web

# For Android Emulator
.\configure-mobile.ps1 -Platform android-emulator

# For iOS Simulator
.\configure-mobile.ps1 -Platform ios-simulator

# For Physical Device (replace with your IP)
.\configure-mobile.ps1 -Platform physical-device -IpAddress 192.168.1.100
```

---

## 🔍 Verify Configuration

After changing, verify the URL is correct:

1. **Start API:**
   ```bash
   python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
   ```

2. **Test in Browser:**
   - Web/iOS Simulator: `http://localhost:8080/docs`
   - Physical Device: `http://YOUR_IP:8080/docs` (e.g., http://192.168.1.100:8080/docs)
   - Android Emulator: Can't test in browser, but should work in app

3. **Run App:**
   ```bash
   cd yoneco_app  # or yoneco_counsellor_app
   flutter run
   ```

4. **Hot Restart:**
   After changing config, press `R` (capital R) in the terminal running Flutter

---

## 🐛 Debugging Tips

**Check Current Configuration:**
Look at line 9 in:
- `D:\Projects\yomehe\yoneco_app\lib\config\app_config.dart`
- `D:\Projects\yomehe\yoneco_counsellor_app\lib\config\app_config.dart`

**Test API Accessibility:**
```bash
# From your computer
curl http://localhost:8080/docs

# From another device (if using physical device)
curl http://YOUR_IP:8080/docs
```

**Common Mistakes:**
- ❌ Using `localhost` on Android Emulator (use `10.0.2.2`)
- ❌ Wrong IP address for physical device
- ❌ Not on same Wi-Fi network
- ❌ Firewall blocking port 8080
- ❌ API not started with `--host 0.0.0.0`

---

## 📝 Platform-Specific Notes

### Android Emulator:
- MUST use `10.0.2.2:8080`
- `localhost` and `127.0.0.1` will NOT work
- Restart emulator if connection issues persist

### iOS Simulator:
- Can use `localhost:8080`
- Only works on macOS
- Make sure Xcode is installed

### Physical Devices:
- MUST be on same Wi-Fi as computer
- Computer firewall must allow port 8080
- Use actual IP address, not localhost
- To test, open `http://YOUR_IP:8080/docs` in phone's browser first

### Web:
- Use `localhost:8080`
- Works on any OS
- Good for development and testing

---

**Remember:** After editing `app_config.dart`, always do a hot restart (press 'R') in the Flutter terminal! 🔄
