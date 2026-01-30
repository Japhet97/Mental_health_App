# 🎉 Tithandizane Helpline - API Connection Fixed!

## ✅ What Was Done

### 1. **Branding Updates**
- ✅ Changed app name from "YONECO" to "Tithandizane Helpline"
- ✅ Replaced heart icons with actual logo (`assets/logo/logo.png`)
- ✅ Updated all language translations
- ✅ Updated API messages and titles

### 2. **IP Address Configuration**
- ✅ Detected current IP: **102.223.95.28**
- ✅ Updated client app config: `yoneco_app/lib/config/app_config.dart`
- ✅ Updated counsellor app config: `yoneco_counsellor_app/lib/config/app_config.dart`
- ✅ Updated firewall script with new IP

### 3. **API Server**
- ✅ API is running on: **http://102.223.95.28:8001**
- ✅ WebSocket available at: **ws://102.223.95.28:8001**
- ✅ Language support fully integrated
- ✅ Session monitoring active

## 🚀 How to Use

### To Start the API:
```powershell
.\START_API.ps1
```
**Keep this terminal open!**

### To Add Firewall Rules (First Time Only):
Right-click PowerShell → Run as Administrator, then:
```powershell
.\add-firewall-rules.ps1
```

### To Run the Client App:
```bash
cd yoneco_app
flutter run
```

### To Run the Counsellor App:
```bash
cd yoneco_counsellor_app
flutter run
```

## 📱 Current Setup

Both apps are configured to connect to:
- **API:** http://102.223.95.28:8001
- **WebSocket:** ws://102.223.95.28:8001

**Important:** Your computer and mobile device must be on the **same Wi-Fi network**!

## 🔧 If Connection Still Fails

1. **Check if API is running:**
   - Look for "Uvicorn running on http://0.0.0.0:8001" in the terminal
   - Test: `curl http://102.223.95.28:8001`

2. **Check firewall:**
   - Run `.\add-firewall-rules.ps1` as Administrator
   - Look for "✅ API firewall rule added successfully!"

3. **Verify IP address:**
   - Your IP may change when reconnecting to Wi-Fi
   - Run `ipconfig` to see current IP
   - Update both app configs if IP changed

4. **Check Wi-Fi:**
   - Computer and phone must be on same network
   - Some Wi-Fi networks block device-to-device communication (try a different network)

5. **Test from phone browser:**
   - Open browser on phone
   - Go to: http://102.223.95.28:8001
   - Should see: `{"message":"Tithandizane Helpline Mental Health Support API"...}`

## 📊 Features Working

- ✅ Language selection (English/Chichewa)
- ✅ Language preference sent to counsellor
- ✅ Logo displayed throughout apps
- ✅ Direct flow: Issues → Counsellor (no chatbot)
- ✅ Real-time WebSocket notifications
- ✅ Session monitoring and timeout
- ✅ Counsellor dashboard shows client language

## 🎯 Next Steps

1. Start the API: `.\START_API.ps1`
2. Run the client app on your phone
3. Run the counsellor app on another device
4. Test creating a session and chatting

## 📞 Test Counsellor Accounts

- **Email:** counsellor1@yoneco.org  
  **Password:** counsellor123

- **Email:** counsellor2@yoneco.org  
  **Password:** counsellor123

## 📚 Documentation

- Full setup guide: `API_CONNECTION_GUIDE.md`
- Mobile testing: `MOBILE_TESTING_GUIDE.md`
- Quick reference: `QUICK_START.md`

---

**The API is currently running and ready for connections!** 🚀
