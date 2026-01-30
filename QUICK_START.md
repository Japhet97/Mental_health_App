# 🚀 YONECO Quick Start Guide

## Run Everything in 3 Steps

### 1️⃣ Start the API (Terminal 1)
```bash
cd D:\Projects\yomehe\python_api
python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```
**✓ Success**: See "Uvicorn running on http://0.0.0.0:8080"

---

### 2️⃣ Login Credentials (Already Created!)

**Counsellor Logins Available:**

| Email | Password |
|-------|----------|
| dr.smith@yoneco.org | DrSmith123 |
| dr.jones@yoneco.org | DrJones123 |
| dr.wilson@yoneco.org | DrWilson123 |
| dr.brown@yoneco.org | DrBrown123 |
| dr.davis@yoneco.org | DrDavis123 |
| counsellor@yoneco.org | counsellor123 |

**Use any of these to login!**

---

### 3️⃣ Run Both Apps (Terminals 2 & 3)

**Terminal 2 - Counsellor App:**
```bash
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run -d chrome
```

**Terminal 3 - Client App:**
```bash
cd D:\Projects\yomehe\yoneco_app
flutter run -d chrome
```

---

## 🧪 Test the Complete Flow

### On CLIENT APP:
1. ✅ Select mental health issue (e.g., "Depression")
2. ✅ Click the issue card
3. ✅ Automatically navigate to chat
4. ✅ Type message: "I need help"
5. ✅ Send and wait for counsellor...

### On COUNSELLOR APP:
1. ✅ Login (use: `dr.smith@yoneco.org` / `DrSmith123`)
2. ✅ See pending session notification
3. ✅ Click "Accept" on the session
4. ✅ See client's issue and message
5. ✅ Type response: "I'm here to help"
6. ✅ Start conversing!

### Both Apps:
- ✅ Messages appear in real-time
- ✅ WebSocket connection active
- ✅ Full bidirectional chat working!

---

## 📂 Key Files

```
python_api/
├── main.py           ← API entry point
├── yoneco.db         ← Database (auto-created)
└── create_counsellor.py   ← Create accounts

yoneco_app/
└── lib/main.dart     ← Client app entry

yoneco_counsellor_app/
└── lib/main.dart     ← Counsellor app entry
```

---

## 🔍 Verify Everything Works

### Check API is Running
```bash
# Open browser
http://localhost:8000/docs
```
**✓ Should see**: Swagger API documentation

### Check Database
```bash
cd python_api
sqlite3 yoneco.db
SELECT * FROM counsellors;
SELECT * FROM sessions;
.quit
```

### Check Sessions Endpoint
```bash
# In browser or Postman
GET http://localhost:8000/sessions/pending
```
**✓ Should see**: JSON list of sessions

---

## ⚡ Quick Commands

```bash
# Install Python packages
pip install fastapi uvicorn sqlalchemy bcrypt pyjwt python-dotenv

# Install Flutter packages (both apps)
flutter pub get

# Run API
uvicorn main:app --reload

# Run Flutter app
flutter run

# Hot reload Flutter (while running)
r    # hot reload
R    # hot restart
q    # quit

# Check Flutter devices
flutter devices
```

---

## 🎯 Success Indicators

### API Running ✅
- Terminal shows: "Application startup complete"
- Browser: http://localhost:8000/docs loads

### Client App Running ✅
- App opens to welcome screen
- Can navigate to issues screen
- Can create session

### Counsellor App Running ✅
- Login screen appears
- Can login successfully
- Dashboard shows statistics

### Full Flow Working ✅
- Client creates session
- Counsellor sees notification
- Both can chat in real-time
- Messages sync instantly

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| API won't start | Install dependencies: `pip install -r requirements.txt` |
| Can't create counsellor | Check `create_counsellor.py` exists |
| Flutter errors | Run `flutter doctor` and fix issues |
| Can't connect to API | Use `10.0.2.2:8000` for Android emulator |
| No sessions showing | Create one from client app first |
| WebSocket fails | Check firewall, verify API is running |

---

## 📖 Full Documentation

- **COMPLETE_SYSTEM.md** - Full system overview
- **IMPLEMENTATION_SUMMARY.md** - What was built
- **SETUP_GUIDE.md** - Detailed setup instructions
- **ARCHITECTURE.md** - System design diagrams
- **COUNSELLOR_APP_GUIDE.md** - Counsellor app guide

---

## 🎊 You're All Set!

The complete YONECO mental health support system is ready for testing.

**Have fun building mental health support! 💚**
