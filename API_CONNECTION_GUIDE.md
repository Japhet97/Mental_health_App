# API Connection Guide - Tithandizane Helpline

## 🔧 Quick Setup

### Step 1: Add Firewall Rules (One-time setup)
**Run as Administrator:**
```powershell
.\add-firewall-rules.ps1
```
This allows your mobile device to connect to the API on port 8001.

### Step 2: Start the API
**Normal PowerShell:**
```powershell
.\START_API.ps1
```
The script will show you the IP address to use. Keep this terminal open.

### Step 3: Update App Configuration (If IP Changed)

**Client App:** `yoneco_app/lib/config/app_config.dart`
```dart
static const String apiBaseUrl = "http://YOUR_IP:8001";
```

**Counsellor App:** `yoneco_counsellor_app/lib/config/app_config.dart`
```dart
static const String apiBaseUrl = "http://YOUR_IP:8001";
```

Replace `YOUR_IP` with the IP shown when you started the API (e.g., `102.223.95.28`)

### Step 4: Connect Your Device

1. **Ensure both your computer and mobile device are on the same Wi-Fi network**
2. Run the Flutter app:
   ```bash
   cd yoneco_app
   flutter run
   ```

## 📱 Current Configuration

- **API URL:** `http://102.223.95.28:8001`
- **WebSocket:** `ws://102.223.95.28:8001`
- **API Port:** 8001

## ✅ Testing the Connection

### From Your Computer:
```powershell
curl http://102.223.95.28:8001
```
Expected response:
```json
{
  "message": "Tithandizane Helpline Mental Health Support API",
  "version": "1.0.0",
  "status": "running"
}
```

### From Your Mobile Device:
Open a browser on your phone and visit: `http://102.223.95.28:8001`

You should see the same JSON response.

## 🔍 Troubleshooting

### API Not Responding?
1. Check if API is running: `.\START_API.ps1`
2. Check firewall: Run `.\add-firewall-rules.ps1` as Administrator
3. Verify both devices are on same Wi-Fi network
4. Check if Windows Firewall or antivirus is blocking the port

### "Connection Refused" Error?
- The API might not be running
- Firewall is blocking port 8001
- Wrong IP address in app config

### IP Address Changed?
Your computer's IP can change when you reconnect to Wi-Fi. If connection stops working:
1. Run `.\START_API.ps1` to see your current IP
2. Update `apiBaseUrl` in both apps' `app_config.dart` files
3. Rebuild the Flutter apps

### "Session expired" in Counsellor App?
The counsellor needs to log in. Use one of these accounts:
- Email: `counsellor1@yoneco.org`, Password: `counsellor123`
- Email: `counsellor2@yoneco.org`, Password: `counsellor123`

## 🚀 Production Deployment

For production, you should:
1. Use a fixed IP or domain name
2. Set up HTTPS with SSL certificates
3. Use environment variables for configuration
4. Deploy to a cloud server (AWS, DigitalOcean, etc.)

## 📝 Notes

- Keep the API terminal window open while testing
- The API auto-reloads when you make code changes
- Check API logs in the terminal for debugging
- Client sessions expire after 30 minutes of inactivity
