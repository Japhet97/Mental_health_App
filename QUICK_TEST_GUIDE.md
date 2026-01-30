# Quick Testing Guide - New Features

## 🚀 Quick Start (5 Minutes)

### Step 1: Start the API (30 seconds)
```bash
cd D:\Projects\yomehe\python_api
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

### Step 2: Start Client App (30 seconds)
```bash
cd D:\Projects\yomehe\yoneco_app
flutter run -d chrome --web-port=8081
```

### Step 3: Start Counsellor App (30 seconds)
```bash
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run -d chrome --web-port=8082
```

---

## ✨ Test New Features (3 Minutes)

### 1️⃣ **Language Selection** (30 seconds)
**Client App**:
- [ ] Launch → See language selection
- [ ] Select "Chichewa"
- [ ] Click "Pitirizani"
- [ ] Verify all text is in Chichewa

### 2️⃣ **End-to-End Encryption Indicator** (15 seconds)
**Both Apps**:
- [ ] Open chat session
- [ ] Look for **green banner** at top
- [ ] Should say "Messages are end-to-end encrypted" with 🔒 icon

### 3️⃣ **Session Timer** (15 seconds)
**Both Apps**:
- [ ] Open chat session
- [ ] Look at **AppBar** below session title
- [ ] Should see timer: `00:01`, `00:02`, etc.
- [ ] Verify it increments every second

### 4️⃣ **Typing Indicators** (1 minute)
**Client App**:
- [ ] Open chat session
- [ ] Start typing in message box
- [ ] **Don't send** - just type

**Counsellor App**:
- [ ] Should see "Client is typing..." with animated dots (●●●)
- [ ] When client stops, indicator disappears after 2 seconds

**Reverse Test**:
- [ ] Counsellor types
- [ ] Client sees "Counsellor is typing..." (or "Mlangizi akulemba..." in Chichewa)

---

## 🎯 Full Workflow Test (5 Minutes)

### **Client Side**:
1. Launch app → Select "English"
2. Select issue: "Depression"
3. Wait on chat screen
4. **See**:
   - ✅ Green encryption banner
   - ✅ Timer starting (00:01, 00:02...)
   - ✅ Orange "Waiting for counsellor" banner

### **Counsellor Side**:
1. Launch app → Login:
   - Email: `dr.smith@yoneco.org`
   - Password: `SecurePass123!`
2. See pending session
3. Click "Accept"
4. **See**:
   - ✅ Green encryption banner
   - ✅ Timer starting
   - ✅ No "waiting" banner

### **Chat Test**:
5. **Client**: Type "Hello" → **Counsellor sees typing indicator**
6. **Client**: Send message → **Appears on counsellor instantly**
7. **Counsellor**: Type "How can I help?" → **Client sees typing indicator**
8. **Counsellor**: Send → **Appears on client instantly**
9. **Both**: Timers should match (±1 second)

---

## 📱 Language Test (2 Minutes)

### Test Chichewa:
**Client App**:
- [ ] Select "Chichewa" on language screen
- [ ] Welcome screen: "Takulandirani ku YONECO"
- [ ] Issues screen: "Tingakuthandizeni bwanji?"
- [ ] Depression: "Kukhumudwa"
- [ ] Anxiety: "Nkhawa"
- [ ] Chat screen: "Mlangizi" instead of "Counsellor"
- [ ] Typing indicator: "Mlangizi akulemba..."

### Test Persistence:
- [ ] Close app
- [ ] Reopen app
- [ ] Should still be in Chichewa

---

## 🐛 What to Look For

### ✅ **Should Work**:
- Messages appear instantly on both sides
- Typing indicators show/hide correctly
- Timer increments every second
- Green encryption banner always visible
- Language persists after restart
- No login required for clients

### ❌ **Known Issues** (Expected):
- Counsellor may need to refresh to see new messages (WebSocket limitation)
- Typing indicator might be delayed by 1-2 seconds
- Timer might be off by ±1 second between client/counsellor

---

## 🎨 Visual Checklist

### Client Chat Screen Should Show:
```
┌─────────────────────────────────────┐
│  ← Counsellor Chat        00:05     │ ← Timer in AppBar
├─────────────────────────────────────┤
│ 🔒 Messages are end-to-end encrypted│ ← Green banner
├─────────────────────────────────────┤
│                                      │
│  [Messages here...]                  │
│                                      │
│  ●●● Counsellor is typing...        │ ← When typing
│                                      │
├─────────────────────────────────────┤
│ [Type a message...]         [Send]  │
└─────────────────────────────────────┘
```

### Counsellor Chat Screen Should Show:
```
┌─────────────────────────────────────┐
│  ← Chat Session           00:05  [X]│ ← Timer + Close
├─────────────────────────────────────┤
│ 🔒 Messages are end-to-end encrypted│ ← Green banner
├─────────────────────────────────────┤
│                                      │
│  [Messages here...]                  │
│                                      │
│  ●●● Client is typing...            │ ← When typing
│                                      │
├─────────────────────────────────────┤
│ [Type your message...]      [Send]  │
└─────────────────────────────────────┘
```

---

## 🔧 Quick Fixes

### WebSocket Not Connecting?
```bash
# Install WebSocket support
pip install websockets

# Restart API
cd D:\Projects\yomehe\python_api
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

### Typing Indicators Not Showing?
1. Check WebSocket connection in browser console
2. Refresh both apps
3. Accept a new session

### Timer Not Starting?
1. Clear browser cache
2. Hard refresh (Ctrl+Shift+R)
3. Restart apps

### Language Not Changing?
1. Clear app data
2. Uninstall and reinstall
3. Or manually delete SharedPreferences

---

## 📊 Success Criteria

All features working if:
- ✅ Can select language and it persists
- ✅ Green encryption banner shows on both apps
- ✅ Timer runs and increments every second
- ✅ Typing indicators appear when typing
- ✅ Messages send/receive in real-time
- ✅ No login required for clients
- ✅ Counsellor can login and accept sessions

---

## 🎯 Next Steps After Testing

If everything works:
1. Test on Android device (see COMPLETE_FEATURES_GUIDE.md)
2. Test with multiple concurrent sessions
3. Test session closure
4. Test network interruption recovery
5. Gather user feedback

If issues found:
1. Check browser console (F12)
2. Check API terminal logs
3. Check database: `D:\Projects\yomehe\python_api\yoneco.db`
4. Review COMPLETE_FEATURES_GUIDE.md for detailed troubleshooting

---

## 📞 Quick Reference

**API**: http://localhost:8080/docs
**Client**: http://localhost:8081
**Counsellor**: http://localhost:8082

**Counsellor Login**:
- Email: `dr.smith@yoneco.org`
- Password: `SecurePass123!`

**Language Codes**:
- English: `en`
- Chichewa: `ny`

---

**Test Duration**: ~10 minutes total
**Status**: All features implemented ✅
**Last Updated**: November 2, 2025
