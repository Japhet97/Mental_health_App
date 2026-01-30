# 📱 Mobile Connection Troubleshooting Guide

## 🎯 Current Setup
- **PC Wi-Fi Network**: Yoneco Wifi
- **PC IP Address**: 102.223.95.10
- **API Port**: 8001
- **Web Port**: 5173

---

## ✅ STEP 1: Connect Phone to Same Wi-Fi

**CRITICAL**: Your phone MUST be connected to: **Yoneco Wifi**

1. Open Wi-Fi settings on your phone
2. Connect to: **Yoneco Wifi**
3. Make sure you're NOT on mobile data

---

## ✅ STEP 2: Test from Phone Browser

Open your phone's browser and visit:

```
http://102.223.95.10:8001/health
```

**Expected result:**
```json
{"status":"healthy","service":"yoneco-api"}
```

### If you see this ✅
Great! API is accessible. Skip to Step 4.

### If you DON'T see this ❌
Continue to Step 3.

---

## ✅ STEP 3: Fix Firewall (Run as Administrator on PC)

### Option A: Run Automated Script
```powershell
D:\Projects\yomehe\add-firewall-rules.ps1
```

### Option B: Manual Commands
```powershell
netsh advfirewall firewall add rule name="YONECO API" dir=in action=allow protocol=TCP localport=8001
netsh advfirewall firewall add rule name="YONECO Web" dir=in action=allow protocol=TCP localport=5173
```

### Option C: Temporarily Disable Firewall (Testing Only)
```powershell
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

**After firewall fix, retry Step 2!**

---

## ✅ STEP 4: Test Network Connectivity

### From your phone, install "Network Tools" app and:

1. **Ping Test**: Ping `102.223.95.10`
   - Should get response
   
2. **Port Scanner**: Check port `8001` on `102.223.95.10`
   - Should show OPEN

---

## ✅ STEP 5: Run Flutter App

If browser test works (Step 2), run your app:

```powershell
cd D:\Projects\yomehe\yoneco_app
flutter run
```

Or for counsellor app:
```powershell
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run
```

---

## 🔍 Common Issues & Solutions

### Issue 1: "Cannot connect" or timeout
**Cause**: Phone not on same Wi-Fi  
**Solution**: Connect phone to "Yoneco Wifi"

### Issue 2: "Connection refused"
**Cause**: Firewall blocking port  
**Solution**: Run Step 3 commands

### Issue 3: "Network unreachable"
**Cause**: PC and phone on different networks  
**Solution**: Check both are on "Yoneco Wifi"

### Issue 4: IP address shows different
**Your Wi-Fi IP might change!**  
**Solution**: Run this on PC to check current IP:
```powershell
Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi 2"
```

If IP changed, update configs:
- `yoneco_app/lib/config/app_config.dart`
- `yoneco_counsellor_app/lib/config/app_config.dart`
- `yoneco-web/.env`

### Issue 5: Using VPN
**Cause**: VPN routing traffic differently  
**Solution**: Disable VPN on PC and phone

---

## 🧪 Quick Diagnostic Checklist

Run on PC:
```powershell
# 1. Check if API is running
netstat -ano | findstr ":8001"

# 2. Check current Wi-Fi IP
Get-NetIPAddress -InterfaceAlias "Wi-Fi 2" | Select-Object IPAddress

# 3. Test API locally
Invoke-RestMethod -Uri "http://102.223.95.10:8001/health"

# 4. Check firewall
Get-NetFirewallRule -DisplayName "*YONECO*"

# 5. Test port is open from network
Test-NetConnection -ComputerName 102.223.95.10 -Port 8001
```

---

## 📝 Verification Steps

### Before running app:
- [ ] Phone connected to "Yoneco Wifi"
- [ ] PC connected to "Yoneco Wifi"  
- [ ] API running on PC (port 8001)
- [ ] Can access http://102.223.95.10:8001/health from phone browser
- [ ] Firewall rules added OR firewall temporarily disabled

### If all checked:
✅ Flutter app should connect successfully!

---

## 🆘 Still Not Working?

### Try Alternative Solution: Use USB Debugging with Port Forwarding

If Wi-Fi doesn't work, use USB:

1. Connect phone via USB
2. Enable USB debugging on phone
3. Run on PC:
   ```powershell
   adb reverse tcp:8001 tcp:8001
   adb reverse tcp:5173 tcp:5173
   ```
4. Update app configs to use `localhost:8001`
5. Run `flutter run`

---

## 📞 Debug Info to Collect

If still failing, collect this info:

1. **PC IP**: `Get-NetIPAddress -InterfaceAlias "Wi-Fi 2"`
2. **Phone Wi-Fi**: What network is phone connected to?
3. **Phone IP**: Check in phone Wi-Fi settings
4. **API Status**: `netstat -ano | findstr ":8001"`
5. **Browser Test**: Screenshot of http://102.223.95.10:8001/health from phone
6. **Flutter Error**: Copy exact error message

---

## ✨ Success Indicators

### When everything works:

1. **Browser test**: Shows API health response ✅
2. **Flutter app**: Connects and shows home screen ✅
3. **Create session**: Can create anonymous session ✅
4. **Send message**: Can send and receive messages ✅

---

**Network**: Yoneco Wifi  
**PC IP**: 102.223.95.10  
**API URL**: http://102.223.95.10:8001
