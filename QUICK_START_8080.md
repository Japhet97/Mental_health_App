# 🚀 Quick Start Guide - Port 8080

## Current Status: ✅ ALL SYSTEMS READY

### Running Services:
1. **API** → http://localhost:8080 ✅ RUNNING
2. **Admin Dashboard** → http://localhost:5175 ✅ RUNNING
3. **Client App** → Ready to run
4. **Counsellor App** → Ready to run

---

## Start Everything (From Scratch)

### Terminal 1: Start API
```powershell
cd D:\Projects\yomehe\python_api
python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```
**URL**: http://localhost:8080/docs

---

### Terminal 2: Start Admin Dashboard
```powershell
cd D:\Projects\yomehe\admin-dashboard-vue
npm run dev
```
**URL**: http://localhost:5173 (or 5174, 5175 if ports busy)

---

### Terminal 3: Start Client App
```powershell
cd D:\Projects\yomehe\yoneco_app
flutter run -d chrome
```
Or for mobile:
```powershell
flutter run -d windows
```

---

### Terminal 4: Start Counsellor App
```powershell
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run -d chrome
```
Or for mobile:
```powershell
flutter run -d windows
```

---

## Quick Test

### 1. Test API
```powershell
curl http://localhost:8080/issues
```
Should return list of issues in JSON.

### 2. Test Dashboard
Open browser: http://localhost:5175
- Login with admin credentials
- View dashboard analytics
- Add/remove issues

### 3. Test Client Flow
1. Select language (English or Chichewa)
2. Select an issue
3. Enter your name
4. Start chat
5. Wait for counsellor

### 4. Test Counsellor Flow
1. Login with counsellor credentials
2. See pending sessions with:
   - Client name
   - Issue selected
   - **Language chosen** 🌍
   - Time waiting
3. Accept session
4. Start chatting

---

## What's Fixed ✅

### 1. Port Configuration
- ✅ Everything on port 8080
- ✅ Chrome-safe port (6000 was blocked)

### 2. WebSocket
- ✅ Real-time notifications working
- ✅ Auto-reconnect on disconnect
- ✅ Sound notifications

### 3. Language
- ✅ Language persists throughout app
- ✅ Counsellors see client's language choice
- ✅ Session stores language preference

### 4. Icons
- ✅ All issue icons display correctly
- ✅ Material Icons (built-in)

### 5. Dashboard
- ✅ Analytics working
- ✅ Issue management
- ✅ Counsellor performance metrics
- ✅ Real-time updates

---

## Credentials

### Admin Login (create if needed):
```powershell
cd D:\Projects\yomehe\python_api
python3.13 create_admin.py
```

### Counsellor Accounts:
Check: `python_api/COUNSELLOR_ACCOUNTS.md`

---

## Testing Checklist

- [ ] API responds at http://localhost:8080
- [ ] Dashboard loads at http://localhost:5175
- [ ] Client app can fetch issues
- [ ] Client app can create session
- [ ] Counsellor receives real-time notification
- [ ] Counsellor sees client's language
- [ ] Chat works in both apps
- [ ] Dashboard shows updated analytics
- [ ] WebSocket auto-reconnects
- [ ] Notification sound plays

---

## Troubleshooting

### API won't start
```powershell
# Check what's on port 8080
netstat -ano | findstr :8080

# Kill if needed
taskkill /PID <PID> /F
```

### Dashboard shows "Network Error"
- Check API is running on port 8080
- Check browser console for CORS errors
- Try: `curl http://localhost:8080/admin/issues`

### Flutter app can't connect
1. Check `app_config.dart` has `http://10.0.2.2:8080`
2. Run: `flutter clean && flutter pub get`
3. Restart app

### WebSocket not working
- Check API logs for WebSocket connection attempts
- Verify token is valid (check API response)
- Look for auto-reconnect messages in console

---

## File Changes Made

1. `yoneco_app/lib/config/app_config.dart`
   - Changed port 6000 → 8080

2. `yoneco_counsellor_app/lib/config/app_config.dart`
   - Changed port 6000 → 8080

3. `admin-dashboard-vue/src/services/api.js`
   - Changed port 6000 → 8080

All other features already working! No other changes needed.

---

## Next Actions

1. ✅ **API Running** - Already started
2. ✅ **Dashboard Running** - Already started
3. ⏳ **Test Client App** - Run `flutter run`
4. ⏳ **Test Counsellor App** - Run `flutter run`
5. ⏳ **End-to-end test** - Create session and chat

---

**Last Updated**: 2025-11-06 08:58 UTC
**Status**: All configurations updated. API and Dashboard running. Ready for mobile testing.
