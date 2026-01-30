# 🎯 YONECO - Start Here!

## What is YONECO?

YONECO is a mental health support system that connects people in need with professional counsellors through real-time chat.

---

## 📱 What You Have

1. **Client App** (`yoneco_app`) - For people seeking mental health support
   - No login needed
   - Select issue → Talk to counsellor
   - Anonymous and private

2. **Counsellor App** (`yoneco_counsellor_app`) - For mental health professionals
   - Secure login
   - Accept client sessions
   - Chat with multiple clients

3. **Python API** (`python_api`) - Backend that handles everything
   - Manages sessions
   - Routes messages
   - Real-time WebSocket communication

---

## 🚀 How to Test (3 Simple Steps)

### Step 1: Start the API
```bash
cd D:\Projects\yomehe\python_api
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```
✅ Leave this running

---

### Step 2: Choose Your Testing Platform

Click the option that applies to you:

#### 🌐 Option A: Testing on Web Browser (Recommended for First Test)
```bash
# Run this (no configuration needed)
cd D:\Projects\yomehe\yoneco_app
flutter run -d chrome
```
Then in a new terminal:
```bash
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run -d chrome
```

#### 📱 Option B: Testing on Android Emulator
```bash
# First, configure
cd D:\Projects\yomehe
.\configure-mobile.ps1 -Platform android-emulator

# Then run apps
cd yoneco_app
flutter run
# (Select Android emulator when prompted)
```
New terminal:
```bash
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run
```

#### 📱 Option C: Testing on Physical Phone
```bash
# First, find your computer's IP address
ipconfig
# Look for "IPv4 Address" - it looks like 192.168.X.X

# Configure with YOUR IP (example: 192.168.1.100)
cd D:\Projects\yomehe
.\configure-mobile.ps1 -Platform physical-device -IpAddress YOUR_IP_HERE

# Then run apps
cd yoneco_app
flutter run
# (Select your phone when prompted)
```
New terminal:
```bash
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run
```



---

### Step 3: Test It!

**On Client App:**
1. You'll see a welcome splash screen
2. Select a mental health issue (e.g., "Depression")
3. Tap "Talk to a Counsellor"
4. Wait for counsellor to accept

**On Counsellor App:**
1. Login with:
   - Email: `dr.smith@yoneco.org`
   - Password: `password123`
2. You'll see the pending session
3. Tap to accept it
4. Start chatting!

**Both Apps:**
- Send messages back and forth
- Watch them appear in real-time
- No refresh needed! 🎉

---

## ⚠️ Having Issues?

### "Connection Failed" Error?
1. Make sure API is running (Step 1)
2. If using physical phone:
   - Are phone and computer on same Wi-Fi?
   - Did you use the correct IP address?
   - Try disabling Windows Firewall temporarily

### "WebSocket Error"?
```bash
cd D:\Projects\yomehe\python_api
pip install websockets
# Then restart the API
```

### Android Emulator Not Connecting?
```bash
# Make sure you configured it
cd D:\Projects\yomehe
.\configure-mobile.ps1 -Platform android-emulator
# Then press 'R' (capital R) in the Flutter terminal
```

### After Changing Configuration?
Press `R` (capital R) in the Flutter terminal to hot restart the app

---

## 📚 Need More Help?

We have detailed guides for everything:

- **Quick Setup:** `QUICK_MOBILE_SETUP.md` - 2-minute reference
- **Complete Guide:** `COMPLETE_MOBILE_SETUP.md` - Everything you need
- **Mobile Testing:** `MOBILE_TESTING_GUIDE.md` - Detailed platform guide
- **Examples:** `CONFIGURATION_EXAMPLES.md` - Config examples

---

## 🎯 Quick Commands Reference

```bash
# Find your IP (for physical device)
ipconfig

# Configure for web
.\configure-mobile.ps1 -Platform web

# Configure for Android emulator
.\configure-mobile.ps1 -Platform android-emulator

# Configure for physical device (replace IP)
.\configure-mobile.ps1 -Platform physical-device -IpAddress 192.168.1.100

# Start API
cd python_api
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080

# Run client app
cd yoneco_app
flutter run

# Run counsellor app
cd yoneco_counsellor_app
flutter run

# Hot restart app
Press 'R' in Flutter terminal

# See all connected devices
flutter devices
```

---

## ✨ System Features

### Client App:
- ✅ Beautiful, calming UI
- ✅ No login required
- ✅ Anonymous support
- ✅ Real-time chat
- ✅ Multiple mental health issues to choose from

### Counsellor App:
- ✅ Secure authentication
- ✅ Manage multiple sessions
- ✅ Real-time notifications
- ✅ Professional interface
- ✅ Active and pending session management

### Backend:
- ✅ RESTful API
- ✅ WebSocket real-time communication
- ✅ Session management
- ✅ Anonymous client support
- ✅ Secure counsellor authentication

---

## 🎨 What's Included

```
yoneco_app/                    Client App (for people seeking help)
├── lib/config/app_config.dart   ← Change this for your platform
├── lib/screens/                 Splash, Welcome, Issues, Chat
└── lib/services/                API communication

yoneco_counsellor_app/         Counsellor App (for professionals)
├── lib/config/app_config.dart   ← Change this for your platform
├── lib/screens/                 Login, Pending/Active Sessions, Chat
└── lib/services/                API communication, Authentication

python_api/                     Backend API
├── main.py                      FastAPI application
├── requirements.txt             Dependencies
└── database/                    SQLite database

configure-mobile.ps1            Easy configuration script
```

---

## 🚀 First Time? Start Here:

1. **Test on web first** (easiest):
   ```bash
   # Terminal 1
   cd D:\Projects\yomehe\python_api
   python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
   
   # Terminal 2
   cd D:\Projects\yomehe\yoneco_app
   flutter run -d chrome
   
   # Terminal 3
   cd D:\Projects\yomehe\yoneco_counsellor_app
   flutter run -d chrome
   ```

2. **Login to counsellor app:**
   - Email: `dr.smith@yoneco.org`
   - Password: `password123`

3. **Create session in client app:**
   - Select any issue
   - Tap "Talk to a Counsellor"

4. **Accept in counsellor app:**
   - See pending session
   - Tap to accept
   - Start chatting!

5. **Once working on web, try mobile:**
   - Follow "Step 2" above for your mobile platform
   - Use the configuration script
   - Enjoy testing on mobile! 📱

---

## 🎉 You're Ready!

Everything is set up and ready to test. Start with web browser testing (easiest), then move to mobile when you're comfortable.

**Questions?** Check the detailed guides mentioned above.

**Happy Testing! 🚀**

---

*Made with ❤️ for YONECO Mental Health Support*
