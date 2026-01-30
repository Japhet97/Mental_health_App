# 🚀 Quick Mobile Setup Reference

## 1️⃣ Find Your Computer's IP

**Windows:**
```bash
ipconfig
```
Look for "IPv4 Address" (e.g., 192.168.1.100)

**Mac/Linux:**
```bash
ifconfig
```

---

## 2️⃣ Start API for Mobile Access

```bash
cd D:\Projects\yomehe\python_api
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

---

## 3️⃣ Configure Apps Based on Platform

### 📱 Android Emulator:
**Edit:** `lib\config\app_config.dart` in BOTH apps
```dart
static const String apiBaseUrl = "http://10.0.2.2:8080";
```

### 📱 iOS Simulator:
**Edit:** `lib\config\app_config.dart` in BOTH apps
```dart
static const String apiBaseUrl = "http://localhost:8080";
```

### 📱 Physical Device (Android/iOS):
**Edit:** `lib\config\app_config.dart` in BOTH apps
```dart
static const String apiBaseUrl = "http://YOUR_IP_ADDRESS:8080";
```
Replace `YOUR_IP_ADDRESS` with your actual IP (e.g., 192.168.1.100)

---

## 4️⃣ Run Apps

**Terminal 1 - Client App:**
```bash
cd D:\Projects\yomehe\yoneco_app
flutter run
```

**Terminal 2 - Counsellor App:**
```bash
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run
```

---

## 5️⃣ Test Login

**Counsellor Credentials:**
- Email: `dr.smith@yoneco.org`
- Password: `password123`

---

## ⚠️ Common Issues

**"Connection Failed"?**
- ✅ Check API is running on `0.0.0.0:8080`
- ✅ Phone & computer on SAME Wi-Fi
- ✅ Correct IP in `app_config.dart`
- ✅ Disable Windows Firewall temporarily

**Android Emulator not connecting?**
- ✅ MUST use `10.0.2.2` NOT `localhost`

**After changing config?**
- ✅ Press 'R' (capital R) in terminal for hot restart

---

## 📂 Config File Locations

**Client App:**
`D:\Projects\yomehe\yoneco_app\lib\config\app_config.dart`

**Counsellor App:**
`D:\Projects\yomehe\yoneco_counsellor_app\lib\config\app_config.dart`

---

## 🎯 Testing Flow

1. Start API ✅
2. Configure apps for your platform ✅
3. Run both apps ✅
4. Client: Select issue → Create session
5. Counsellor: Login → Accept session
6. Chat in real-time! 💬

---

**Need detailed help?** See `MOBILE_TESTING_GUIDE.md`
