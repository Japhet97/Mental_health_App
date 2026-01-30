# 🧪 Quick Test Guide - Tithandizane Helpline

## ✅ API is Running and Ready!

### Current Status
- **API URL:** http://102.223.95.28:8001
- **Status:** ✅ RUNNING
- **Database:** ✅ READY (with language support)
- **Branding:** ✅ Updated to Tithandizane Helpline

---

## 🚀 How to Test Now

### 1️⃣ **Start Testing the Client App**

```bash
# Navigate to client app
cd yoneco_app

# Run on connected device
flutter run
```

**Expected Flow:**
1. **Splash Screen** - See Tithandizane Helpline logo
2. **Language Selection** - Choose English or Chichewa (button inactive until selection)
3. **Welcome Screen** - See logo and "Welcome to Tithandizane"
4. **Issues Screen** - Select an issue (e.g., Anxiety)
5. **Counsellor Screen** - Enter your name
6. **Chat Screen** - Wait for counsellor

### 2️⃣ **Start Testing the Counsellor App**

```bash
# Navigate to counsellor app
cd yoneco_counsellor_app

# Run on connected device
flutter run
```

**Login Credentials:**
- Email: `counsellor1@yoneco.org`
- Password: `counsellor123`

**Expected Features:**
1. **Login Screen** - Sign in as counsellor
2. **Dashboard** - See pending/active sessions
3. **Pending Sessions** - See client's issue AND language 🌍
4. **Accept Session** - Join the chat
5. **Chat Screen** - Communicate with client

---

## 🧪 Test Scenarios

### Test 1: Language Selection Works
- [ ] Open client app
- [ ] Continue button is disabled initially
- [ ] Select a language
- [ ] Continue button becomes enabled
- [ ] Text changes to selected language

### Test 2: Logo Appears
- [ ] Logo shows on splash screen
- [ ] Logo shows on welcome screen
- [ ] No heart icons anywhere

### Test 3: Chatbot Removed
- [ ] Select an issue
- [ ] Goes directly to "Enter Name" screen
- [ ] No chatbot conversation screen

### Test 4: Language Sent to Counsellor
- [ ] Client selects Chichewa language
- [ ] Client creates session
- [ ] Counsellor sees "Language: Chichewa" 🌍 in pending session
- [ ] Language icon displayed in blue

### Test 5: Full Chat Flow
- [ ] Client creates session
- [ ] Counsellor receives notification
- [ ] Counsellor accepts session
- [ ] Both can send messages
- [ ] Typing indicators work
- [ ] Messages delivered in real-time

---

## 📱 Testing on Physical Device

### Prerequisites:
1. **Same Wi-Fi:** Computer and phone on same network
2. **Firewall:** Run `.\add-firewall-rules.ps1` (as Admin)
3. **API Running:** Terminal shows "Uvicorn running on http://0.0.0.0:8001"

### Test Connection from Phone:
1. Open phone browser
2. Visit: `http://102.223.95.28:8001`
3. Should see JSON response with "Tithandizane Helpline"

### If Connection Fails:
```powershell
# Check your current IP
ipconfig

# Look for "IPv4 Address"
# Update both app configs if IP changed
```

---

## 🔍 Monitoring the API

Watch the API terminal for logs:
```
INFO: 102.223.95.28:xxxxx - "GET / HTTP/1.1" 200 OK
INFO: Starting Tithandizane Helpline Backend API...
INFO: Session monitor started
```

---

## 🎯 What to Look For

### ✅ Success Indicators:
- Logo displays correctly
- "Tithandizane Helpline" appears everywhere
- Language selection is mandatory
- Counsellor sees client's language preference
- No chatbot screen in flow
- Real-time messaging works
- WebSocket notifications arrive

### ❌ Common Issues:
- **"Connection refused"** → API not running or wrong IP
- **Firewall prompt** → Allow access when prompted
- **No logo** → Run `flutter pub get` in app directory
- **Language not showing** → Clear app data and restart

---

## 📊 Database Check (Optional)

```bash
cd python_api
.\venv\Scripts\python.exe

# In Python console:
import sqlite3
conn = sqlite3.connect('yoneco.db')
cursor = conn.cursor()

# Check sessions table
cursor.execute("PRAGMA table_info(sessions)")
for row in cursor.fetchall():
    print(row)

# Look for 'language' column
```

---

## 🎉 Ready to Test!

**Everything is configured and running.** Just:
1. Make sure API terminal is open and running
2. Connect your devices to the same Wi-Fi
3. Run the Flutter apps
4. Test the complete flow!

**Happy Testing!** 🚀

---

## 📞 Need Help?

Check these files:
- `API_CONNECTION_GUIDE.md` - Detailed connection setup
- `API_FIXED_AND_READY.md` - Quick reference
- API logs in the terminal window
