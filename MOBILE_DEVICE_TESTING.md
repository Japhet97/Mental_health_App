# 📱 Mobile Device Testing Setup

## 🎯 Your Configuration
- **PC IP Address**: `102.223.95.129`
- **API Port**: `8001`
- **Web Port**: `5173`
- **Network**: Same Wi-Fi network required

---

## ✅ What's Already Configured

All apps are now configured to use:
- **API URL**: `http://102.223.95.129:8001`
- **Web URL**: `http://102.223.95.129:5173`

### Apps Ready for Mobile Testing:
1. ✅ **Client App** (yoneco_app) - Port 8001
2. ✅ **Counsellor App** (yoneco_counsellor_app) - Port 8001  
3. ✅ **Web App** (yoneco-web) - Port 5173

---

## 🚀 Quick Start (3 Steps)

### Step 1: Start the Backend API
```powershell
cd D:\Projects\yomehe\python_api
python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8001
```

### Step 2: Start the Web App (Optional)
```powershell
cd D:\Projects\yomehe\yoneco-web
npm run dev
```

### Step 3: Connect Your Mobile Device
1. Connect your phone to the **same Wi-Fi** as your PC (102.223.95.129)
2. Enable USB debugging on your phone
3. Connect via USB cable
4. Run the Flutter app:
   ```powershell
   cd D:\Projects\yomehe\yoneco_app
   flutter run
   ```

---

## 📲 Testing on Physical Device

### For Android:
```powershell
# Client App
cd D:\Projects\yomehe\yoneco_app
flutter run

# Counsellor App
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run
```

### For iOS:
```powershell
# Client App
cd D:\Projects\yomehe\yoneco_app
flutter run

# Counsellor App
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run
```

---

## 🌐 Access Web App from Mobile

1. Make sure web app is running
2. Open browser on your phone
3. Navigate to: `http://102.223.95.129:5173`
4. Login with counsellor credentials

---

## 🔧 Firewall Configuration

If you can't connect from mobile, allow ports through Windows Firewall:

```powershell
# Allow API port
netsh advfirewall firewall add rule name="YONECO API" dir=in action=allow protocol=TCP localport=8001

# Allow Web port
netsh advfirewall firewall add rule name="YONECO Web" dir=in action=allow protocol=TCP localport=5173
```

---

## 🧪 Test Checklist

### API Test:
- [ ] API running: http://102.223.95.129:8001/health
- [ ] Swagger docs: http://102.223.95.129:8001/docs

### Web App Test:
- [ ] Web app accessible from mobile browser
- [ ] Can login as counsellor
- [ ] WebSocket connection works

### Mobile Apps Test:
- [ ] Client app connects to API
- [ ] Can create anonymous session
- [ ] Can send/receive messages
- [ ] Counsellor app connects
- [ ] Can see active sessions
- [ ] Real-time chat works

---

## 🔍 Troubleshooting

### Can't Connect from Phone?

1. **Check PC IP** (run this to verify):
   ```powershell
   Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*"}
   ```

2. **Check same network**:
   - PC and phone must be on same Wi-Fi
   - Check phone Wi-Fi settings

3. **Ping test from phone**:
   - Install "Network Tools" app
   - Ping `102.223.95.129`
   - Should get response

4. **Check firewall**:
   - Temporarily disable Windows Firewall
   - If it works, add firewall rules above

### App Shows Connection Error?

1. **Restart API** with correct host:
   ```powershell
   python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8001
   ```

2. **Check API is accessible**:
   - From PC: http://localhost:8001/health
   - From phone browser: http://102.223.95.129:8001/health

3. **Hot restart Flutter app**:
   - Press `r` in terminal running Flutter
   - Or full restart: Press `R`

---

## 📝 Important Notes

### IP Address Changes
If your PC IP changes (e.g., after restart), update:

1. **Client App**: `yoneco_app/lib/config/app_config.dart`
2. **Counsellor App**: `yoneco_counsellor_app/lib/config/app_config.dart`
3. **Web App**: `yoneco-web/.env`
4. **API CORS**: `python_api/.env` (ALLOWED_ORIGINS)

### Network Requirements
- ✅ Same Wi-Fi network
- ✅ No VPN on PC or phone
- ✅ No firewall blocking
- ✅ Not on mobile data

### Alternative: Use Wi-Fi 2
Your PC has two network interfaces:
- Ethernet 2: `102.223.95.129`
- Wi-Fi 2: `102.223.95.15`

If one doesn't work, try the other by updating the configs.

---

## 🎬 Complete Test Flow

1. **Start API**: `python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8001`
2. **Start Web** (optional): `npm run dev` in yoneco-web
3. **Connect phone** via USB
4. **Run client app**: `flutter run` in yoneco_app
5. **Test from phone**:
   - Create anonymous session
   - Send message
6. **Open web app** in browser: http://102.223.95.129:5173
7. **Login as counsellor**: admin@yoneco.com / YonecoAdmin2024!
8. **Accept session** and reply
9. **Check real-time** sync on phone

---

## ✨ Success Indicators

### API Running:
```
INFO:     Uvicorn running on http://0.0.0.0:8001 (Press CTRL+C to quit)
INFO:     Application startup complete.
```

### Web Running:
```
VITE v7.0.6  ready in 543 ms

➜  Local:   http://localhost:5173/
➜  Network: http://102.223.95.129:5173/
```

### Flutter Connected:
```
Launching lib/main.dart on SM G960F in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build/app/outputs/flutter-apk/app-debug.apk.
Installing build/app/outputs/flutter-apk/app-debug.apk...
Syncing files to device...
```

---

## 🎉 You're All Set!

All configurations are complete. Just start the services and test on your mobile device!

**Need help?** Check troubleshooting section above or restart all services.
