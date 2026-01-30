# 🎯 YONECO Complete Mobile Testing Setup

## 📋 Overview

You have successfully set up the YONECO Mental Health Support System with:
- ✅ Client App (for people seeking help)
- ✅ Counsellor App (for mental health counsellors)
- ✅ Python API Backend (handles all logic)
- ✅ Real-time chat with WebSocket support
- ✅ Anonymous client access (no login required)
- ✅ Secure counsellor authentication

---

## 🚀 Quick Start - Choose Your Platform

### Option 1: Test on Web Browser (Easiest)
```bash
# Terminal 1: Start API
cd D:\Projects\yomehe\python_api
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080

# Terminal 2: Run Client App
cd D:\Projects\yomehe\yoneco_app
flutter run -d chrome

# Terminal 3: Run Counsellor App
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run -d chrome
```

### Option 2: Test on Android Emulator
```bash
# 1. Configure for Android
cd D:\Projects\yomehe
.\configure-mobile.ps1 -Platform android-emulator

# 2. Start API
cd python_api
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080

# 3. Start Android Emulator (from Android Studio)

# 4. Run Client App
cd ..\yoneco_app
flutter run

# 5. Run Counsellor App (new terminal)
cd ..\yoneco_counsellor_app
flutter run
```

### Option 3: Test on Physical Device
```bash
# 1. Find your computer's IP
ipconfig  # Windows (look for IPv4 Address)

# 2. Configure for your IP (replace with your actual IP)
cd D:\Projects\yomehe
.\configure-mobile.ps1 -Platform physical-device -IpAddress 192.168.1.100

# 3. Start API
cd python_api
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080

# 4. Connect phone via USB or ensure on same Wi-Fi

# 5. Run Client App
cd ..\yoneco_app
flutter run

# 6. Run Counsellor App (new terminal)
cd ..\yoneco_counsellor_app
flutter run
```

---

## 🔑 Default Credentials

### Counsellor Login:
- **Email:** `dr.smith@yoneco.org`
- **Password:** `password123`

### Client App:
- No login required! Just select an issue and start chatting.

---

## 📱 Platform Configuration Reference

| Platform | Configuration Command |
|----------|----------------------|
| **Web Browser** | `.\configure-mobile.ps1 -Platform web` |
| **Android Emulator** | `.\configure-mobile.ps1 -Platform android-emulator` |
| **iOS Simulator** | `.\configure-mobile.ps1 -Platform ios-simulator` |
| **Physical Device** | `.\configure-mobile.ps1 -Platform physical-device -IpAddress YOUR_IP` |

---

## 🧪 Testing Workflow

### Step-by-Step Test:

1. **Start the API:**
   ```bash
   cd D:\Projects\yomehe\python_api
   python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
   ```
   ✅ You should see: `Uvicorn running on http://0.0.0.0:8080`

2. **Verify API is accessible:**
   - Open browser: `http://localhost:8080/docs`
   - You should see the API documentation

3. **Configure apps for your platform** (use script above)

4. **Run Client App:**
   ```bash
   cd D:\Projects\yomehe\yoneco_app
   flutter run
   ```
   Select your device when prompted

5. **Run Counsellor App (new terminal):**
   ```bash
   cd D:\Projects\yomehe\yoneco_counsellor_app
   flutter run
   ```
   Select your device when prompted

6. **Test the Flow:**
   
   **On Client App:**
   - You'll see a splash screen, then welcome screen
   - Tap any mental health issue (e.g., "Depression")
   - Tap "Talk to a Counsellor"
   - Wait for a counsellor to accept

   **On Counsellor App:**
   - Login with credentials above
   - You'll see the pending session
   - Tap to accept the session
   - Start chatting!

   **Both Apps:**
   - Messages appear in real-time
   - No refresh needed
   - Full bidirectional chat

---

## 🎨 App Features

### Client App:
- ✅ Beautiful splash screen
- ✅ No login required (anonymous)
- ✅ Select mental health issue
- ✅ Real-time chat with counsellor
- ✅ Clean, calming UI with forest green theme

### Counsellor App:
- ✅ Secure login
- ✅ See pending sessions
- ✅ Accept and manage sessions
- ✅ Real-time chat with multiple clients
- ✅ Professional UI

---

## 🛠️ Manual Configuration (Alternative)

If you prefer to edit files manually instead of using the script:

**Files to Edit:**
1. `D:\Projects\yomehe\yoneco_app\lib\config\app_config.dart`
2. `D:\Projects\yomehe\yoneco_counsellor_app\lib\config\app_config.dart`

**Change line 9 in both files:**

```dart
// For Web
static const String apiBaseUrl = "http://localhost:8080";

// For Android Emulator
static const String apiBaseUrl = "http://10.0.2.2:8080";

// For iOS Simulator
static const String apiBaseUrl = "http://localhost:8080";

// For Physical Device (replace with your IP)
static const String apiBaseUrl = "http://192.168.1.100:8080";
```

**After editing:** Press `R` in the Flutter terminal to hot restart

---

## 🐛 Troubleshooting

### Problem: "Connection Timeout" or "Failed to Connect"

**Solution Checklist:**
- [ ] Is the API running? Check `http://localhost:8080/docs`
- [ ] Is the correct IP in `app_config.dart`?
- [ ] For physical device: Are phone and computer on same Wi-Fi?
- [ ] Is Windows Firewall blocking? Try disabling temporarily
- [ ] Did you restart the app after changing config? (Press 'R')

### Problem: "WebSocket Error"

**Solution:**
```bash
# Install WebSocket support in API
cd D:\Projects\yomehe\python_api
pip install websockets
# Restart the API
```

### Problem: Android Emulator "Connection Refused"

**Solution:**
- MUST use `10.0.2.2:8080`, not `localhost:8080`
- Run the configuration script:
  ```bash
  .\configure-mobile.ps1 -Platform android-emulator
  ```
- Press 'R' in Flutter terminal to hot restart

### Problem: "Not Authenticated" in Counsellor App

**Solution:**
- Make sure you're logged in
- Check credentials: `dr.smith@yoneco.org` / `password123`
- If still failing, logout and login again

### Problem: Messages Not Appearing in Real-Time

**Solution:**
- Check WebSocket connection (look for errors in console)
- Ensure API is running with WebSocket support
- Try accepting a new session

---

## 📂 Project Structure

```
D:\Projects\yomehe\
├── python_api/              # Backend API
│   ├── main.py
│   ├── requirements.txt
│   └── ...
├── yoneco_app/              # Client App
│   └── lib/
│       ├── config/
│       │   └── app_config.dart  ← Edit this for platform
│       ├── screens/
│       └── services/
├── yoneco_counsellor_app/   # Counsellor App
│   └── lib/
│       ├── config/
│       │   └── app_config.dart  ← Edit this for platform
│       ├── screens/
│       └── services/
└── configure-mobile.ps1     # Configuration helper script
```

---

## 🌐 Useful Commands

```bash
# Check Flutter devices
flutter devices

# Run on specific device
flutter run -d chrome          # Web
flutter run -d <device-id>     # Specific device

# Hot reload (small changes)
Press 'r' in terminal

# Hot restart (bigger changes, after config change)
Press 'R' in terminal

# Clean build
flutter clean
flutter pub get
flutter run

# Check API logs
# Look at the terminal running uvicorn

# Find your IP
ipconfig                       # Windows
ifconfig                       # Mac/Linux
```

---

## 📚 Additional Resources

- **Detailed Mobile Guide:** `MOBILE_TESTING_GUIDE.md`
- **Quick Reference:** `QUICK_MOBILE_SETUP.md`
- **Config Examples:** `CONFIGURATION_EXAMPLES.md`
- **System Architecture:** `ARCHITECTURE.md`
- **API Documentation:** http://localhost:8080/docs (when API is running)

---

## 🎯 Production Considerations

Before deploying to production:

1. **Security:**
   - Change default passwords
   - Use HTTPS instead of HTTP
   - Use WSS instead of WS for WebSockets
   - Add rate limiting
   - Implement proper authentication tokens

2. **Database:**
   - Currently using SQLite (file-based)
   - Consider PostgreSQL or MySQL for production
   - Implement proper migrations

3. **Hosting:**
   - Deploy API to a cloud server (AWS, Azure, DigitalOcean)
   - Get a domain name
   - Set up SSL certificates
   - Update `app_config.dart` with production URLs

4. **App Deployment:**
   - Build release versions:
     ```bash
     flutter build apk          # Android
     flutter build ios          # iOS
     flutter build web          # Web
     ```
   - Submit to Google Play Store (Android)
   - Submit to Apple App Store (iOS)
   - Deploy web version to hosting

---

## ✅ Testing Checklist

- [ ] API starts successfully
- [ ] Can access API docs at http://localhost:8080/docs
- [ ] Client app runs on chosen platform
- [ ] Counsellor app runs on chosen platform
- [ ] Can login to counsellor app
- [ ] Can create session from client app
- [ ] Pending session appears in counsellor app
- [ ] Can accept session from counsellor app
- [ ] Messages sent from client appear in counsellor app
- [ ] Messages sent from counsellor appear in client app
- [ ] Real-time updates work (no manual refresh needed)
- [ ] Can close session

---

## 🎉 Success!

If you've completed the testing checklist, your YONECO Mental Health Support System is working perfectly!

**What you've built:**
- 📱 Two beautiful Flutter apps
- 🔧 A powerful Python API
- 💬 Real-time chat system
- 🔒 Secure authentication
- 🌍 Multi-platform support (Web, Android, iOS)
- 🎨 Professional, calming UI design

**Need help?** Check the troubleshooting section or the detailed guides in the other markdown files.

---

**Happy Testing! 🚀**
